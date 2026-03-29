# Plot a field description table with encoded coarse fragment properties

Plot a field description table with encoded coarse fragment properties

## Usage

``` r
plot_soil_description_fragments(
  data,
  site_id = "soil-profile",
  profile_bottom = NULL,
  classification = list(system = "Field description", taxon = NULL),
  metadata = list(),
  seed = 1
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

- seed:

  Random seed for deterministic coarse fragment placement.

## Value

A `ggplot2` object.

## Examples

``` r
# \donttest{
field_notes <- data.frame(
  Depth = c("0-18 cm", "18-52 cm", "52-95 cm"),
  description = c(
    "Ap dark brown silt loam moist clear smooth few subangular weak fragments",
    "Bt1 reddish brown clay loam gradual wavy common rounded moderate fragments",
    "Bt2 brown clay diffuse irregular many subrounded strong fragments"
  )
)
plot_soil_description_fragments(field_notes, site_id = "pedon-001")

# }
```
