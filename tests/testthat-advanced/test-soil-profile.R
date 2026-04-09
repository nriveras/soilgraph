test_that("new_soil_horizon validates depths", {
  expect_error(
    new_soil_horizon(top = 10, bottom = 5, label = "A"),
    "`bottom` must be greater than `top`"
  )

  horizon <- new_soil_horizon(top = 0, bottom = 20, label = "A", color = "#6B4F3A")

  expect_s3_class(horizon, "soil_horizon")
  expect_equal(horizon$bottom, 20)
})

test_that("new_soil_profile rejects overlapping horizons", {
  horizons <- list(
    new_soil_horizon(top = 0, bottom = 20, label = "A"),
    new_soil_horizon(top = 15, bottom = 40, label = "Bt")
  )

  expect_error(
    new_soil_profile(site_id = "site-1", horizons = horizons),
    "Horizons cannot overlap"
  )
})

test_that("soil profiles round-trip through json", {
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
        coarse_shape = "subangular",
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
        coarse_shape = "rounded",
        coarse_grade = "moderate"
      )
    ),
    classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf"),
    metadata = list(country = "Chile", slope_percent = 4)
  )

  output_path <- tempfile(fileext = ".soil.json")
  write_soil_json(profile, output_path)
  restored <- read_soil_json(output_path)

  expect_equal(restored$site_id, profile$site_id)
  expect_equal(restored$classification$taxon, profile$classification$taxon)
  expect_equal(length(restored$horizons), 2)
  expect_equal(restored$horizons[[2]]$texture, "clay loam")
  expect_equal(restored$horizons[[1]]$boundary_grade, "clear")
  expect_equal(restored$horizons[[2]]$coarse_abundance, "common")
})

test_that("plot_soil_profile returns a ggplot object", {
  profile <- new_soil_profile(
    site_id = "pedon-002",
    horizons = list(
      new_soil_horizon(top = 0, bottom = 10, label = "O", color = "#2E1A12"),
      new_soil_horizon(top = 10, bottom = 30, label = "A", color = "#6B4F3A")
    )
  )

  plot <- plot_soil_profile(profile)
  expect_s3_class(plot, "ggplot")
})

test_that("derive_soil_horizons parses range depths and descriptions", {
  field_notes <- data.frame(
    Depth = c("0-18 cm", "18-52 cm"),
    description = c(
      "Ap dark brown silt loam moist clear smooth few subangular weak 8% fine black gravel fragments with granular structure",
      "Bt1 reddish brown clay loam slightly moist gradual wavy common rounded moderate 22% coarse red cobble fragments with clay films"
    ),
    stringsAsFactors = FALSE
  )

  derived <- derive_soil_horizons(field_notes)

  expect_equal(derived$Horizon, c("Ap", "Bt1"))
  expect_equal(derived$Top, c(0, 18))
  expect_equal(derived$Bottom, c(18, 52))
  expect_equal(derived$Texture, c("silt loam", "clay loam"))
  expect_equal(derived$Moisture, c("moist", "slightly moist"))
  expect_equal(derived$Color, c("#5C4033", "#7B3F2A"))
  expect_equal(derived$BoundaryGrade, c("clear", "gradual"))
  expect_equal(derived$BoundaryShape, c("smooth", "wavy"))
  expect_equal(derived$CoarseAbundance, c("few", "common"))
  expect_equal(derived$CoarseShape, c("subangular", "rounded"))
  expect_equal(derived$CoarseGrade, c("weak", "moderate"))
  expect_equal(derived$CoarseType, c("gravel", "cobble"))
  expect_equal(derived$CoarseSize, c("fine", "coarse"))
  expect_equal(derived$CoarsePercent, c(8, 22))
  expect_equal(derived$CoarseColor, c("#2E2E2E", "#A63A2B"))
})

test_that("derive_soil_horizons parses top depths with profile bottom", {
  field_notes <- data.frame(
    Depth = c("0", "22", "48"),
    description = c(
      "A dark brown sandy loam moist",
      "Bt clay loam slightly moist",
      "C gray sand dry"
    ),
    stringsAsFactors = FALSE
  )

  derived <- derive_soil_horizons(field_notes, profile_bottom = 90)

  expect_equal(derived$Top, c(0, 22, 48))
  expect_equal(derived$Bottom, c(22, 48, 90))
  expect_equal(derived$Horizon, c("A", "Bt", "C"))
})

test_that("derive_soil_horizons requires profile bottom for top-depth input", {
  field_notes <- data.frame(
    Depth = c("0", "20"),
    description = c("A dark brown loam", "Bt brown clay loam"),
    stringsAsFactors = FALSE
  )

  expect_error(
    derive_soil_horizons(field_notes),
    "`profile_bottom` is required"
  )
})

test_that("soil_profile_from_table returns a soil_profile", {
  field_notes <- data.frame(
    Depth = c("0-15", "15-40"),
    description = c(
      "Ap dark brown silt loam moist clear smooth few subangular weak fragments",
      "Bt brown clay loam gradual wavy common rounded moderate fragments"
    ),
    stringsAsFactors = FALSE
  )

  profile <- soil_profile_from_table(field_notes, site_id = "pedon-003")

  expect_s3_class(profile, "soil_profile")
  expect_equal(profile$horizons[[1]]$label, "Ap")
  expect_equal(profile$horizons[[2]]$texture, "clay loam")
  expect_equal(profile$horizons[[1]]$boundary_grade, "clear")
  expect_equal(profile$horizons[[2]]$coarse_shape, "rounded")
})

test_that("plot_soil_description returns a ggplot object", {
  field_notes <- data.frame(
    Depth = c("0-12", "12-35"),
    description = c("O very dark brown loam moist", "A brown sandy loam dry"),
    stringsAsFactors = FALSE
  )

  plot <- plot_soil_description(field_notes, site_id = "pedon-004")

  expect_s3_class(plot, "ggplot")
})

test_that("plot_soil_profile_fragments returns a ggplot object", {
  profile <- new_soil_profile(
    site_id = "pedon-fragments",
    horizons = list(
      new_soil_horizon(
        top = 0,
        bottom = 20,
        label = "Ap",
        color = "#5C4033",
        boundary_shape = "smooth",
        coarse_abundance = "few",
        coarse_type = "gravel",
        coarse_size = "fine",
        coarse_color = "#2E2E2E",
        coarse_grade = "weak",
        coarse_percent = 8
      ),
      new_soil_horizon(
        top = 20,
        bottom = 55,
        label = "Bt",
        color = "#7B3F2A",
        boundary_shape = "wavy",
        coarse_abundance = "common",
        coarse_type = "cobble",
        coarse_size = "coarse",
        coarse_color = "#A63A2B",
        coarse_grade = "strong",
        coarse_percent = 24
      )
    )
  )

  plot <- plot_soil_profile_fragments(profile, seed = 123)
  expect_s3_class(plot, "ggplot")
})
