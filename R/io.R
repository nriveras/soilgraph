# nolint start: object_usage_linter.
#' Write a soil profile to JSON
#'
#' @param profile A `soil_profile` object.
#' @param path Output file path.
#' @param pretty Whether to format the JSON output.
#'
#' @return The normalized output path, invisibly.
#' @export
write_soil_json <- function(profile, path, pretty = TRUE) {
  validate_soil_profile(profile)

  output_dir <- dirname(path)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  jsonlite::write_json(
    strip_soil_classes(profile),
    path = path,
    pretty = pretty,
    auto_unbox = TRUE,
    null = "null"
  )

  invisible(normalizePath(path, winslash = "/", mustWork = FALSE))
}

#' Read a soil profile from JSON
#'
#' @param path Input file path.
#'
#' @return A `soil_profile` object.
#' @export
read_soil_json <- function(path) {
  payload <- jsonlite::read_json(path, simplifyVector = FALSE)

  horizons <- lapply(payload$horizons %||% list(), function(horizon) {
    new_soil_horizon(
      top = horizon$top,
      bottom = horizon$bottom,
      label = horizon$label,
      texture = horizon$texture,
      color = horizon$color,
      moisture = horizon$moisture,
      boundary_grade = horizon$boundary_grade,
      boundary_shape = horizon$boundary_shape,
      coarse_abundance = horizon$coarse_abundance,
      coarse_shape = horizon$coarse_shape,
      coarse_grade = horizon$coarse_grade,
      coarse_type = horizon$coarse_type,
      coarse_size = horizon$coarse_size,
      coarse_color = horizon$coarse_color,
      coarse_percent = horizon$coarse_percent,
      notes = horizon$notes
    )
  })

  profile <- new_soil_profile(
    site_id = payload$site_id,
    horizons = horizons,
    classification = payload$classification %||% list(system = "Soil Taxonomy"),
    metadata = payload$metadata %||% list()
  )

  profile$schema_version <- payload$schema_version %||% profile$schema_version
  profile
}

strip_soil_classes <- function(value) {
  if (inherits(value, "soil_profile") || inherits(value, "soil_horizon")) {
    class(value) <- "list"
  }

  if (!is.list(value)) {
    return(value)
  }

  lapply(value, strip_soil_classes)
}

# nolint end
