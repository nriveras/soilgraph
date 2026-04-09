# nolint start: object_usage_linter.
#' Visualization Utilities
#'
#' Helper functions for soil profile visualization, including color validation,
#' data validation, and plotting utilities.

#' Validate if a string is a valid color
#'
#' Checks if the provided value is a valid R color specification.
#'
#' @param value Value to test
#'
#' @return Logical: TRUE if valid color, FALSE otherwise
#' @keywords internal
is_valid_color <- function(value) {
  if (is.null(value) || !is.character(value) || length(value) != 1) {
    return(FALSE)
  }

  !inherits(tryCatch(grDevices::col2rgb(value), error = function(e) NULL), "NULL")
}

#' Get horizon plot data with all visualization properties
#'
#' Extracts and prepares horizon data for visualization, applying defaults
#' and normalizing property values for use by graphics engines.
#'
#' @param profile A `soil_profile` object
#'
#' @return Data frame with columns: horizon_index, label, top, bottom, fill,
#'   midpoint, boundary_shape, boundary_grade, coarse_abundance, coarse_grade,
#'   coarse_type, coarse_size, coarse_color, coarse_percent
#' @keywords internal
build_horizon_plot_data <- function(profile) {
  if (!inherits(profile, "soil_profile")) {
    stop("`profile` must be a soil_profile object.", call. = FALSE)
  }

  horizon_count <- length(profile$horizons)
  fallback_colors <- grDevices::hcl.colors(horizon_count, palette = "Terrain 2", rev = TRUE)

  data <- data.frame(
    horizon_index = seq_len(horizon_count),
    label = vapply(
      seq_along(profile$horizons),
      function(index) profile$horizons[[index]]$label %||% paste0("H", index),
      character(1)
    ),
    top = vapply(profile$horizons, function(horizon) horizon$top, numeric(1)),
    bottom = vapply(profile$horizons, function(horizon) horizon$bottom, numeric(1)),
    fill = vapply(
      seq_along(profile$horizons),
      function(index) {
        candidate <- profile$horizons[[index]]$color
        if (is_valid_color(candidate)) {
          candidate
        } else {
          fallback_colors[[index]]
        }
      },
      character(1)
    ),
    boundary_shape = vapply(
      profile$horizons,
      function(horizon) tolower(horizon$boundary_shape %||% "smooth"),
      character(1)
    ),
    boundary_grade = vapply(
      profile$horizons,
      function(horizon) tolower(horizon$boundary_grade %||% "clear"),
      character(1)
    ),
    coarse_abundance = vapply(
      profile$horizons,
      function(horizon) tolower(horizon$coarse_abundance %||% "few"),
      character(1)
    ),
    coarse_grade = vapply(
      profile$horizons,
      function(horizon) tolower(horizon$coarse_grade %||% "moderate"),
      character(1)
    ),
    coarse_type = vapply(
      profile$horizons,
      function(horizon) tolower(horizon$coarse_type %||% "gravel"),
      character(1)
    ),
    coarse_size = vapply(
      profile$horizons,
      function(horizon) tolower(horizon$coarse_size %||% "medium"),
      character(1)
    ),
    coarse_color = vapply(
      profile$horizons,
      function(horizon) horizon$coarse_color %||% "#1B1B1B",
      character(1)
    ),
    coarse_percent = vapply(
      profile$horizons,
      function(horizon) horizon$coarse_percent %||% NA_real_,
      numeric(1)
    ),
    stringsAsFactors = FALSE
  )

  data$midpoint <- (data$top + data$bottom) / 2
  data
}

#' Generate a description of soil profile visualization
#'
#' Creates a summary string describing the profile and its visualization properties,
#' useful for accessibility and debugging.
#'
#' @param profile A `soil_profile` object
#'
#' @return Character string describing the profile
#' @keywords internal
describe_soil_profile <- function(profile) {
  n_horizons <- length(profile$horizons)
  total_depth <- profile$horizons[[n_horizons]]$bottom

  paste0(
    profile$site_id,
    " (",
    profile$classification$system,
    "): ",
    n_horizons,
    " horizons, ",
    total_depth,
    " cm deep"
  )
}


#' Create default theme for soil profile plots
#'
#' Returns a ggplot2 theme optimized for soil profile visualization.
#'
#' @param base_size Numeric: base font size
#' @param show_grid Logical: whether to show grid lines
#'
#' @return A ggplot2 theme object
#' @keywords internal
theme_soil_profile <- function(base_size = 12, show_grid = FALSE) {
  base_theme <- ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(size = ggplot2::rel(0.9)),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "right",
      plot.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.2)),
      plot.subtitle = ggplot2::element_text(size = ggplot2::rel(0.9), color = "#666666")
    )

  if (!show_grid) {
    base_theme <- base_theme +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.major.x = ggplot2::element_blank()
      )
  }

  base_theme
}

#' Get color palette for horizons based on classification
#'
#' Returns an appropriate color palette based on horizon properties.
#'
#' @param n Number of colors needed
#' @param palette Character: palette name ("Terrain 2", "Spectral", etc.)
#'
#' @return Character vector of colors
#' @keywords internal
get_horizon_palette <- function(n, palette = "Terrain 2") {
  grDevices::hcl.colors(n, palette = palette, rev = TRUE)
}

#' Encode fragment properties into visual encoding scheme
#'
#' Creates a mapping of fragment properties to visual attributes
#' (size, transparency, color, shape).
#'
#' @param horizon_data Data frame with horizon properties
#'
#' @return List with named elements describing visual encoding
#' @keywords internal
create_fragment_encoding <- function(horizon_data) {
  list(
    size_mapping = c(
      "very fine" = 1.0,
      "fine" = 1.3,
      "small" = 1.6,
      "medium" = 2.0,
      "coarse" = 2.6,
      "large" = 3.2,
      "very coarse" = 3.8
    ),
    grade_mapping = c(
      "very weak" = 0.3,
      "weak" = 0.45,
      "moderate" = 0.65,
      "strong" = 0.82,
      "very strong" = 0.95
    ),
    abundance_mapping = c(
      "very few" = 6,
      "few" = 10,
      "common" = 18,
      "many" = 30,
      "abundant" = 42
    ),
    type_shapes = c(
      "gravel" = 16,
      "cobble" = 15,
      "stone" = 17,
      "boulder" = 18,
      "channer" = 3,
      "flagstone" = 0
    )
  )
}

#' Encode boundary properties into visual representation
#'
#' Creates visual properties for boundary rendering based on descriptive attributes.
#'
#' @param boundary_grade Character: boundary distinctness
#' @param boundary_shape Character: boundary topography
#'
#' @return List with visual properties: linewidth, linetype, smoothing
#' @keywords internal
create_boundary_encoding <- function(boundary_grade = "clear", boundary_shape = "smooth") {
  boundary_grade <- tolower(boundary_grade %||% "clear")
  boundary_shape <- tolower(boundary_shape %||% "smooth")

  list(
    grade = boundary_grade,
    shape = boundary_shape,
    linewidth = switch(boundary_grade,
      "abrupt" = 0.8,
      "clear" = 0.5,
      "gradual" = 0.35,
      "diffuse" = 0.2,
      0.5 # default
    ),
    linetype = switch(boundary_grade,
      "abrupt" = "solid",
      "clear" = "solid",
      "gradual" = "dashed",
      "diffuse" = "dotted",
      "solid" # default
    ),
    distortion_level = switch(boundary_shape,
      "smooth" = 0.0,
      "wavy" = 0.6,
      "irregular" = 0.8,
      "broken" = 1.0,
      "discontinuous" = 0.9,
      0.0 # default
    )
  )
}

#' Compute color contrast for accessibility
#'
#' Determines if text should be light or dark based on background color.
#'
#' @param bg_color Character: background color specification
#'
#' @return Character: "#FFFFFF" for light text or "#000000" for dark text
#' @keywords internal
get_contrasting_text_color <- function(bg_color) {
  tryCatch(
    {
      rgb_matrix <- grDevices::col2rgb(bg_color)
      # Calculate luminance
      luminance <- (0.299 * rgb_matrix[1] + 0.587 * rgb_matrix[2] + 0.114 * rgb_matrix[3]) / 255
      if (luminance > 0.5) "#000000" else "#FFFFFF"
    },
    error = function(e) {
      # Default to dark text if color parsing fails
      "#000000"
    }
  )
}

# nolint end
