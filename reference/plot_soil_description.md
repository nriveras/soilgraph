# Plot a soil profile from a two-column field description table

Plot a soil profile from a two-column field description table

## Usage

``` r
plot_soil_description(
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

A `ggplot2` object.

## Examples

``` r
# \donttest{
field_notes <- data.frame(
  Depth = c("0-18 cm", "18-52 cm", "52-95 cm"),
  description = c(
    "Ap dark brown silt loam moist clear smooth",
    "Bt1 reddish brown clay loam slightly moist gradual wavy",
    "Bt2 brown clay dry diffuse irregular"
  )
)
plot_soil_description(field_notes, site_id = "pedon-001")

# }
```
