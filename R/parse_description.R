# nolint start: object_usage_linter.
#' Derive horizons from a two-column field description table
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `derive_soil_horizons()` is deprecated because the free-text parser is
#' fragile and redundant when structured input is available. Use
#' [soil_profile_from_table()] with a structured data frame containing explicit
#' columns (`Top`, `Bottom`, `Texture`, `Color`, etc.) instead. See
#' `vignette("getting-started")` for migration examples.
#'
#' @param data A data frame with `Depth` and `description` columns.
#' @param profile_bottom Optional terminal depth in centimeters. Required when
#'   `Depth` contains top depths rather than depth ranges.
#'
#' @return A data frame with derived `Horizon`, `Top`, `Bottom`, `Texture`,
#'   `Moisture`, `Color`, `BoundaryGrade`, `BoundaryShape`,
#'   `CoarseAbundance`, `CoarseShape`, `CoarseGrade`, `CoarseType`,
#'   `CoarseSize`, `CoarseColor`, `CoarsePercent`, and `Notes` columns.
#' @export
derive_soil_horizons <- function(data, profile_bottom = NULL) {
  .Deprecated(
    "soil_profile_from_table",
    package = "soilgraph",
    msg = paste(
      "`derive_soil_horizons()` is deprecated.",
      "Use `soil_profile_from_table()` with a structured data frame instead.",
      "See `vignette('getting-started')` for migration examples."
    )
  )
  table_data <- validate_description_table(data)
  parsed_depths <- parse_depth_column(table_data$Depth, profile_bottom = profile_bottom)

  derived_rows <- lapply(seq_len(nrow(table_data)), function(index) {
    parsed_description <- parse_description_fields(table_data$description[[index]])

    data.frame(
      Depth = table_data$Depth[[index]],
      description = table_data$description[[index]],
      Horizon = parsed_description$label %||% paste0("H", index),
      Top = parsed_depths$top[[index]],
      Bottom = parsed_depths$bottom[[index]],
      Texture = parsed_description$texture %||% NA_character_,
      Moisture = parsed_description$moisture %||% NA_character_,
      Color = parsed_description$color %||% NA_character_,
      BoundaryGrade = parsed_description$boundary_grade %||% NA_character_,
      BoundaryShape = parsed_description$boundary_shape %||% NA_character_,
      CoarseAbundance = parsed_description$coarse_abundance %||% NA_character_,
      CoarseShape = parsed_description$coarse_shape %||% NA_character_,
      CoarseGrade = parsed_description$coarse_grade %||% NA_character_,
      CoarseType = parsed_description$coarse_type %||% NA_character_,
      CoarseSize = parsed_description$coarse_size %||% NA_character_,
      CoarseColor = parsed_description$coarse_color %||% NA_character_,
      CoarsePercent = parsed_description$coarse_percent %||% NA_real_,
      Notes = parsed_description$notes %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, derived_rows)
}

#' Build a soil profile from a tabular description
#'
#' Converts a data frame of horizon properties into a `soil_profile` object.
#' The primary workflow uses a **structured table** whose columns correspond
#' directly to soil properties (`Top`, `Bottom`, `Texture`, `Color`, etc.).
#'
#' A legacy pathway is maintained for data frames that contain only `Depth` and
#' `description` columns (the free-text parser workflow). This pathway emits a
#' deprecation warning and will be removed in a future release.
#'
#' @param data A data frame. Preferred: structured columns such as `Top`,
#'   `Bottom`, `Horizon`, `Texture`, `Color`, `Moisture`, `BoundaryGrade`,
#'   `BoundaryShape`, `CoarseAbundance`, `CoarseShape`, `CoarseGrade`,
#'   `CoarseType`, `CoarseSize`, `CoarseColor`, `CoarsePercent`, `Notes`.
#'   Legacy: `Depth` and `description` columns only.
#' @param site_id Profile identifier. Defaults to `"soil-profile"`.
#' @param profile_bottom Optional terminal depth in centimeters. Required when
#'   using the legacy `Depth`/`description` format with top depths only.
#' @param classification A named list describing the classification system and taxon.
#' @param metadata A named list with arbitrary profile metadata.
#'
#' @return A `soil_profile` object.
#' @export
#' @examples
#' # Structured table workflow (preferred)
#' horizons_df <- data.frame(
#'   Top = c(0, 18, 52),
#'   Bottom = c(18, 52, 95),
#'   Horizon = c("Ap", "Bt1", "Bt2"),
#'   Texture = c("silt loam", "clay loam", "clay"),
#'   Color = c("#5C4033", "#8A5A44", "#A66A4C"),
#'   BoundaryGrade = c("clear", "gradual", "diffuse"),
#'   BoundaryShape = c("smooth", "wavy", "irregular"),
#'   stringsAsFactors = FALSE
#' )
#' profile <- soil_profile_from_table(horizons_df, site_id = "pedon-001")
soil_profile_from_table <- function(
    data,
    site_id = "soil-profile",
    profile_bottom = NULL,
    classification = list(system = "Field description", taxon = NULL),
    metadata = list()) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  cols <- tolower(trimws(names(data)))
  is_structured <- all(c("top", "bottom") %in% cols)
  is_legacy <- all(c("depth", "description") %in% cols) && !is_structured

  if (is_legacy) {
    .Deprecated(
      msg = paste(
        "Passing a Depth/description table to `soil_profile_from_table()` is deprecated.",
        "Provide a structured data frame with explicit columns",
        "(Top, Bottom, Horizon, Texture, Color, ...) instead.",
        "See `vignette('getting-started')` for migration examples."
      )
    )
    derived <- derive_soil_horizons_internal(data, profile_bottom = profile_bottom)
    return(build_profile_from_derived(derived, site_id, classification, metadata))
  }

  if (!is_structured) {
    stop(
      paste(
        "`data` must contain `Top` and `Bottom` columns (structured format),",
        "or `Depth` and `description` columns (legacy format)."
      ),
      call. = FALSE
    )
  }

  build_profile_from_structured(data, site_id, classification, metadata)
}

validate_description_table <- function(data) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  names_normalized <- tolower(trimws(names(data)))
  required_columns <- c("depth", "description")

  if (!all(required_columns %in% names_normalized)) {
    stop("`data` must contain `Depth` and `description` columns.", call. = FALSE)
  }

  depth_index <- match("depth", names_normalized)
  description_index <- match("description", names_normalized)

  table_data <- data.frame(
    Depth = as.character(data[[depth_index]]),
    description = as.character(data[[description_index]]),
    stringsAsFactors = FALSE
  )

  if (nrow(table_data) == 0) {
    stop("`data` must contain at least one row.", call. = FALSE)
  }

  if (any(is.na(table_data$Depth)) || any(!nzchar(trimws(table_data$Depth)))) {
    stop("`Depth` values must be non-empty.", call. = FALSE)
  }

  if (any(is.na(table_data$description)) || any(!nzchar(trimws(table_data$description)))) {
    stop("`description` values must be non-empty.", call. = FALSE)
  }

  table_data
}

# Internal (non-deprecated) parser entry point for the legacy pathway
derive_soil_horizons_internal <- function(data, profile_bottom = NULL) {
  table_data <- validate_description_table(data)
  parsed_depths <- parse_depth_column(table_data$Depth, profile_bottom = profile_bottom)

  derived_rows <- lapply(seq_len(nrow(table_data)), function(index) {
    parsed_description <- parse_description_fields(table_data$description[[index]])

    data.frame(
      Depth = table_data$Depth[[index]],
      description = table_data$description[[index]],
      Horizon = parsed_description$label %||% paste0("H", index),
      Top = parsed_depths$top[[index]],
      Bottom = parsed_depths$bottom[[index]],
      Texture = parsed_description$texture %||% NA_character_,
      Moisture = parsed_description$moisture %||% NA_character_,
      Color = parsed_description$color %||% NA_character_,
      BoundaryGrade = parsed_description$boundary_grade %||% NA_character_,
      BoundaryShape = parsed_description$boundary_shape %||% NA_character_,
      CoarseAbundance = parsed_description$coarse_abundance %||% NA_character_,
      CoarseShape = parsed_description$coarse_shape %||% NA_character_,
      CoarseGrade = parsed_description$coarse_grade %||% NA_character_,
      CoarseType = parsed_description$coarse_type %||% NA_character_,
      CoarseSize = parsed_description$coarse_size %||% NA_character_,
      CoarseColor = parsed_description$coarse_color %||% NA_character_,
      CoarsePercent = parsed_description$coarse_percent %||% NA_real_,
      Notes = parsed_description$notes %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, derived_rows)
}

build_profile_from_derived <- function(derived, site_id, classification, metadata) {
  horizons <- lapply(seq_len(nrow(derived)), function(index) {
    new_soil_horizon(
      top = derived$Top[[index]],
      bottom = derived$Bottom[[index]],
      label = missing_to_null(derived$Horizon[[index]]),
      texture = missing_to_null(derived$Texture[[index]]),
      color = missing_to_null(derived$Color[[index]]),
      moisture = missing_to_null(derived$Moisture[[index]]),
      boundary_grade = missing_to_null(derived$BoundaryGrade[[index]]),
      boundary_shape = missing_to_null(derived$BoundaryShape[[index]]),
      coarse_abundance = missing_to_null(derived$CoarseAbundance[[index]]),
      coarse_shape = missing_to_null(derived$CoarseShape[[index]]),
      coarse_grade = missing_to_null(derived$CoarseGrade[[index]]),
      coarse_type = missing_to_null(derived$CoarseType[[index]]),
      coarse_size = missing_to_null(derived$CoarseSize[[index]]),
      coarse_color = missing_to_null(derived$CoarseColor[[index]]),
      coarse_percent = missing_to_null_number(derived$CoarsePercent[[index]]),
      notes = missing_to_null(derived$Notes[[index]])
    )
  })

  new_soil_profile(
    site_id = site_id,
    horizons = horizons,
    classification = classification,
    metadata = metadata
  )
}

build_profile_from_structured <- function(data, site_id, classification, metadata) {
  cols <- tolower(trimws(names(data)))

  col_index <- function(name) {
    idx <- match(name, cols)
    if (is.na(idx)) NULL else idx
  }

  top_idx <- col_index("top")
  bottom_idx <- col_index("bottom")

  if (nrow(data) == 0) {
    stop("`data` must contain at least one row.", call. = FALSE)
  }

  horizon_idx <- col_index("horizon") %||% col_index("label")
  texture_idx <- col_index("texture")
  color_idx <- col_index("color")
  moisture_idx <- col_index("moisture")
  boundary_grade_idx <- col_index("boundarygrade") %||% col_index("boundary_grade")
  boundary_shape_idx <- col_index("boundaryshape") %||% col_index("boundary_shape")
  coarse_abundance_idx <- col_index("coarseabundance") %||% col_index("coarse_abundance")
  coarse_shape_idx <- col_index("coarseshape") %||% col_index("coarse_shape")
  coarse_grade_idx <- col_index("coarsegrade") %||% col_index("coarse_grade")
  coarse_type_idx <- col_index("coarsetype") %||% col_index("coarse_type")
  coarse_size_idx <- col_index("coarsesize") %||% col_index("coarse_size")
  coarse_color_idx <- col_index("coarsecolor") %||% col_index("coarse_color")
  coarse_percent_idx <- col_index("coarsepercent") %||% col_index("coarse_percent")
  notes_idx <- col_index("notes")

  get_val <- function(row, idx) {
    if (is.null(idx)) {
      return(NULL)
    }
    val <- data[[idx]][[row]]
    if (is.na(val) || (is.character(val) && !nzchar(trimws(val)))) NULL else val
  }

  get_num <- function(row, idx) {
    if (is.null(idx)) {
      return(NULL)
    }
    val <- data[[idx]][[row]]
    if (is.na(val)) NULL else as.numeric(val)
  }

  horizons <- lapply(seq_len(nrow(data)), function(index) {
    new_soil_horizon(
      top = as.numeric(data[[top_idx]][[index]]),
      bottom = as.numeric(data[[bottom_idx]][[index]]),
      label = get_val(index, horizon_idx),
      texture = get_val(index, texture_idx),
      color = get_val(index, color_idx),
      moisture = get_val(index, moisture_idx),
      boundary_grade = get_val(index, boundary_grade_idx),
      boundary_shape = get_val(index, boundary_shape_idx),
      coarse_abundance = get_val(index, coarse_abundance_idx),
      coarse_shape = get_val(index, coarse_shape_idx),
      coarse_grade = get_val(index, coarse_grade_idx),
      coarse_type = get_val(index, coarse_type_idx),
      coarse_size = get_val(index, coarse_size_idx),
      coarse_color = get_val(index, coarse_color_idx),
      coarse_percent = get_num(index, coarse_percent_idx),
      notes = get_val(index, notes_idx)
    )
  })

  new_soil_profile(
    site_id = site_id,
    horizons = horizons,
    classification = classification,
    metadata = metadata
  )
}

parse_depth_column <- function(depth_values, profile_bottom = NULL) {
  depth_mode <- detect_depth_mode(depth_values)

  if (identical(depth_mode, "range")) {
    parsed_ranges <- lapply(depth_values, parse_depth_range)

    return(list(
      top = vapply(parsed_ranges, function(value) value[[1]], numeric(1)),
      bottom = vapply(parsed_ranges, function(value) value[[2]], numeric(1))
    ))
  }

  top_depths <- vapply(depth_values, parse_single_depth, numeric(1))
  profile_bottom <- validate_profile_bottom(profile_bottom)

  if (profile_bottom <= top_depths[[length(top_depths)]]) {
    stop("`profile_bottom` must be greater than the last top depth.", call. = FALSE)
  }

  list(
    top = top_depths,
    bottom = c(top_depths[-1], profile_bottom)
  )
}

detect_depth_mode <- function(depth_values) {
  has_range <- vapply(depth_values, is_depth_range, logical(1))

  if (all(has_range)) {
    return("range")
  }

  if (!any(has_range)) {
    return("top")
  }

  stop("`Depth` must use either only ranges or only top depths.", call. = FALSE)
}

is_depth_range <- function(value) {
  grepl(
    "^\\s*[0-9]+(?:\\.[0-9]+)?\\s*(?:-|to)\\s*[0-9]+(?:\\.[0-9]+)?\\s*(?:cm)?\\s*$",
    value,
    ignore.case = TRUE,
    perl = TRUE
  )
}

parse_depth_range <- function(value) {
  matches <- regmatches(
    value,
    regexec(
      "^\\s*([0-9]+(?:\\.[0-9]+)?)\\s*(?:-|to)\\s*([0-9]+(?:\\.[0-9]+)?)\\s*(?:cm)?\\s*$",
      value,
      ignore.case = TRUE,
      perl = TRUE
    )
  )[[1]]

  if (length(matches) != 3) {
    stop(sprintf("Invalid depth range: `%s`.", value), call. = FALSE)
  }

  top <- as.numeric(matches[[2]])
  bottom <- as.numeric(matches[[3]])

  if (bottom <= top) {
    stop(sprintf("Depth range `%s` must have a lower boundary greater than the upper boundary.", value), call. = FALSE)
  }

  c(top, bottom)
}

parse_single_depth <- function(value) {
  matches <- regmatches(
    value,
    regexec(
      "^\\s*([0-9]+(?:\\.[0-9]+)?)\\s*(?:cm)?\\s*$",
      value,
      ignore.case = TRUE,
      perl = TRUE
    )
  )[[1]]

  if (length(matches) != 2) {
    stop(sprintf("Invalid top depth: `%s`.", value), call. = FALSE)
  }

  as.numeric(matches[[2]])
}

validate_profile_bottom <- function(profile_bottom) {
  if (is.null(profile_bottom)) {
    stop("`profile_bottom` is required when `Depth` contains top depths only.", call. = FALSE)
  }

  validate_depth_value(profile_bottom, "profile_bottom")
}

parse_description_fields <- function(description) {
  label_match <- extract_horizon_label(description)
  texture_match <- extract_dictionary_match(description, texture_dictionary())
  moisture_match <- extract_dictionary_match(description, moisture_dictionary())
  color_match <- extract_color(description)
  boundary_grade_match <- extract_dictionary_match(description, boundary_grade_dictionary())
  boundary_shape_match <- extract_dictionary_match(description, boundary_shape_dictionary())
  coarse_abundance_match <- extract_dictionary_match(description, coarse_abundance_dictionary())
  coarse_shape_match <- extract_dictionary_match(description, coarse_shape_dictionary())
  coarse_grade_match <- extract_dictionary_match(description, coarse_grade_dictionary())
  coarse_type_match <- extract_dictionary_match(description, coarse_type_dictionary())
  coarse_size_match <- extract_dictionary_match(description, coarse_size_dictionary())
  coarse_color_match <- extract_coarse_color(description)
  coarse_percent_match <- extract_coarse_percent(description)

  notes <- description
  notes <- remove_match(notes, label_match$raw)
  notes <- remove_match(notes, texture_match$raw)
  notes <- remove_match(notes, moisture_match$raw)
  notes <- remove_match(notes, color_match$raw)
  notes <- remove_match(notes, boundary_grade_match$raw)
  notes <- remove_match(notes, boundary_shape_match$raw)
  notes <- remove_match(notes, coarse_abundance_match$raw)
  notes <- remove_match(notes, coarse_shape_match$raw)
  notes <- remove_match(notes, coarse_grade_match$raw)
  notes <- remove_match(notes, coarse_type_match$raw)
  notes <- remove_match(notes, coarse_size_match$raw)
  notes <- remove_match(notes, coarse_color_match$raw)
  notes <- remove_match(notes, coarse_percent_match$raw)
  notes <- clean_notes(notes)

  list(
    label = label_match$value,
    texture = texture_match$value,
    moisture = moisture_match$value,
    color = color_match$value,
    boundary_grade = boundary_grade_match$value,
    boundary_shape = boundary_shape_match$value,
    coarse_abundance = coarse_abundance_match$value,
    coarse_shape = coarse_shape_match$value,
    coarse_grade = coarse_grade_match$value,
    coarse_type = coarse_type_match$value,
    coarse_size = coarse_size_match$value,
    coarse_color = coarse_color_match$value,
    coarse_percent = coarse_percent_match$value,
    notes = notes
  )
}

extract_horizon_label <- function(description) {
  pattern <- "\\b([0-9]?(?:AB|BA|BE|EB|BC|CB|A|B|C|E|O|R)(?:[a-z]{0,3})[0-9]{0,2})\\b"
  matches <- regmatches(
    description,
    regexpr(pattern, description, ignore.case = TRUE, perl = TRUE)
  )

  if (!length(matches) || identical(matches[[1]], "")) {
    return(list(raw = NULL, value = NULL))
  }

  list(raw = matches[[1]], value = normalize_horizon_label(matches[[1]]))
}

normalize_horizon_label <- function(label) {
  matches <- regmatches(
    label,
    regexec("^([0-9]?)([A-Za-z]+)([0-9]{0,2})$", label, perl = TRUE)
  )[[1]]

  if (length(matches) != 4) {
    return(label)
  }

  prefix <- matches[[2]]
  alpha <- tolower(matches[[3]])
  suffix <- matches[[4]]
  uppercase_pairs <- c("ab", "ba", "be", "eb", "bc", "cb")

  normalized_alpha <- if (substr(alpha, 1, 2) %in% uppercase_pairs) {
    paste0(toupper(substr(alpha, 1, 2)), substr(alpha, 3, nchar(alpha)))
  } else {
    paste0(toupper(substr(alpha, 1, 1)), substr(alpha, 2, nchar(alpha)))
  }

  paste0(prefix, normalized_alpha, suffix)
}

extract_dictionary_match <- function(description, dictionary) {
  lowered <- tolower(description)
  keys <- names(dictionary)
  keys <- keys[order(nchar(keys), decreasing = TRUE)]

  for (key in keys) {
    if (grepl(paste0("\\b", key, "\\b"), lowered, perl = TRUE)) {
      return(list(raw = key, value = unname(dictionary[[key]])))
    }
  }

  list(raw = NULL, value = NULL)
}

extract_color <- function(description) {
  hex_match <- regmatches(
    description,
    regexpr("#(?:[0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})\\b", description, perl = TRUE)
  )

  if (length(hex_match) && !identical(hex_match[[1]], "")) {
    return(list(raw = hex_match[[1]], value = hex_match[[1]]))
  }

  color_match <- extract_dictionary_match(description, color_dictionary())
  if (!is.null(color_match$value)) {
    return(color_match)
  }

  list(raw = NULL, value = NULL)
}

texture_dictionary <- function() {
  c(
    "silty clay loam" = "silty clay loam",
    "sandy clay loam" = "sandy clay loam",
    "sandy loam" = "sandy loam",
    "silty loam" = "silty loam",
    "silt loam" = "silt loam",
    "clay loam" = "clay loam",
    "silty clay" = "silty clay",
    "sandy clay" = "sandy clay",
    "loamy sand" = "loamy sand",
    "sand" = "sand",
    "silt" = "silt",
    "clay" = "clay",
    "loam" = "loam"
  )
}

moisture_dictionary <- function() {
  c(
    "very dry" = "very dry",
    "slightly moist" = "slightly moist",
    "very moist" = "very moist",
    "saturated" = "saturated",
    "moist" = "moist",
    "dry" = "dry",
    "wet" = "wet"
  )
}

color_dictionary <- function() {
  c(
    "very dark brown" = "#3B2A1F",
    "dark grayish brown" = "#4F453D",
    "reddish brown" = "#7B3F2A",
    "yellowish brown" = "#9C6B30",
    "grayish brown" = "#6B5B4D",
    "dark brown" = "#5C4033",
    "light brown" = "#A67C52",
    "dark gray" = "#4A4A4A",
    "olive" = "#708238",
    "brown" = "#8B5A2B",
    "black" = "#2E2E2E",
    "gray" = "#808080",
    "grey" = "#808080",
    "red" = "#A63A2B"
  )
}

boundary_grade_dictionary <- function() {
  c(
    "very abrupt" = "very abrupt",
    "abrupt" = "abrupt",
    "clear" = "clear",
    "gradual" = "gradual",
    "diffuse" = "diffuse"
  )
}

boundary_shape_dictionary <- function() {
  c(
    "very irregular" = "very irregular",
    "discontinuous" = "discontinuous",
    "irregular" = "irregular",
    "broken" = "broken",
    "wavy" = "wavy",
    "smooth" = "smooth"
  )
}

coarse_abundance_dictionary <- function() {
  c(
    "very few" = "very few",
    "few" = "few",
    "common" = "common",
    "many" = "many",
    "abundant" = "abundant"
  )
}

coarse_shape_dictionary <- function() {
  c(
    "subrounded" = "subrounded",
    "subangular" = "subangular",
    "angular" = "angular",
    "rounded" = "rounded",
    "platy" = "platy",
    "flat" = "flat"
  )
}

coarse_grade_dictionary <- function() {
  c(
    "very weak" = "very weak",
    "weak" = "weak",
    "moderate" = "moderate",
    "strong" = "strong",
    "very strong" = "very strong"
  )
}

coarse_type_dictionary <- function() {
  c(
    "flagstone" = "flagstone",
    "boulder" = "boulder",
    "channer" = "channer",
    "cobble" = "cobble",
    "gravel" = "gravel",
    "stone" = "stone"
  )
}

coarse_size_dictionary <- function() {
  c(
    "very coarse" = "very coarse",
    "very fine" = "very fine",
    "coarse" = "coarse",
    "medium" = "medium",
    "small" = "small",
    "large" = "large",
    "fine" = "fine"
  )
}

extract_coarse_color <- function(description) {
  type_pattern <- "gravel|cobble|stone|boulder|channer|flagstone|fragments?"
  color_keys <- names(color_dictionary())
  color_keys <- color_keys[order(nchar(color_keys), decreasing = TRUE)]

  for (key in color_keys) {
    pattern <- paste0("\\b", key, "\\s+(?:", type_pattern, ")\\b")
    if (grepl(pattern, tolower(description), perl = TRUE)) {
      return(list(raw = key, value = unname(color_dictionary()[[key]])))
    }
  }

  list(raw = NULL, value = NULL)
}

extract_coarse_percent <- function(description) {
  matches <- regmatches(
    description,
    regexec("\\b([0-9]{1,3})\\s*%", description, perl = TRUE)
  )[[1]]

  if (length(matches) != 2) {
    return(list(raw = NULL, value = NULL))
  }

  value <- as.numeric(matches[[2]])
  if (is.na(value) || value < 0 || value > 100) {
    return(list(raw = NULL, value = NULL))
  }

  list(raw = matches[[1]], value = value)
}

remove_match <- function(text, match) {
  if (is.null(match)) {
    return(text)
  }

  escaped <- escape_regex(match)

  if (grepl("^[[:alnum:] ]+$", match)) {
    pattern <- paste0("\\b", escaped, "\\b")
  } else {
    pattern <- escaped
  }

  gsub(pattern, " ", text, ignore.case = TRUE, perl = TRUE)
}

escape_regex <- function(value) {
  gsub("([][{}()+*^$|\\?.])", "\\\\\\1", value, perl = TRUE)
}

clean_notes <- function(value) {
  value <- gsub("[,;:/()-]", " ", value)
  value <- gsub("\\s+", " ", value, perl = TRUE)
  value <- trimws(value)

  if (!nzchar(value)) {
    return(NULL)
  }

  value
}

missing_to_null <- function(value) {
  if (length(value) == 0 || is.na(value) || !nzchar(trimws(value))) {
    return(NULL)
  }

  value
}

missing_to_null_number <- function(value) {
  if (length(value) == 0 || is.na(value)) {
    return(NULL)
  }

  as.numeric(value)
}

# nolint end
