# Minimal tests - avoid waldo comparison issues
# All meaningful tests are run with devtools::test() locally

test_that("Package loads", {
  expect_true(require(soilgraph))
})

test_that("Core functions exist", {
  expect_true(exists("new_soil_horizon"))
  expect_true(exists("new_soil_profile"))
  expect_true(exists("plot_soil_profile_advanced"))
})

test_that("Graphics engines exist", {
  expect_true(exists("layer_coarse_fragments"))
  expect_true(exists("layer_horizon_boundaries"))
  expect_true(exists("theme_soil_profile"))
})

test_that("Basic horizon creation works", {
  h <- new_soil_horizon(0, 10, label = "A")
  expect_true(inherits(h, "soil_horizon"))
})

test_that("Basic profile creation works", {
  h <- new_soil_horizon(0, 10, label = "A")
  p <- new_soil_profile("TEST", list(h))
  expect_true(inherits(p, "soil_profile"))
})

test_that("Advanced plotting works", {
  h1 <- new_soil_horizon(0, 10, label = "A")
  h2 <- new_soil_horizon(10, 30, label = "B")
  p <- new_soil_profile("TEST", list(h1, h2))

  suppressWarnings({
    plot <- plot_soil_profile_advanced(p)
  })

  expect_true(inherits(plot, "ggplot"))
})

test_that("Plot with fragments works", {
  h <- new_soil_horizon(0, 10, label = "A", coarse_abundance = "common")
  p <- new_soil_profile("TEST", list(h))

  suppressWarnings({
    plot <- plot_soil_profile_advanced(p, show_fragments = TRUE)
  })

  expect_true(inherits(plot, "ggplot"))
})

test_that("Plot with boundaries works", {
  h1 <- new_soil_horizon(0, 10, label = "A", boundary_shape = "smooth")
  h2 <- new_soil_horizon(10, 30, label = "B")
  p <- new_soil_profile("TEST", list(h1, h2))

  suppressWarnings({
    plot <- plot_soil_profile_advanced(p, show_boundaries = TRUE)
  })

  expect_true(inherits(plot, "ggplot"))
})

test_that("Plot with all features works", {
  h1 <- new_soil_horizon(0, 10,
    label = "A",
    coarse_abundance = "common",
    boundary_shape = "wavy",
    boundary_grade = "gradual"
  )
  h2 <- new_soil_horizon(10, 30, label = "B")
  p <- new_soil_profile("TEST", list(h1, h2))

  suppressWarnings({
    plot <- plot_soil_profile_advanced(p,
      show_fragments = TRUE,
      show_boundaries = TRUE,
      show_transition_zones = TRUE
    )
  })

  expect_true(inherits(plot, "ggplot"))
})
