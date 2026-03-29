# Get horizon plot data with all visualization properties

Extracts and prepares horizon data for visualization, applying defaults
and normalizing property values for use by graphics engines.

## Usage

``` r
build_horizon_plot_data(profile)
```

## Arguments

- profile:

  A `soil_profile` object

## Value

Data frame with columns: horizon_index, label, top, bottom, fill,
midpoint, boundary_shape, boundary_grade, coarse_abundance,
coarse_grade, coarse_type, coarse_size, coarse_color, coarse_percent
