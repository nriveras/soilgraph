# nolint start: object_usage_linter.
#' Coarse Fragment Engine
#'
#' Generates irregular shapes for coarse fragments based on soil description properties.
#' Creates mathematically irregular polygons that visually represent different fragment
#' types, sizes, and abundances in soil profiles.

#' Generate irregular polygon for a single coarse fragment
#'
#' @param center_x X-coordinate of fragment center
#' @param center_y Y-coordinate of fragment center
#' @param size Numeric size multiplier (1-5 range typical)
#' @param total_depth Total depth of the soil profile for aspect ratio correction
#' @param seed Random seed for reproducible shape generation
#'
#' @return A data frame with columns: x, y, fragment_id
#' @keywords internal
generate_fragment_shape <- function(center_x, center_y, size, fragment_type, total_depth = 100, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }

  fragment_type <- tolower(fragment_type)

  # Base parameters for each fragment type
  # aspect_ratio > 1 means taller (Y), < 1 means wider (X)
  type_params <- list(
    gravel = list(n_vertices = 6, irregularity = 0.35, aspect_ratio = 1.0),
    cobble = list(n_vertices = 7, irregularity = 0.25, aspect_ratio = 1.1),
    stone = list(n_vertices = 5, irregularity = 0.40, aspect_ratio = 1.3),
    boulder = list(n_vertices = 8, irregularity = 0.20, aspect_ratio = 0.95),
    channer = list(n_vertices = 4, irregularity = 0.50, aspect_ratio = 0.6), # Flat
    flagstone = list(n_vertices = 4, irregularity = 0.45, aspect_ratio = 0.5) # Flatter
  )

  params <- type_params[[fragment_type]] %||% type_params$gravel

  # Generate base vertices
  n_vertices <- params$n_vertices
  angles <- seq(0, 2 * pi, length.out = n_vertices + 1)[seq_len(n_vertices)]

  # Scale radii independently for each axis to avoid elongation.
  # X axis spans 0-1 (unit scale), Y axis spans depth in cm.
  # A single radius produces shapes stretched across the full X axis.
  # We use a base factor of 1.25 relative to a 100cm depth reference.
  base_radius_x <- size * (1.25 / total_depth)
  base_radius_y <- size * 1.0

  radii_x <- base_radius_x + stats::rnorm(n_vertices, 0, base_radius_x * params$irregularity)
  radii_y <- base_radius_y + stats::rnorm(n_vertices, 0, base_radius_y * params$irregularity)
  radii_x <- pmax(radii_x, base_radius_x * 0.3)
  radii_y <- pmax(radii_y, base_radius_y * 0.3)

  # Apply aspect ratio
  x_dist <- radii_x * cos(angles)
  y_dist <- radii_y * sin(angles) * params$aspect_ratio

  # Add small noise to each vertex
  x_dist <- x_dist + stats::rnorm(n_vertices, 0, base_radius_x * 0.1)
  y_dist <- y_dist + stats::rnorm(n_vertices, 0, base_radius_y * 0.1)

  # Close the polygon
  x_coords <- center_x + c(x_dist, x_dist[1])
  y_coords <- center_y + c(y_dist, y_dist[1])

  data.frame(
    x = x_coords,
    y = y_coords,
    stringsAsFactors = FALSE
  )
}

#' Generate layout of coarse fragments for a horizon
#'
#' Creates a spatial distribution of irregular coarse fragment shapes within
#' a horizon layer. Fragments are distributed based on abundance, with visual
#' properties encoded by size, grade, and type.
#'
#' @param horizon_data Data frame row containing horizon properties
#' @param horizon_index Integer index of the horizon
#' @param total_depth Total depth of the soil profile for scaling
#' @param seed Random seed for reproducible placement
#'
#' @return A data frame with fragment polygon coordinates and properties
#' @keywords internal
generate_horizon_fragments <- function(horizon_data, horizon_index, total_depth = 100, seed = 1) {
  abundance <- tolower(horizon_data$coarse_abundance[[1]])
  percent <- horizon_data$coarse_percent[[1]]
  grade <- tolower(horizon_data$coarse_grade[[1]])
  size_class <- tolower(horizon_data$coarse_size[[1]])
  fragment_type <- horizon_data$coarse_type[[1]]

  # Determine number of fragments
  fragment_count <- coarse_fragment_count(abundance, percent)

  if (fragment_count <= 0) {
    return(NULL)
  }

  set.seed(seed + 100 * horizon_index)

  # Generate fragment positions and shapes
  fragments_list <- lapply(seq_len(fragment_count), function(frag_idx) {
    # Random position within horizon
    center_x <- stats::runif(1, 0.07, 0.93)
    center_y <- stats::runif(1, horizon_data$top[[1]] + 0.8, horizon_data$bottom[[1]] - 0.8)

    # Marker size based on grade and size class
    marker_size <- coarse_size_to_marker(size_class)

    # Generate irregular polygon
    shape <- generate_fragment_shape(
      center_x = center_x,
      center_y = center_y,
      size = marker_size,
      fragment_type = fragment_type,
      total_depth = total_depth,
      seed = seed + 100 * horizon_index + frag_idx
    )

    shape$fragment_id <- paste0("h", horizon_index, "_f", frag_idx)
    shape$fragment_type <- fragment_type
    shape$grade <- grade
    shape$alpha <- coarse_grade_to_alpha(grade)
    shape$color <- normalized_fragment_color(horizon_data$coarse_color[[1]])

    shape
  })

  do.call(rbind, fragments_list)
}

#' Build complete fragment layout for entire profile
#'
#' Orchestrates the generation of coarse fragment polygons for all horizons
#' in a soil profile.
#'
#' @param profile A `soil_profile` object
#' @param seed Random seed for reproducible fragment generation
#'
#' @return A data frame with polygon coordinates for all fragments
#' @keywords internal
build_fragment_polygons <- function(profile, seed = 1) {
  horizon_data_full <- build_horizon_plot_data(profile)
  total_depth <- max(horizon_data_full$bottom)

  fragments_list <- lapply(seq_len(nrow(horizon_data_full)), function(idx) {
    horizon_row <- horizon_data_full[idx, ]
    generate_horizon_fragments(horizon_row, idx, total_depth = total_depth, seed = seed)
  })

  fragments_list <- Filter(Negate(is.null), fragments_list)

  if (length(fragments_list) == 0) {
    return(NULL)
  }

  do.call(rbind, fragments_list)
}

#' Render coarse fragments as geom_polygon layer
#'
#' Creates ggplot2 layers for rendering coarse fragments with proper
#' coloring and transparency based on fragment properties.
#'
#' @param fragment_data Data frame from `build_fragment_polygons()`
#'
#' @return A list of ggplot2 layer objects
#' @keywords internal
layer_coarse_fragments <- function(fragment_data) {
  if (is.null(fragment_data) || nrow(fragment_data) == 0) {
    return(list())
  }

  .data <- rlang::.data

  list(
    ggplot2::geom_polygon(
      data = fragment_data,
      ggplot2::aes(
        x = .data$x,
        y = .data$y,
        group = .data$fragment_id,
        fill = .data$color,
        alpha = .data$alpha
      ),
      color = "#332211",
      linewidth = 0.2,
      inherit.aes = FALSE
    ),
    ggplot2::scale_fill_identity(),
    ggplot2::scale_alpha_identity()
  )
}

#' Helper function to count fragments based on abundance
#'
#' Maps soil description abundance terms to fragment count.
#'
#' @param abundance Character: abundance descriptor
#' @param percent Optional numeric: percentage override
#'
#' @return Integer count of fragments
#' @keywords internal
coarse_fragment_count <- function(abundance, percent) {
  if (!is.na(percent)) {
    return(max(3, as.integer(round(percent * 1.2))))
  }

  mapping <- c(
    "very few" = 6,
    few = 10,
    common = 18,
    many = 30,
    abundant = 42
  )

  if (!abundance %in% names(mapping)) {
    return(10)
  }

  unname(mapping[[abundance]])
}

#' Map size class to marker size
#'
#' @param size_class Character: size descriptor
#'
#' @return Numeric marker size
#' @keywords internal
coarse_size_to_marker <- function(size_class) {
  mapping <- c(
    "very fine" = 1.0,
    fine = 1.3,
    small = 1.6,
    medium = 2.0,
    coarse = 2.6,
    large = 3.2,
    "very coarse" = 3.8
  )

  if (!size_class %in% names(mapping)) {
    return(2.0)
  }

  unname(mapping[[size_class]])
}

#' Map grade to transparency
#'
#' @param grade Character: grade descriptor
#'
#' @return Numeric alpha value (0-1)
#' @keywords internal
coarse_grade_to_alpha <- function(grade) {
  mapping <- c(
    "very weak" = 0.3,
    weak = 0.45,
    moderate = 0.65,
    strong = 0.82,
    "very strong" = 0.95
  )

  if (!grade %in% names(mapping)) {
    return(0.65)
  }

  unname(mapping[[grade]])
}

#' Normalize fragment type
#'
#' @param fragment_type Character: type descriptor
#'
#' @return Character: normalized type or "gravel" as fallback
#' @keywords internal
normalize_fragment_type <- function(fragment_type) {
  valid <- c("gravel", "cobble", "stone", "boulder", "channer", "flagstone")
  if (fragment_type %in% valid) {
    fragment_type
  } else {
    "gravel"
  }
}

#' Normalize fragment color
#'
#' @param color Character or NULL: color specification
#'
#' @return Character: valid color or default
#' @keywords internal
normalized_fragment_color <- function(color) {
  if (is_valid_color(color)) {
    color
  } else {
    "#1B1B1B"
  }
}

# nolint end
