# Plot soil profile with advanced graphical engines

Creates a detailed soil profile visualization using custom graphical
engines for coarse fragments (polygons) and horizon boundaries
(irregular lines). This function provides a more sophisticated rendering
compared to the basic point-based visualization.

## Usage

``` r
plot_soil_profile_advanced(
  profile,
  show_fragments = TRUE,
  show_boundaries = TRUE,
  show_transition_zones = TRUE,
  seed = 1
)
```

## Arguments

- profile:

  A `soil_profile` object.

- show_fragments:

  Logical: whether to render coarse fragments as polygons.

- show_boundaries:

  Logical: whether to render boundary transitions.

- show_transition_zones:

  Logical: whether to show gradual/diffuse transition zones.

- seed:

  Random seed for deterministic rendering.

## Value

A `ggplot2` object.
