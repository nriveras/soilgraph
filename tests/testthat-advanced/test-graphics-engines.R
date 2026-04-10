test_that("generate_fragment_shape creates valid polygon", {
  shape <- generate_fragment_shape(
    center_x = 0.5,
    center_y = 30,
    size = 2.0,
    fragment_type = "gravel",
    seed = 42
  )

  expect_true(is.data.frame(shape))
  expect_identical(nrow(shape), 7L) # 6 vertices + closing point
  expect_true(all(c("x", "y") %in% names(shape)))

  # First and last points should match (closed polygon)
  expect_true(abs(shape$x[1] - shape$x[nrow(shape)]) < 1e-10)
  expect_true(abs(shape$y[1] - shape$y[nrow(shape)]) < 1e-10)

  # Points should be near center
  mean_x <- mean(shape$x[-nrow(shape)])
  mean_y <- mean(shape$y[-nrow(shape)])

  expect_true(abs(mean_x - 0.5) < 1.0)
  expect_true(abs(mean_y - 30) < 1.0)
})

test_that("generate_fragment_shape respects fragment types", {
  types <- c("gravel", "cobble", "stone", "boulder", "channer", "flagstone")

  for (type in types) {
    shape <- generate_fragment_shape(
      center_x = 0.5,
      center_y = 30,
      size = 2.0,
      fragment_type = type,
      seed = 42
    )

    expect_true(is.data.frame(shape))
    expect_true(nrow(shape) > 0)
  }
})

test_that("generate_boundary_path creates smooth boundary", {
  path <- generate_boundary_path(
    depth_cm = 50,
    boundary_shape = "smooth",
    boundary_grade = "clear",
    seed = 42,
    boundary_id = "test_boundary"
  )

  expect_true(is.data.frame(path))
  expect_true(all(c("x", "y", "boundary_id", "boundary_shape", "boundary_grade") %in% names(path)))
  expect_identical(nrow(path), 200L)
  expect_true(all(path$boundary_id == "test_boundary"))
  expect_true(all(path$boundary_shape == "smooth"))

  # All points should be near depth value
  expect_true(max(abs(path$y - 50)) < 0.1)
})

test_that("generate_boundary_path creates wavy boundary", {
  path <- generate_boundary_path(
    depth_cm = 50,
    boundary_shape = "wavy",
    boundary_grade = "clear",
    seed = 42,
    boundary_id = "test_boundary"
  )

  expect_true(is.data.frame(path))
  expect_true(nrow(path) > 0)

  # Wavy boundary should have variation in y
  y_range <- max(path$y) - min(path$y)
  expect_true(y_range > 0.5)
})

test_that("generate_boundary_path respects grade", {
  grades <- c("abrupt", "clear", "gradual", "diffuse")

  for (grade in grades) {
    path <- generate_boundary_path(
      depth_cm = 50,
      boundary_shape = "irregular",
      boundary_grade = grade,
      seed = 42,
      boundary_id = paste0("test_", grade)
    )

    expect_true(is.data.frame(path))
    expect_true(nrow(path) > 0)
  }
})

test_that("build_fragment_polygons generates complete layout", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        color = "#8B7355",
        coarse_abundance = "common",
        coarse_type = "gravel",
        coarse_grade = "moderate"
      ),
      new_soil_horizon(
        top = 20,
        bottom = 50,
        label = "B",
        color = "#A0826D",
        coarse_abundance = "few",
        coarse_type = "cobble",
        coarse_grade = "weak"
      )
    )
  )

  fragments <- build_fragment_polygons(profile, seed = 42)

  expect_true(is.data.frame(fragments))
  expect_true(nrow(fragments) > 0)
  expect_true(all(c("x", "y", "fragment_id", "fragment_type", "grade", "alpha", "color") %in% names(fragments)))
})

test_that("build_boundary_paths generates boundary data", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        boundary_shape = "smooth",
        boundary_grade = "clear"
      ),
      new_soil_horizon(
        top = 20,
        bottom = 50,
        label = "B",
        boundary_shape = "wavy",
        boundary_grade = "clear"
      )
    )
  )

  horizon_data <- build_horizon_plot_data(profile)
  boundaries <- build_boundary_paths(horizon_data, seed = 42)

  expect_true(is.data.frame(boundaries))
  expect_true(nrow(boundaries) > 0)
  expect_true(all(c("boundary_id", "x", "y", "boundary_shape", "boundary_grade") %in% names(boundaries)))
})

test_that("build_horizon_polygons builds closed path-following polygons", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        color = "#8B7355",
        boundary_shape = "wavy",
        boundary_grade = "clear"
      ),
      new_soil_horizon(
        top = 20,
        bottom = 50,
        label = "B",
        color = "#A0826D"
      )
    )
  )

  horizon_data <- build_horizon_plot_data(profile)
  boundaries <- build_boundary_paths(horizon_data, seed = 42)
  polygons <- build_horizon_polygons(horizon_data, boundary_data = boundaries)

  expect_true(is.data.frame(polygons))
  expect_true(nrow(polygons) > 0)
  expect_true(all(c("x", "y", "fill", "polygon_id", "horizon_index") %in% names(polygons)))
  expect_identical(length(unique(polygons$polygon_id)), 2L)

  horizon_one <- polygons[polygons$polygon_id == "h1", ]
  expect_true(length(unique(horizon_one$y)) > 1)
})

test_that("build_boundary_transition_zones creates appropriate zones", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        boundary_grade = "gradual"
      ),
      new_soil_horizon(
        top = 20,
        bottom = 50,
        label = "B",
        boundary_grade = "diffuse"
      ),
      new_soil_horizon(
        top = 50,
        bottom = 80,
        label = "C",
        boundary_grade = "abrupt"
      )
    )
  )

  horizon_data <- build_horizon_plot_data(profile)
  zones <- build_boundary_transition_zones(horizon_data, seed = 42)

  expect_true(is.data.frame(zones))
  expect_true(nrow(zones) > 0)
  expect_identical(length(unique(zones$boundary_id)), 2L)
  expect_true(all(c("boundary_id", "x", "y", "zone_alpha", "zone_grade") %in% names(zones)))
})

test_that("plot_soil_profile_advanced renders without error", {
  profile <- new_soil_profile(
    site_id = "pedon-001",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 18,
        label = "Ap",
        texture = "silt loam",
        color = "#5C4033",
        boundary_grade = "clear",
        boundary_shape = "smooth",
        coarse_abundance = "few",
        coarse_grade = "weak"
      ),
      new_soil_horizon(
        top = 18,
        bottom = 52,
        label = "Bt1",
        texture = "clay loam",
        color = "#8A5A44",
        boundary_grade = "gradual",
        boundary_shape = "wavy",
        coarse_abundance = "common",
        coarse_grade = "moderate"
      )
    )
  )

  plot <- plot_soil_profile_advanced(profile, seed = 42)

  expect_s3_class(plot, "ggplot")
})

test_that("plot_soil_profile_advanced options work correctly", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        color = "#8B7355",
        coarse_abundance = "common"
      ),
      new_soil_horizon(
        top = 20,
        bottom = 50,
        label = "B",
        color = "#A0826D"
      )
    )
  )

  # Should work with all combinations
  p1 <- plot_soil_profile_advanced(profile, show_fragments = TRUE)
  expect_s3_class(p1, "ggplot")

  p2 <- plot_soil_profile_advanced(profile, show_boundaries = FALSE)
  expect_s3_class(p2, "ggplot")

  p3 <- plot_soil_profile_advanced(profile, show_transition_zones = FALSE)
  expect_s3_class(p3, "ggplot")

  p4 <- plot_soil_profile_advanced(
    profile,
    show_fragments = FALSE,
    show_boundaries = FALSE,
    show_transition_zones = FALSE
  )
  expect_s3_class(p4, "ggplot")
})

test_that("layer_coarse_fragments returns appropriate layers", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        coarse_abundance = "common"
      )
    )
  )

  fragments <- build_fragment_polygons(profile, seed = 42)
  layers <- layer_coarse_fragments(fragments)

  expect_true(is.list(layers))
  expect_true(length(layers) > 0)
})

test_that("layer_horizon_boundaries returns appropriate layers", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        boundary_shape = "wavy"
      ),
      new_soil_horizon(
        top = 20,
        bottom = 50,
        label = "B"
      )
    )
  )

  horizon_data <- build_horizon_plot_data(profile)
  boundaries <- build_boundary_paths(horizon_data, seed = 42)
  layers <- layer_horizon_boundaries(boundaries)

  expect_true(is.list(layers))
  expect_true(length(layers) > 0)
})

test_that("layer_boundary_transition_zones returns appropriate layers", {
  profile <- new_soil_profile(
    site_id = "test",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "A",
        boundary_grade = "gradual"
      ),
      new_soil_horizon(
        top = 20,
        bottom = 50,
        label = "B"
      )
    )
  )

  horizon_data <- build_horizon_plot_data(profile)
  zones <- build_boundary_transition_zones(horizon_data, seed = 42)
  layers <- layer_boundary_transition_zones(zones)

  expect_true(is.list(layers))
})
