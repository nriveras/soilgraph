# Construct a soil profile

Construct a soil profile

## Usage

``` r
new_soil_profile(
  site_id,
  horizons,
  classification = list(system = "Soil Taxonomy", taxon = NULL),
  metadata = list()
)
```

## Arguments

- site_id:

  Site identifier.

- horizons:

  A non-empty list of `soil_horizon` objects.

- classification:

  A named list describing the classification system and taxon.

- metadata:

  A named list with arbitrary profile metadata.

## Value

A `soil_profile` object.
