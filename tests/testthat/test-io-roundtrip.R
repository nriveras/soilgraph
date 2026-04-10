test_that("JSON round-trip preserves all fields", {
  h1 <- new_soil_horizon(0, 18,
    label = "Ap", color = "#5C4033",
    texture = "silt loam", moisture = "moist",
    boundary_grade = "clear", boundary_shape = "smooth",
    boundary_thickness_cm = 4,
    coarse_abundance = "few", coarse_type = "gravel",
    coarse_grade = "weak", coarse_size = "fine",
    notes = "Round-trip test horizon"
  )
  h2 <- new_soil_horizon(18, 52,
    label = "Bt1", color = "#8A5A44",
    texture = "clay loam", boundary_grade = "gradual",
    boundary_shape = "wavy"
  )

  profile <- new_soil_profile(
    site_id = "roundtrip-test",
    horizons = list(h1, h2),
    classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf"),
    metadata = list(country = "Chile", slope_percent = 4)
  )

  tmp <- tempfile(fileext = ".soil.json")
  on.exit(unlink(tmp), add = TRUE)

  write_soil_json(profile, tmp)
  reloaded <- read_soil_json(tmp)

  expect_equal(reloaded$site_id, "roundtrip-test")
  expect_equal(reloaded$classification$system, "Soil Taxonomy")
  expect_equal(reloaded$classification$taxon, "Typic Hapludalf")
  expect_equal(length(reloaded$horizons), 2)
  expect_equal(reloaded$horizons[[1]]$label, "Ap")
  expect_equal(reloaded$horizons[[1]]$top, 0)
  expect_equal(reloaded$horizons[[1]]$bottom, 18)
  expect_equal(reloaded$horizons[[1]]$texture, "silt loam")
  expect_equal(reloaded$horizons[[1]]$color, "#5C4033")
  expect_equal(reloaded$horizons[[1]]$boundary_grade, "clear")
  expect_equal(reloaded$horizons[[1]]$boundary_thickness_cm, 4)
  expect_equal(reloaded$horizons[[1]]$coarse_type, "gravel")
  expect_equal(reloaded$horizons[[1]]$notes, "Round-trip test horizon")
  expect_equal(reloaded$horizons[[2]]$label, "Bt1")
})

test_that("read bundled example.soil.json", {
  json_path <- system.file("extdata", "example.soil.json", package = "soilgraph")
  skip_if(json_path == "", message = "example.soil.json not found")

  profile <- read_soil_json(json_path)

  expect_s3_class(profile, "soil_profile")
  expect_equal(profile$site_id, "pedon-001")
  expect_equal(profile$classification$system, "Soil Taxonomy")
  expect_equal(profile$classification$taxon, "Typic Hapludalf")
  expect_equal(length(profile$horizons), 3)
  expect_equal(profile$horizons[[1]]$label, "Ap")
  expect_equal(profile$horizons[[2]]$label, "Bt1")
  expect_equal(profile$horizons[[3]]$label, "Bt2")
  expect_equal(profile$horizons[[3]]$bottom, 95)
})

test_that("write_soil_json creates valid JSON", {
  h <- new_soil_horizon(0, 20, label = "A")
  p <- new_soil_profile("json-test", list(h))

  tmp <- tempfile(fileext = ".soil.json")
  on.exit(unlink(tmp), add = TRUE)

  write_soil_json(p, tmp)
  expect_true(file.exists(tmp))

  parsed <- jsonlite::fromJSON(tmp, simplifyVector = FALSE)
  expect_equal(parsed$site_id, "json-test")
  expect_equal(parsed$schema_version, "0.1.0")
  expect_equal(length(parsed$horizons), 1)
})

test_that("JSON round-trip with metadata", {
  h <- new_soil_horizon(0, 30, label = "A")
  p <- new_soil_profile("meta-test", list(h),
    metadata = list(country = "USA", elevation = 350)
  )

  tmp <- tempfile(fileext = ".soil.json")
  on.exit(unlink(tmp), add = TRUE)

  write_soil_json(p, tmp)
  reloaded <- read_soil_json(tmp)

  expect_equal(reloaded$metadata$country, "USA")
  expect_equal(reloaded$metadata$elevation, 350)
})
