# Build a soil profile from a two-column field description table

Build a soil profile from a two-column field description table

## Usage

``` r
soil_profile_from_table(
  data,
  site_id = "soil-profile",
  profile_bottom = NULL,
  classification = list(system = "Field description", taxon = NULL),
  metadata = list()
)
```

## Arguments

- data:

  A data frame with `Depth` and `description` columns.

- site_id:

  Profile identifier. Defaults to `"soil-profile"`.

- profile_bottom:

  Optional terminal depth in centimeters. Required when `Depth` contains
  top depths rather than depth ranges.

- classification:

  A named list describing the classification system and taxon.

- metadata:

  A named list with arbitrary profile metadata.

## Value

A `soil_profile` object.
