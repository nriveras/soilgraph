# Render boundary lines as ggplot2 geometries

Creates appropriate graphical layers for displaying horizon boundaries,
with visual properties encoding boundary distinctness and topography.

## Usage

``` r
layer_horizon_boundaries(
  boundary_data,
  line_color = "#1B1B1B",
  line_width = 0.5
)
```

## Arguments

- boundary_data:

  Data frame from
  [`build_boundary_paths()`](https://nriveras.github.io/soilgraph/reference/build_boundary_paths.md)

- line_color:

  Character: color for boundary lines (default: dark brown)

- line_width:

  Numeric: line width (default: 0.5)

## Value

A list of ggplot2 layer objects
