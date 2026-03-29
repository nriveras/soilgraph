# Derive horizons from a two-column field description table

Derive horizons from a two-column field description table

## Usage

``` r
derive_soil_horizons(data, profile_bottom = NULL)
```

## Arguments

- data:

  A data frame with `Depth` and `description` columns.

- profile_bottom:

  Optional terminal depth in centimeters. Required when `Depth` contains
  top depths rather than depth ranges.

## Value

A data frame with derived `Horizon`, `Top`, `Bottom`, `Texture`,
`Moisture`, `Color`, `BoundaryGrade`, `BoundaryShape`,
`CoarseAbundance`, `CoarseShape`, `CoarseGrade`, `CoarseType`,
`CoarseSize`, `CoarseColor`, `CoarsePercent`, and `Notes` columns.
