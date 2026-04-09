test_that("derive_soil_horizons emits deprecation warning", {
  notes <- data.frame(
    Depth = c("0-18 cm", "18-52 cm"),
    description = c(
      "Ap dark brown silt loam moist clear smooth",
      "Bt1 reddish brown clay loam gradual wavy"
    )
  )
  expect_warning(derive_soil_horizons(notes), "deprecated")
})

test_that("soil_profile_from_table works with structured input", {
  horizons_df <- data.frame(
    Top = c(0, 18, 52),
    Bottom = c(18, 52, 95),
    Horizon = c("Ap", "Bt1", "Bt2"),
    Texture = c("silt loam", "clay loam", "clay"),
    Color = c("#5C4033", "#8A5A44", "#A66A4C"),
    BoundaryGrade = c("clear", "gradual", "diffuse"),
    BoundaryShape = c("smooth", "wavy", "irregular"),
    stringsAsFactors = FALSE
  )

  profile <- soil_profile_from_table(horizons_df, site_id = "structured-test")

  expect_s3_class(profile, "soil_profile")
  expect_equal(profile$site_id, "structured-test")
  expect_equal(length(profile$horizons), 3)
  expect_equal(profile$horizons[[1]]$label, "Ap")
  expect_equal(profile$horizons[[1]]$texture, "silt loam")
  expect_equal(profile$horizons[[1]]$color, "#5C4033")
  expect_equal(profile$horizons[[2]]$boundary_grade, "gradual")
  expect_equal(profile$horizons[[3]]$bottom, 95)
})

test_that("soil_profile_from_table accepts underscore column names", {
  horizons_df <- data.frame(
    Top = c(0, 20),
    Bottom = c(20, 50),
    Horizon = c("A", "B"),
    boundary_grade = c("clear", "gradual"),
    boundary_shape = c("smooth", "wavy"),
    coarse_abundance = c("few", "common"),
    stringsAsFactors = FALSE
  )

  profile <- soil_profile_from_table(horizons_df, site_id = "underscore-test")
  expect_equal(profile$horizons[[1]]$boundary_grade, "clear")
  expect_equal(profile$horizons[[2]]$coarse_abundance, "common")
})

test_that("soil_profile_from_table minimal structured input", {
  horizons_df <- data.frame(
    Top = c(0, 30),
    Bottom = c(30, 80)
  )

  profile <- soil_profile_from_table(horizons_df)
  expect_s3_class(profile, "soil_profile")
  expect_equal(length(profile$horizons), 2)
  expect_equal(profile$horizons[[1]]$top, 0)
  expect_equal(profile$horizons[[2]]$bottom, 80)
})

test_that("soil_profile_from_table warns on legacy Depth/description input", {
  notes <- data.frame(
    Depth = c("0-18 cm", "18-52 cm"),
    description = c(
      "Ap dark brown silt loam moist clear smooth",
      "Bt1 reddish brown clay loam gradual wavy"
    )
  )
  expect_warning(
    soil_profile_from_table(notes, site_id = "legacy-test"),
    "deprecated"
  )
})

test_that("soil_profile_from_table errors on missing columns", {
  bad_df <- data.frame(x = 1, y = 2)
  expect_error(soil_profile_from_table(bad_df), "Top.*Bottom|Depth.*description")
})

test_that("soil_profile_from_table handles NA values in optional columns", {
  horizons_df <- data.frame(
    Top = c(0, 20),
    Bottom = c(20, 50),
    Horizon = c("A", NA),
    Texture = c(NA, "clay"),
    stringsAsFactors = FALSE
  )

  profile <- soil_profile_from_table(horizons_df)
  expect_null(profile$horizons[[1]]$texture)
  expect_null(profile$horizons[[2]]$label)
  expect_equal(profile$horizons[[2]]$texture, "clay")
})

test_that("structured profile round-trips through JSON", {
  horizons_df <- data.frame(
    Top = c(0, 18, 52),
    Bottom = c(18, 52, 95),
    Horizon = c("Ap", "Bt1", "Bt2"),
    Texture = c("silt loam", "clay loam", "clay"),
    Color = c("#5C4033", "#8A5A44", "#A66A4C"),
    BoundaryGrade = c("clear", "gradual", "diffuse"),
    CoarseAbundance = c("few", "common", "many"),
    stringsAsFactors = FALSE
  )

  profile <- soil_profile_from_table(
    horizons_df,
    site_id = "roundtrip-structured",
    classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf")
  )

  tmp <- tempfile(fileext = ".soil.json")
  on.exit(unlink(tmp), add = TRUE)

  write_soil_json(profile, tmp)
  reloaded <- read_soil_json(tmp)

  expect_equal(reloaded$site_id, "roundtrip-structured")
  expect_equal(reloaded$horizons[[1]]$texture, "silt loam")
  expect_equal(reloaded$horizons[[2]]$boundary_grade, "gradual")
  expect_equal(reloaded$horizons[[3]]$coarse_abundance, "many")
})

test_that("structured profile plots with all engines", {
  horizons_df <- data.frame(
    Top = c(0, 18, 52),
    Bottom = c(18, 52, 95),
    Horizon = c("Ap", "Bt1", "Bt2"),
    Color = c("#5C4033", "#8A5A44", "#A66A4C"),
    BoundaryGrade = c("clear", "gradual", "diffuse"),
    BoundaryShape = c("smooth", "wavy", "irregular"),
    CoarseAbundance = c("few", "common", "many"),
    CoarseType = c("gravel", "cobble", "stone"),
    stringsAsFactors = FALSE
  )

  profile <- soil_profile_from_table(horizons_df, site_id = "plot-test")

  expect_s3_class(plot_soil_profile(profile), "ggplot")
  expect_s3_class(plot_soil_profile_fragments(profile, seed = 1), "ggplot")
  suppressWarnings(
    expect_s3_class(plot_soil_profile_advanced(profile, seed = 1), "ggplot")
  )
})

test_that("JSON schema file is bundled", {
  schema_path <- system.file(
    "extdata", "soil-profile.schema.json",
    package = "soilgraph"
  )
  skip_if(schema_path == "", message = "schema not installed")
  schema <- jsonlite::fromJSON(schema_path, simplifyVector = FALSE)
  expect_equal(schema$title, "Soil Profile")
  expect_true("horizons" %in% names(schema$properties))
})
