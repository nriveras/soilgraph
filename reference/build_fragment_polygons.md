# Build complete fragment layout for entire profile

Orchestrates the generation of coarse fragment polygons for all horizons
in a soil profile.

## Usage

``` r
build_fragment_polygons(profile, seed = 1)
```

## Arguments

- profile:

  A `soil_profile` object

- seed:

  Random seed for reproducible fragment generation

## Value

A data frame with polygon coordinates for all fragments
