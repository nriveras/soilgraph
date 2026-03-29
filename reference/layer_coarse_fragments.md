# Render coarse fragments as geom_polygon layer

Creates ggplot2 layers for rendering coarse fragments with proper
coloring and transparency based on fragment properties.

## Usage

``` r
layer_coarse_fragments(fragment_data)
```

## Arguments

- fragment_data:

  Data frame from
  [`build_fragment_polygons()`](https://nriveras.github.io/soilgraph/reference/build_fragment_polygons.md)

## Value

A list of ggplot2 layer objects
