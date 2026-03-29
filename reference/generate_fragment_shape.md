# Coarse Fragment Engine

Generates irregular shapes for coarse fragments based on soil
description properties. Creates mathematically irregular polygons that
visually represent different fragment types, sizes, and abundances in
soil profiles. Generate irregular polygon for a single coarse fragment

## Usage

``` r
generate_fragment_shape(
  center_x,
  center_y,
  size,
  fragment_type,
  total_depth = 100,
  seed = NULL
)
```

## Arguments

- center_x:

  X-coordinate of fragment center

- center_y:

  Y-coordinate of fragment center

- size:

  Numeric size multiplier (1-5 range typical)

- total_depth:

  Total depth of the soil profile for aspect ratio correction

- seed:

  Random seed for reproducible shape generation

## Value

A data frame with columns: x, y, fragment_id
