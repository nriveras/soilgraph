#!/usr/bin/env Rscript
#
# Demonstration of Soilgraph Graphical Engines
#
# This script demonstrates the advanced graphical rendering capabilities
# of the soilgraph package, showcasing coarse fragment and boundary engines.
#

devtools::load_all()
library(ggplot2)

output_dir <- file.path("outputs", "example-graphics-engines")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

save_example_plot <- function(filename, plot, width = 7, height = 9) {
  ggplot2::ggsave(
    filename = file.path(output_dir, filename),
    plot = plot,
    width = width,
    height = height,
    dpi = 300
  )
}

# ============================================================================
# Example 1: Basic Profile with Polygon Fragments
# ============================================================================

cat("Creating Example 1: Basic profile with polygon fragments...\n")

profile_1 <- new_soil_profile(
  site_id = "Example-001",
  classification = list(
    system = "Soil Taxonomy",
    taxon = "Typic Hapludalf"
  ),
  horizons = list(
    new_soil_horizon(
      top = 0,
      bottom = 18,
      label = "Ap",
      texture = "silt loam",
      color = "#5C4033",
      boundary_grade = "clear",
      boundary_shape = "smooth",
      coarse_type = "gravel",
      coarse_abundance = "few",
      coarse_grade = "weak",
      coarse_size = "fine"
    ),
    new_soil_horizon(
      top = 18,
      bottom = 52,
      label = "Bt1",
      texture = "clay loam",
      color = "#8A5A44",
      boundary_grade = "gradual",
      boundary_shape = "wavy",
      coarse_type = "cobble",
      coarse_abundance = "common",
      coarse_grade = "moderate",
      coarse_size = "medium"
    ),
    new_soil_horizon(
      top = 52,
      bottom = 95,
      label = "Bt2",
      texture = "clay",
      color = "#A66A4C",
      boundary_grade = "diffuse",
      boundary_shape = "irregular",
      coarse_type = "stone",
      coarse_abundance = "many",
      coarse_grade = "strong",
      coarse_size = "coarse"
    )
  )
)

# Create all rendering variants
cat("  - Basic (no fragments/boundaries)...\n")
plot_1a <- plot_soil_profile(profile_1)

cat("  - With point-based fragments...\n")
plot_1b <- plot_soil_profile_fragments(profile_1, seed = 42)

cat("  - With polygon fragments only...\n")
plot_1c <- plot_soil_profile_advanced(
  profile_1,
  show_fragments = TRUE,
  show_boundaries = FALSE,
  show_transition_zones = FALSE,
  seed = 42
)

cat("  - With boundaries and transition zones only...\n")
plot_1d <- plot_soil_profile_advanced(
  profile_1,
  show_fragments = FALSE,
  show_boundaries = TRUE,
  show_transition_zones = TRUE,
  seed = 42
)

cat("  - Full advanced rendering...\n")
plot_1e <- plot_soil_profile_advanced(profile_1, seed = 42)

save_example_plot("example-1a-basic-profile.png", plot_1a)
save_example_plot("example-1b-point-fragments.png", plot_1b)
save_example_plot("example-1c-polygon-fragments.png", plot_1c)
save_example_plot("example-1d-boundaries-zones.png", plot_1d)
save_example_plot("example-1e-full-advanced.png", plot_1e)

# ============================================================================
# Example 2: Fragment Type Showcase
# ============================================================================

cat("Creating Example 2: Fragment type showcase...\n")

# Create profile showcasing different fragment types
fragment_types <- c("gravel", "cobble", "stone", "boulder", "channer", "flagstone")

profile_2 <- new_soil_profile(
  site_id = "Fragment-Types",
  horizons = lapply(
    seq_along(fragment_types),
    function(i) {
      new_soil_horizon(
        top = (i - 1) * 15,
        bottom = i * 15,
        label = toupper(fragment_types[i]),
        color = "#8B7355",
        coarse_type = fragment_types[i],
        coarse_abundance = "common",
        coarse_grade = "moderate",
        coarse_size = "medium",
        boundary_shape = "smooth",
        boundary_grade = "clear"
      )
    }
  )
)

cat("  - Rendering with different fragment types...\n")
plot_2 <- plot_soil_profile_advanced(profile_2, seed = 42)

save_example_plot("example-2-fragment-types.png", plot_2, width = 7, height = 10)

# ============================================================================
# Example 3: Boundary Grade and Shape Showcase
# ============================================================================

cat("Creating Example 3: Boundary properties showcase...\n")

boundary_grades <- c("abrupt", "clear", "gradual", "diffuse")
boundary_shapes <- c("smooth", "wavy", "irregular", "broken")

profile_3 <- new_soil_profile(
  site_id = "Boundary-Types",
  horizons = list(
    new_soil_horizon(
      top = 0,
      bottom = 15,
      label = "Abrupt",
      color = "#A0826D",
      boundary_grade = "abrupt",
      boundary_shape = "smooth"
    ),
    new_soil_horizon(
      top = 15,
      bottom = 30,
      label = "Clear",
      color = "#9B7D66",
      boundary_grade = "clear",
      boundary_shape = "wavy"
    ),
    new_soil_horizon(
      top = 30,
      bottom = 50,
      label = "Gradual",
      color = "#96795F",
      boundary_grade = "gradual",
      boundary_shape = "irregular"
    ),
    new_soil_horizon(
      top = 50,
      bottom = 75,
      label = "Diffuse",
      color = "#917558",
      boundary_grade = "diffuse",
      boundary_shape = "broken"
    )
  )
)

cat("  - Rendering with different boundary properties...\n")
plot_3 <- plot_soil_profile_advanced(
  profile_3,
  show_fragments = FALSE,
  show_boundaries = TRUE,
  show_transition_zones = TRUE,
  seed = 42
)

save_example_plot("example-3-boundary-properties.png", plot_3, width = 7, height = 10)

# ============================================================================
# Example 4: Coarse Fragment Abundance Gradient
# ============================================================================

cat("Creating Example 4: Fragment abundance gradient...\n")

abundances <- c("very few", "few", "common", "many", "abundant")

profile_4 <- new_soil_profile(
  site_id = "Abundance-Gradient",
  horizons = lapply(
    seq_along(abundances),
    function(i) {
      new_soil_horizon(
        top = (i - 1) * 15,
        bottom = i * 15,
        label = substr(abundances[i], 1, 3),
        color = "#8B7355",
        coarse_type = "gravel",
        coarse_abundance = abundances[i],
        coarse_grade = "moderate",
        coarse_size = "medium",
        boundary_shape = "smooth",
        boundary_grade = "clear"
      )
    }
  )
)

cat("  - Rendering with fragment abundance gradient...\n")
plot_4 <- plot_soil_profile_advanced(
  profile_4,
  show_fragments = TRUE,
  show_boundaries = FALSE,
  seed = 42
)

save_example_plot("example-4-fragment-abundance.png", plot_4, width = 7, height = 9)

# ============================================================================
# Example 5: Coarse Fragment Grade (Cementation) Showcase
# ============================================================================

cat("Creating Example 5: Fragment grade showcase...\n")

grades <- c("very weak", "weak", "moderate", "strong", "very strong")

profile_5 <- new_soil_profile(
  site_id = "Grade-Showcase",
  horizons = lapply(
    seq_along(grades),
    function(i) {
      new_soil_horizon(
        top = (i - 1) * 15,
        bottom = i * 15,
        label = substr(grades[i], 1, 3),
        color = "#8B7355",
        coarse_type = "gravel",
        coarse_abundance = "common",
        coarse_grade = grades[i],
        coarse_size = "medium",
        boundary_shape = "smooth",
        boundary_grade = "clear"
      )
    }
  )
)

cat("  - Rendering with fragment grade gradient...\n")
plot_5 <- plot_soil_profile_advanced(
  profile_5,
  show_fragments = TRUE,
  show_boundaries = FALSE,
  seed = 42
)

save_example_plot("example-5-fragment-grade.png", plot_5, width = 7, height = 9)

# ============================================================================
# Example 6: Coarse Fragment Size Classes
# ============================================================================

cat("Creating Example 6: Fragment size showcase...\n")

sizes <- c("very fine", "fine", "small", "medium", "coarse", "large", "very coarse")

profile_6 <- new_soil_profile(
  site_id = "Size-Showcase",
  horizons = lapply(
    seq_along(sizes),
    function(i) {
      new_soil_horizon(
        top = (i - 1) * 12,
        bottom = i * 12,
        label = substr(sizes[i], 1, 3),
        color = "#8B7355",
        coarse_type = "gravel",
        coarse_abundance = "common",
        coarse_grade = "moderate",
        coarse_size = sizes[i],
        boundary_shape = "smooth",
        boundary_grade = "clear"
      )
    }
  )
)

cat("  - Rendering with fragment size gradient...\n")
plot_6 <- plot_soil_profile_advanced(
  profile_6,
  show_fragments = TRUE,
  show_boundaries = FALSE,
  seed = 42
)

save_example_plot("example-6-fragment-size.png", plot_6, width = 7, height = 10)

# ============================================================================
# Example 7: Reproducibility with Seeds
# ============================================================================

cat("Creating Example 7: Seed reproducibility...\n")

profile_7 <- new_soil_profile(
  site_id = "Seed-Test",
  horizons = list(
    new_soil_horizon(
      top = 0,
      bottom = 50,
      label = "A",
      color = "#8B7355",
      coarse_abundance = "common",
      boundary_shape = "irregular",
      boundary_grade = "gradual"
    )
  )
)

cat("  - Same seed produces identical renderings (seed=123)...\n")
plot_7a <- plot_soil_profile_advanced(profile_7, seed = 123)
plot_7b <- plot_soil_profile_advanced(profile_7, seed = 123)

cat("  - Different seeds produce different renderings...\n")
plot_7c <- plot_soil_profile_advanced(profile_7, seed = 456)

save_example_plot("example-7a-seed-123.png", plot_7a, width = 7, height = 8)
save_example_plot("example-7b-seed-123-repeat.png", plot_7b, width = 7, height = 8)
save_example_plot("example-7c-seed-456.png", plot_7c, width = 7, height = 8)

# ============================================================================
# Output Summary
# ============================================================================

cat("\n")
cat("========================================\n")
cat("EXAMPLES CREATED SUCCESSFULLY\n")
cat("========================================\n")
cat("\nGenerated plots:\n")
cat("  Example 1: Rendering variants (1a-1e)\n")
cat("  Example 2: Fragment types\n")
cat("  Example 3: Boundary properties\n")
cat("  Example 4: Fragment abundance\n")
cat("  Example 5: Fragment grade (cementation)\n")
cat("  Example 6: Fragment size classes\n")
cat("  Example 7: Seed reproducibility\n")
cat("\nTo display a plot, use:\n")
cat("  print(plot_1a)\n")
cat("  print(plot_2)\n")
cat("  etc.\n")
cat("\nSaved plot files to:\n")
cat("  ", output_dir, "\n", sep = "")
cat("\n")

# Return list of all plots for interactive use
invisible(list(
  plot_1a = plot_1a,
  plot_1b = plot_1b,
  plot_1c = plot_1c,
  plot_1d = plot_1d,
  plot_1e = plot_1e,
  plot_2 = plot_2,
  plot_3 = plot_3,
  plot_4 = plot_4,
  plot_5 = plot_5,
  plot_6 = plot_6,
  plot_7a = plot_7a,
  plot_7b = plot_7b,
  plot_7c = plot_7c
))
