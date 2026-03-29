# Build boundary paths for all horizons in a profile

Generates irregular boundary lines between sequential horizons, encoding
boundary properties into visual irregularity.

## Usage

``` r
build_boundary_paths(horizon_data, seed = 1)
```

## Arguments

- horizon_data:

  Data frame with horizon properties from
  [`build_horizon_plot_data()`](https://nriveras.github.io/soilgraph/reference/build_horizon_plot_data.md)

- seed:

  Random seed for reproducible generation

## Value

Data frame with boundary path coordinates
