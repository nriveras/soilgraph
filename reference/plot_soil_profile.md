# Plot a soil profile

Plot a soil profile

## Usage

``` r
plot_soil_profile(profile)
```

## Arguments

- profile:

  A `soil_profile` object.

## Value

A `ggplot2` object.

## Examples

``` r
# \donttest{
h1 <- new_soil_horizon(0, 18, label = "Ap", color = "#5C4033")
h2 <- new_soil_horizon(18, 52, label = "Bt1", color = "#8A5A44")
h3 <- new_soil_horizon(52, 95, label = "Bt2", color = "#A66A4C")
profile <- new_soil_profile("pedon-001", list(h1, h2, h3),
  classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf"))
plot_soil_profile(profile)

# }
```
