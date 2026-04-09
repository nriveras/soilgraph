test_that("plot_soil_profile returns ggplot", {
  h1 <- new_soil_horizon(0, 18, label = "Ap", color = "#5C4033")
  h2 <- new_soil_horizon(18, 52, label = "Bt1", color = "#8A5A44")
  p <- new_soil_profile("test", list(h1, h2))
  expect_s3_class(plot_soil_profile(p), "ggplot")
})

test_that("plot_soil_profile_fragments returns ggplot", {
  h1 <- new_soil_horizon(0, 18,
    label = "Ap", color = "#5C4033",
    coarse_abundance = "few", coarse_type = "gravel",
    coarse_grade = "weak", coarse_size = "fine"
  )
  h2 <- new_soil_horizon(18, 52,
    label = "Bt1", color = "#8A5A44",
    coarse_abundance = "common", coarse_type = "cobble",
    coarse_grade = "moderate", coarse_size = "medium"
  )
  p <- new_soil_profile("test", list(h1, h2))
  expect_s3_class(plot_soil_profile_fragments(p, seed = 1), "ggplot")
})

test_that("plot_soil_profile_fragments uses polygon horizons", {
  h1 <- new_soil_horizon(0, 18,
    label = "Ap", color = "#5C4033",
    boundary_shape = "wavy", boundary_grade = "clear"
  )
  h2 <- new_soil_horizon(18, 52,
    label = "Bt1", color = "#8A5A44"
  )
  p <- new_soil_profile("test-poly", list(h1, h2))

  layer_classes <- vapply(
    plot_soil_profile_fragments(p, seed = 1)$layers,
    function(layer) class(layer$geom)[1],
    character(1)
  )

  expect_true("GeomPolygon" %in% layer_classes)
})

test_that("plot_soil_description emits deprecation warning", {
  notes <- data.frame(
    Depth = c("0-18 cm", "18-52 cm"),
    description = c(
      "Ap dark brown silt loam moist clear smooth",
      "Bt1 reddish brown clay loam gradual wavy"
    )
  )
  expect_warning(
    plot_soil_description(notes, site_id = "test"),
    "deprecated"
  )
})

test_that("plot_soil_description_fragments emits deprecation warning", {
  notes <- data.frame(
    Depth = c("0-18 cm", "18-52 cm"),
    description = c(
      "Ap dark brown silt loam moist clear smooth few subangular weak fragments",
      "Bt1 reddish brown clay loam gradual wavy common rounded moderate fragments"
    )
  )
  expect_warning(
    plot_soil_description_fragments(notes, site_id = "test", seed = 1),
    "deprecated"
  )
})

test_that("single-horizon profile plots without error", {
  h <- new_soil_horizon(0, 30, label = "A", color = "#5C4033")
  p <- new_soil_profile("single", list(h))
  expect_s3_class(plot_soil_profile(p), "ggplot")
  suppressWarnings(expect_s3_class(
    plot_soil_profile_advanced(p, seed = 1), "ggplot"
  ))
})

test_that("plot_soil_profile_advanced uses polygon horizons", {
  h1 <- new_soil_horizon(0, 20,
    label = "A", color = "#5C4033",
    boundary_shape = "wavy", boundary_grade = "gradual"
  )
  h2 <- new_soil_horizon(20, 50,
    label = "B", color = "#8A5A44"
  )
  p <- new_soil_profile("test-advanced-poly", list(h1, h2))

  layer_classes <- vapply(
    plot_soil_profile_advanced(p, seed = 1)$layers,
    function(layer) class(layer$geom)[1],
    character(1)
  )

  expect_true("GeomPolygon" %in% layer_classes)
})

test_that("profile with no coarse fragments renders in fragment mode", {
  h1 <- new_soil_horizon(0, 20, label = "A", color = "#5C4033")
  h2 <- new_soil_horizon(20, 50, label = "B", color = "#8A5A44")
  p <- new_soil_profile("no-frags", list(h1, h2))
  expect_s3_class(plot_soil_profile_fragments(p, seed = 1), "ggplot")
})

test_that("validate_soil_profile returns profile invisibly for valid input", {
  h <- new_soil_horizon(0, 20, label = "A")
  p <- new_soil_profile("test", list(h))
  result <- validate_soil_profile(p)
  expect_s3_class(result, "soil_profile")
})

test_that("validate_soil_profile errors on non-profile input", {
  expect_error(validate_soil_profile(list(not = "a profile")), "soil_profile")
})

test_that("theme_soil_profile returns a ggplot theme", {
  th <- theme_soil_profile()
  expect_s3_class(th, "theme")
})

test_that("theme_soil_profile with grid option", {
  th_grid <- theme_soil_profile(show_grid = TRUE)
  th_no_grid <- theme_soil_profile(show_grid = FALSE)
  expect_s3_class(th_grid, "theme")
  expect_s3_class(th_no_grid, "theme")
})

test_that("get_horizon_palette returns correct count", {
  colors <- get_horizon_palette(5)
  expect_length(colors, 5)
  expect_type(colors, "character")
})

test_that("get_contrasting_text_color returns dark for light backgrounds", {
  expect_equal(get_contrasting_text_color("#FFFFFF"), "#000000")
})

test_that("get_contrasting_text_color returns light for dark backgrounds", {
  expect_equal(get_contrasting_text_color("#000000"), "#FFFFFF")
})

test_that("describe_soil_profile returns character string", {
  h1 <- new_soil_horizon(0, 20, label = "A")
  h2 <- new_soil_horizon(20, 50, label = "B")
  p <- new_soil_profile("test-desc", list(h1, h2))
  desc <- describe_soil_profile(p)
  expect_type(desc, "character")
  expect_true(grepl("test-desc", desc))
  expect_true(grepl("2 horizons", desc))
})

test_that("build_horizon_plot_data returns expected columns", {
  h1 <- new_soil_horizon(0, 20,
    label = "A", color = "#5C4033",
    boundary_grade = "clear", boundary_shape = "smooth",
    coarse_abundance = "few", coarse_type = "gravel"
  )
  p <- new_soil_profile("test", list(h1))
  hd <- build_horizon_plot_data(p)
  expect_s3_class(hd, "data.frame")
  expected_cols <- c(
    "horizon_index", "label", "top", "bottom", "fill",
    "midpoint", "boundary_shape", "boundary_grade",
    "coarse_abundance", "coarse_type"
  )
  for (col in expected_cols) {
    expect_true(col %in% names(hd), info = paste("missing column:", col))
  }
})

test_that("create_fragment_encoding returns list with mappings", {
  enc <- create_fragment_encoding(data.frame())
  expect_type(enc, "list")
  expect_true("size_mapping" %in% names(enc))
  expect_true("grade_mapping" %in% names(enc))
  expect_true("abundance_mapping" %in% names(enc))
  expect_true("type_shapes" %in% names(enc))
})

test_that("create_boundary_encoding returns correct structure", {
  enc <- create_boundary_encoding("gradual", "wavy")
  expect_type(enc, "list")
  expect_equal(enc$grade, "gradual")
  expect_equal(enc$shape, "wavy")
  expect_equal(enc$linetype, "dashed")
  expect_true(enc$distortion_level > 0)
})
