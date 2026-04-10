# nolint start: object_usage_linter.
#' Horizon Boundary Engine
#'
#' Generates irregular boundary lines between soil horizons based on
#' descriptive properties like boundary grade (distinctness) and shape (topography).

#' Generate a single irregular boundary line
#'
#' Creates a path representing the boundary between two soil horizons with
#' irregularity based on boundary_shape and boundary_grade properties.
#'
#' @param depth_cm Numeric depth value (y-coordinate) of the boundary
#' @param boundary_shape Character: "smooth", "wavy", "irregular", "broken", "discontinuous"
#' @param boundary_grade Character: "abrupt", "clear", "gradual", "diffuse"
#' @param thickness_cm Optional boundary transition thickness in centimeters.
#' @param x_range Numeric vector of length 2: x-coordinate range (default: 0 to 1)
#' @param seed Random seed for reproducible generation
#' @param boundary_id Character: unique identifier for the boundary
#'
#' @return Data frame with columns: x, y, boundary_id
#' @keywords internal
generate_boundary_path <- function(
    depth_cm,
    boundary_shape = "smooth",
    boundary_grade = "clear",
    thickness_cm = NULL,
    x_range = c(0, 1),
    seed = 1,
    boundary_id = "boundary") {
  boundary_shape <- tolower(boundary_shape %||% "smooth")
  boundary_grade <- tolower(boundary_grade %||% "clear")
  thickness_cm <- resolve_boundary_thickness_cm(
    grade = boundary_grade,
    thickness_cm = thickness_cm
  )

  # Generate base x-coordinates
  n_points <- 200
  x_vals <- seq(x_range[1], x_range[2], length.out = n_points)
  y_vals <- rep(depth_cm, n_points)

  # Apply shape distortion
  shape_distortion <- generate_boundary_distortion(
    x_vals = x_vals,
    shape = boundary_shape,
    amplitude_cm = thickness_cm,
    seed = seed
  )

  # Apply grade-based smoothing
  grade_smoothing <- compute_boundary_smoothing(
    distortion = shape_distortion,
    grade = boundary_grade,
    seed = seed
  )

  y_vals <- y_vals + grade_smoothing

  data.frame(
    x = x_vals,
    y = y_vals,
    boundary_id = boundary_id,
    boundary_shape = boundary_shape,
    boundary_grade = boundary_grade,
    boundary_thickness_cm = thickness_cm,
    stringsAsFactors = FALSE
  )
}

#' Generate positional distortion for boundary shape
#'
#' @param x_vals Numeric vector of x-coordinates
#' @param shape Character: boundary shape type
#' @param amplitude_cm Numeric transition thickness scale in centimeters
#' @param seed Random seed
#'
#' @return Numeric vector of y-distortions
#' @keywords internal
generate_boundary_distortion <- function(x_vals, shape = "smooth", amplitude_cm = 3, seed = 1) {
  n <- length(x_vals)
  distortion <- rep(0, n)
  amplitude_cm <- max(as.numeric(amplitude_cm %||% 0), 0)

  if (identical(shape, "smooth")) {
    # No distortion
    distortion <- rep(0, n)
  } else if (identical(shape, "wavy")) {
    # Smooth, regular waves
    distortion <- 0.4 * amplitude_cm * sin(seq(0, 8 * pi, length.out = n))
  } else if (identical(shape, "irregular")) {
    # Irregular with noise
    set.seed(seed)
    # Perlin-style noise via cumulative normal distribution
    raw_noise <- stats::rnorm(n, mean = 0, sd = 0.08)
    distortion <- cumsum(raw_noise)
    distortion <- distortion - mean(distortion)
    if (max(abs(distortion)) > 0) {
      distortion <- distortion * ((0.5 * amplitude_cm) / max(abs(distortion)))
    }
  } else if (identical(shape, "broken")) {
    # Sharp, discontinuous changes
    set.seed(seed)
    # Create segments with random offsets
    segment_length <- as.integer(n / 8)
    segment_offsets <- stats::rnorm(8, 0, 0.6 * amplitude_cm)

    for (i in seq_along(segment_offsets)) {
      start_idx <- (i - 1) * segment_length + 1
      end_idx <- min(i * segment_length, n)
      distortion[start_idx:end_idx] <- segment_offsets[i]
    }

    # Add small noise within segments
    distortion <- distortion + stats::rnorm(n, 0, 0.08 * amplitude_cm)
  } else if (identical(shape, "discontinuous")) {
    # Patchy, intermittent discontinuities
    set.seed(seed)
    # Random patches of distortion
    patch_size <- as.integer(n / 12)
    positions <- sample(seq(1, n - patch_size), 4, replace = FALSE)

    for (pos in positions) {
      patch_depth <- stats::rnorm(1, 0.5 * amplitude_cm, 0.2 * amplitude_cm)
      distortion[pos:(pos + patch_size - 1)] <- patch_depth
    }

    distortion <- distortion + stats::rnorm(n, 0, 0.06 * amplitude_cm)
  }

  distortion
}

#' Apply boundary grade-based smoothing
#'
#' Modulates distortion magnitude based on distinctness grade.
#' Abrupt boundaries have sharper transitions, gradual/diffuse are smoother.
#'
#' @param distortion Numeric vector of distortions
#' @param grade Character: boundary grade
#' @param seed Random seed
#'
#' @return Numeric vector of smoothed distortions
#' @keywords internal
compute_boundary_smoothing <- function(distortion, grade = "clear", seed = 1) {
  n <- length(distortion)

  # Smooth using rolling average based on grade
  window_size <- switch(grade,
    "abrupt" = 2,
    "clear" = 5,
    "gradual" = 10,
    "diffuse" = 20,
    5 # default
  )

  # Apply Tukey smoothing
  smoothed <- distortion

  if (window_size > 1) {
    half_window <- as.integer(window_size / 2)
    for (i in seq_len(n)) {
      start_idx <- max(1, i - half_window)
      end_idx <- min(n, i + half_window)
      smoothed[i] <- mean(distortion[start_idx:end_idx])
    }
  }

  # Scale by grade distinctness
  grade_scale <- switch(grade,
    "abrupt" = 1.0,
    "clear" = 0.7,
    "gradual" = 0.4,
    "diffuse" = 0.15,
    0.7 # default
  )

  smoothed * grade_scale
}

#' Build boundary paths for all horizons in a profile
#'
#' Generates irregular boundary lines between sequential horizons,
#' encoding boundary properties into visual irregularity.
#'
#' @param horizon_data Data frame with horizon properties from `build_horizon_plot_data()`
#' @param seed Random seed for reproducible generation
#'
#' @return Data frame with boundary path coordinates
#' @keywords internal
build_boundary_paths <- function(horizon_data, seed = 1) {
  if (nrow(horizon_data) <= 1) {
    return(data.frame())
  }

  boundary_rows <- lapply(seq_len(nrow(horizon_data) - 1), function(index) {
    depth <- horizon_data$bottom[[index]]
    shape <- horizon_data$boundary_shape[[index]]
    grade <- horizon_data$boundary_grade[[index]]
    thickness <- horizon_data$boundary_thickness_cm[[index]]

    generate_boundary_path(
      depth_cm = depth,
      boundary_shape = shape,
      boundary_grade = grade,
      thickness_cm = thickness,
      seed = seed + index,
      boundary_id = paste0("b", index)
    )
  })

  do.call(rbind, boundary_rows)
}

#' Build horizon polygons that follow boundary paths
#'
#' Uses adjacent boundary paths to construct closed polygons for each horizon.
#' Polygon top edges follow the upper boundary and bottom edges follow the lower
#' boundary, producing shaped fills that match rendered contacts.
#'
#' @param horizon_data Data frame with horizon properties from `build_horizon_plot_data()`
#' @param boundary_data Optional data frame from `build_boundary_paths()`
#' @param minimum_thickness Minimum vertical separation between top and bottom edges
#'   in centimeters (default: 0.02)
#'
#' @return Data frame with polygon coordinates for `geom_polygon()`
#' @keywords internal
# nolint next: object_length_linter.
build_horizon_polygons <- function(
    horizon_data,
    boundary_data = NULL,
    minimum_thickness = 0.02) {
  if (nrow(horizon_data) == 0) {
    return(data.frame())
  }

  if (is.null(boundary_data)) {
    boundary_data <- build_boundary_paths(horizon_data)
  }

  x_vals <- seq(0, 1, length.out = 200)
  horizon_count <- nrow(horizon_data)

  get_boundary <- function(index) {
    boundary_id <- paste0("b", index)
    boundary <- boundary_data[boundary_data$boundary_id == boundary_id, ]

    if (nrow(boundary) == 0) {
      return(NULL)
    }

    boundary <- boundary[order(boundary$x), c("x", "y")]
    rownames(boundary) <- NULL
    boundary
  }

  polygon_rows <- lapply(seq_len(horizon_count), function(index) {
    top_boundary <- if (index == 1) {
      data.frame(x = x_vals, y = rep(horizon_data$top[[index]], length(x_vals)))
    } else {
      get_boundary(index - 1)
    }

    bottom_boundary <- if (index == horizon_count) {
      data.frame(x = x_vals, y = rep(horizon_data$bottom[[index]], length(x_vals)))
    } else {
      get_boundary(index)
    }

    if (is.null(top_boundary)) {
      top_boundary <- data.frame(x = x_vals, y = rep(horizon_data$top[[index]], length(x_vals)))
    }
    if (is.null(bottom_boundary)) {
      bottom_boundary <- data.frame(x = x_vals, y = rep(horizon_data$bottom[[index]], length(x_vals)))
    }

    # Keep horizons from collapsing where adjacent boundaries get very close.
    if (length(top_boundary$y) == length(bottom_boundary$y)) {
      bottom_boundary$y <- pmax(bottom_boundary$y, top_boundary$y + minimum_thickness)
    }

    polygon_id <- paste0("h", horizon_data$horizon_index[[index]])

    rbind(
      data.frame(
        x = bottom_boundary$x,
        y = bottom_boundary$y,
        horizon_index = horizon_data$horizon_index[[index]],
        label = horizon_data$label[[index]],
        fill = horizon_data$fill[[index]],
        polygon_id = polygon_id,
        stringsAsFactors = FALSE
      ),
      data.frame(
        x = rev(top_boundary$x),
        y = rev(top_boundary$y),
        horizon_index = horizon_data$horizon_index[[index]],
        label = horizon_data$label[[index]],
        fill = horizon_data$fill[[index]],
        polygon_id = polygon_id,
        stringsAsFactors = FALSE
      )
    )
  })

  do.call(rbind, polygon_rows)
}

#' Render boundary lines as ggplot2 geometries
#'
#' Creates appropriate graphical layers for displaying horizon boundaries,
#' with visual properties encoding boundary distinctness and topography.
#'
#' @param boundary_data Data frame from `build_boundary_paths()`
#' @param line_color Character: color for boundary lines (default: dark brown)
#' @param line_width Numeric: line width (default: 0.5)
#'
#' @return A list of ggplot2 layer objects
#' @keywords internal
layer_horizon_boundaries <- function(
    boundary_data,
    line_color = "#1B1B1B",
    line_width = 0.5) {
  if (is.null(boundary_data) || nrow(boundary_data) == 0) {
    return(list())
  }

  .data <- rlang::.data

  # Map boundary grade to line type for additional visual encoding
  boundary_data$linetype <- tolower(boundary_data$boundary_grade %||% "clear")
  boundary_data$linetype <- ifelse(
    boundary_data$linetype %in% c("abrupt", "clear"),
    "solid",
    "dashed"
  )

  list(
    ggplot2::geom_path(
      data = boundary_data,
      ggplot2::aes(
        x = .data$x,
        y = .data$y,
        group = .data$boundary_id,
        linetype = .data$linetype
      ),
      color = line_color,
      linewidth = line_width,
      inherit.aes = FALSE
    ),
    ggplot2::scale_linetype_manual(
      values = c("solid" = "solid", "dashed" = "dashed"),
      guide = "none"
    )
  )
}

#' Create a transition zone visualization for gradual/diffuse boundaries
#'
#' For boundaries with gradual or diffuse grades, optionally render a
#' semi-transparent zone representing the transitional layer.
#'
#' @param horizon_data Data frame with horizon properties
#' @param seed Random seed
#'
#' @return Data frame specifying transition zone rectangles
#' @keywords internal
# nolint next: object_length_linter.
build_boundary_transition_zones <- function(horizon_data, seed = 1) {
  if (nrow(horizon_data) <= 1) {
    return(data.frame())
  }

  boundary_data <- build_boundary_paths(horizon_data, seed = seed)
  if (nrow(boundary_data) == 0) {
    return(data.frame())
  }

  zone_rows <- lapply(seq_len(nrow(horizon_data) - 1), function(index) {
    grade <- tolower(horizon_data$boundary_grade[[index]] %||% "clear")
    thickness_cm <- resolve_boundary_thickness_cm(
      grade = grade,
      thickness_cm = horizon_data$boundary_thickness_cm[[index]]
    )

    if (thickness_cm <= 0) {
      return(NULL)
    }

    zone_alpha <- switch(grade,
      "abrupt" = 0.03,
      "clear" = 0.05,
      "gradual" = 0.08,
      "diffuse" = 0.12,
      0.05
    )

    boundary_id <- paste0("b", index)
    boundary <- boundary_data[boundary_data$boundary_id == boundary_id, c("x", "y")]

    if (nrow(boundary) == 0) {
      return(NULL)
    }

    zone_id <- paste0("zone", index)
    upper <- boundary
    lower <- boundary
    upper$y <- upper$y - (thickness_cm / 2)
    lower$y <- lower$y + (thickness_cm / 2)

    rbind(
      data.frame(
        boundary_id = zone_id,
        x = upper$x,
        y = upper$y,
        zone_alpha = zone_alpha,
        zone_grade = grade,
        stringsAsFactors = FALSE
      ),
      data.frame(
        boundary_id = zone_id,
        x = rev(lower$x),
        y = rev(lower$y),
        zone_alpha = zone_alpha,
        zone_grade = grade,
        stringsAsFactors = FALSE
      )
    )
  })

  zone_rows <- Filter(Negate(is.null), zone_rows)

  if (length(zone_rows) == 0) {
    return(data.frame())
  }

  do.call(rbind, zone_rows)
}

#' Layer for rendering transition zones
#'
#' @param zone_data Data frame from `build_boundary_transition_zones()`
#'
#' @return A ggplot2 layer object (or empty list if no zones)
#' @keywords internal
# nolint next: object_length_linter.
layer_boundary_transition_zones <- function(zone_data) {
  if (is.null(zone_data) || nrow(zone_data) == 0) {
    return(list())
  }

  .data <- rlang::.data

  list(
    ggplot2::geom_polygon(
      data = zone_data,
      ggplot2::aes(
        x = .data$x,
        y = .data$y,
        group = .data$boundary_id,
        alpha = .data$zone_alpha
      ),
      fill = "#8B7355",
      inherit.aes = FALSE
    ),
    ggplot2::scale_alpha_identity()
  )
}

# nolint end
