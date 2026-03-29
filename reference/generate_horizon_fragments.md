# Generate layout of coarse fragments for a horizon

Creates a spatial distribution of irregular coarse fragment shapes
within a horizon layer. Fragments are distributed based on abundance,
with visual properties encoded by size, grade, and type.

## Usage

``` r
generate_horizon_fragments(
  horizon_data,
  horizon_index,
  total_depth = 100,
  seed = 1
)
```

## Arguments

- horizon_data:

  Data frame row containing horizon properties

- horizon_index:

  Integer index of the horizon

- total_depth:

  Total depth of the soil profile for scaling

- seed:

  Random seed for reproducible placement

## Value

A data frame with fragment polygon coordinates and properties
