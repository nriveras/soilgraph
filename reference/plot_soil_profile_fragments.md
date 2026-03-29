# Plot a soil profile with encoded coarse fragment properties

Plot a soil profile with encoded coarse fragment properties

## Usage

``` r
plot_soil_profile_fragments(profile, seed = 1)
```

## Arguments

- profile:

  A `soil_profile` object.

- seed:

  Random seed for deterministic coarse fragment placement.

## Value

A `ggplot2` object.

## Examples

``` r
# \donttest{
h1 <- new_soil_horizon(0, 18, label = "Ap", color = "#5C4033",
  coarse_abundance = "few", coarse_shape = "subangular",
  coarse_grade = "weak", coarse_type = "gravel")
h2 <- new_soil_horizon(18, 52, label = "Bt1", color = "#8A5A44",
  coarse_abundance = "common", coarse_shape = "rounded",
  coarse_grade = "moderate", coarse_type = "cobble")
profile <- new_soil_profile("pedon-001", list(h1, h2))
plot_soil_profile_fragments(profile)

# }
```
