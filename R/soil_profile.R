#' Construct a soil horizon
#'
#' @param top Top depth in centimeters.
#' @param bottom Bottom depth in centimeters.
#' @param label Horizon label, such as `A` or `Bt1`.
#' @param texture Optional texture description.
#' @param color Optional display color or color description.
#' @param moisture Optional moisture state.
#' @param boundary_grade Optional horizon boundary distinctness.
#' @param boundary_shape Optional horizon boundary topography.
#' @param coarse_abundance Optional coarse fragment abundance.
#' @param coarse_shape Optional coarse fragment shape.
#' @param coarse_grade Optional coarse fragment grade.
#' @param coarse_type Optional coarse fragment type.
#' @param coarse_size Optional coarse fragment size class.
#' @param coarse_color Optional coarse fragment color.
#' @param coarse_percent Optional coarse fragment proportion (0-100).
#' @param notes Optional free-text notes.
#'
#' @return A `soil_horizon` object.
#' @export
new_soil_horizon <- function(
    top,
    bottom,
    label = NULL,
    texture = NULL,
    color = NULL,
    moisture = NULL,
    boundary_grade = NULL,
    boundary_shape = NULL,
    coarse_abundance = NULL,
    coarse_shape = NULL,
    coarse_grade = NULL,
    coarse_type = NULL,
    coarse_size = NULL,
    coarse_color = NULL,
    coarse_percent = NULL,
    notes = NULL) {
  top <- validate_depth_value(top, "top")
  bottom <- validate_depth_value(bottom, "bottom")

  if (top < 0) {
    stop("`top` must be greater than or equal to 0.", call. = FALSE)
  }

  if (bottom <= top) {
    stop("`bottom` must be greater than `top`.", call. = FALSE)
  }

  horizon <- list(
    top = top,
    bottom = bottom,
    label = validate_optional_string(label, "label"),
    texture = validate_optional_string(texture, "texture"),
    color = validate_optional_string(color, "color"),
    moisture = validate_optional_string(moisture, "moisture"),
    boundary_grade = validate_optional_string(boundary_grade, "boundary_grade"),
    boundary_shape = validate_optional_string(boundary_shape, "boundary_shape"),
    coarse_abundance = validate_optional_string(coarse_abundance, "coarse_abundance"),
    coarse_shape = validate_optional_string(coarse_shape, "coarse_shape"),
    coarse_grade = validate_optional_string(coarse_grade, "coarse_grade"),
    coarse_type = validate_optional_string(coarse_type, "coarse_type"),
    coarse_size = validate_optional_string(coarse_size, "coarse_size"),
    coarse_color = validate_optional_string(coarse_color, "coarse_color"),
    coarse_percent = validate_optional_number(coarse_percent, "coarse_percent", min = 0, max = 100),
    notes = validate_optional_string(notes, "notes")
  )

  class(horizon) <- c("soil_horizon", "list")
  horizon
}

#' Construct a soil profile
#'
#' @param site_id Site identifier.
#' @param horizons A non-empty list of `soil_horizon` objects.
#' @param classification A named list describing the classification system and taxon.
#' @param metadata A named list with arbitrary profile metadata.
#'
#' @return A `soil_profile` object.
#' @importFrom rlang %||%
#' @export
new_soil_profile <- function(
    site_id,
    horizons,
    classification = list(system = "Soil Taxonomy", taxon = NULL),
    metadata = list()) {
  site_id <- validate_required_string(site_id, "site_id")

  if (!is.list(horizons) || length(horizons) == 0) {
    stop("`horizons` must be a non-empty list.", call. = FALSE)
  }

  if (!all(vapply(horizons, inherits, logical(1), what = "soil_horizon"))) {
    stop("Every element in `horizons` must be a `soil_horizon`.", call. = FALSE)
  }

  if (!is.list(classification)) {
    stop("`classification` must be a list.", call. = FALSE)
  }

  if (!is.list(metadata) || (length(metadata) > 0 && is.null(names(metadata)))) {
    stop("`metadata` must be a named list.", call. = FALSE)
  }

  profile <- list(
    schema_version = "0.1.0",
    site_id = site_id,
    classification = list(
      system = validate_required_string(
        if (is.null(classification$system)) "Soil Taxonomy" else classification$system,
        "classification$system"
      ),
      taxon = validate_optional_string(classification$taxon, "classification$taxon")
    ),
    metadata = metadata,
    horizons = horizons
  )

  class(profile) <- c("soil_profile", "list")
  validate_soil_profile(profile)
}

#' Validate a soil profile
#'
#' Checks that the profile has valid horizons with correct depth ordering,
#' no overlapping layers, and each horizon's `bottom` is greater than its `top`.
#'
#' @param profile A `soil_profile` object.
#'
#' @return The input profile, invisibly.
#' @export
#' @examples
#' h1 <- new_soil_horizon(0, 18, label = "Ap")
#' h2 <- new_soil_horizon(18, 52, label = "Bt1")
#' profile <- new_soil_profile("test", list(h1, h2))
#' validate_soil_profile(profile)
validate_soil_profile <- function(profile) {
  if (!inherits(profile, "soil_profile")) {
    stop("`profile` must be a `soil_profile`.", call. = FALSE)
  }

  if (!is.list(profile$horizons) || length(profile$horizons) == 0) {
    stop("`profile$horizons` must be a non-empty list.", call. = FALSE)
  }

  tops <- vapply(profile$horizons, function(horizon) horizon$top, numeric(1))
  bottoms <- vapply(profile$horizons, function(horizon) horizon$bottom, numeric(1))

  if (is.unsorted(tops, strictly = FALSE)) {
    stop("Horizon top depths must be sorted from shallow to deep.", call. = FALSE)
  }

  if (any(bottoms <= tops)) {
    stop("Each horizon must have `bottom` greater than `top`.", call. = FALSE)
  }

  if (length(tops) > 1 && any(tops[-1] < bottoms[-length(bottoms)])) {
    stop("Horizons cannot overlap.", call. = FALSE)
  }

  invisible(profile)
}

validate_depth_value <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1 || is.na(value)) {
    stop(sprintf("`%s` must be a single numeric value.", name), call. = FALSE)
  }

  as.numeric(value)
}

validate_required_string <- function(value, name) {
  value <- validate_optional_string(value, name)

  if (is.null(value)) {
    stop(sprintf("`%s` must be a non-empty string.", name), call. = FALSE)
  }

  value
}

validate_optional_string <- function(value, name) {
  if (is.null(value)) {
    return(NULL)
  }

  if (!is.character(value) || length(value) != 1 || is.na(value)) {
    stop(sprintf("`%s` must be a single string or `NULL`.", name), call. = FALSE)
  }

  value <- trimws(value)
  if (!nzchar(value)) {
    stop(sprintf("`%s` must be a non-empty string when provided.", name), call. = FALSE)
  }

  value
}

validate_optional_number <- function(value, name, min = -Inf, max = Inf) {
  if (is.null(value)) {
    return(NULL)
  }

  if (!is.numeric(value) || length(value) != 1 || is.na(value)) {
    stop(sprintf("`%s` must be a single numeric value or `NULL`.", name), call. = FALSE)
  }

  if (value < min || value > max) {
    stop(sprintf("`%s` must be between %s and %s.", name, min, max), call. = FALSE)
  }

  as.numeric(value)
}
