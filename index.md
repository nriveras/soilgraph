# Soilgraph

The usual way to clasify soils is by pit description. In this sence,
there are 2 main systems of classifying soils: + Soil Taxonomy:
Developed by the USDA for The United States of America, and widelly
adopted in the Americas, Asia, Oceania and Africa. + World Reference
Base for Soil Resources (WRB): FAO, used more in Europe. Focus is soil
as a physical medium.

The current package can: + Create a vector database of soil description
systems or other way to integrate it in a systematic way. + Create an
standard to store soil description (Initially just Soil Taxonomy system,
then WRB). `.soil.json` with standarized fields based in the models. +
Automate creation of `.soil.json` based in field data. Even handwriten.
Usually not every property is note, because some of them can be infered
based in other more general and easy to survey. + Graphical
visualization of the soil profile based in the `.soil.json` object.
Create a visual interpretation based in description criteria translated
to visual hints. + Coarse fragment engine can generate irregular
elements based in description, with different shape, size, abundance,
degree. + Horizon limit engine can generate irregular elements based in
description, with different shape and degree. + Tidy description
creation.

# Implementation

- Initial implementation will be done in R, with C++ in case of needing
  speed in calculation. Further plans to develope a python equivalent.
  - Standard package development structure.
  - Documentation with `Roxygen`
  - testing with `testthat`
  - visualization based in last version of `ggplot2`
- test-driven development: for each functionality, a test sould be
  writen first.

# Current MVP

- R package scaffold with `DESCRIPTION`, `NAMESPACE`, `R/`, `tests/`,
  and `inst/`
- Structured soil objects for horizons and full profiles
- Validation for depth ordering and horizon overlap
- `.soil.json` read and write helpers
- Basic soil profile visualization using `ggplot2`
- Example `.soil.json` payload in `inst/extdata/example.soil.json`
- Parser workflow from only `Depth` and `description`

# Main workflow

``` r
library(soilgraph)

field_notes <- data.frame(
    Depth = c("0-18 cm", "18-52 cm", "52-95 cm"),
    description = c(
        "Ap dark brown silt loam moist clear smooth few subangular weak fragments with granular structure",
        "Bt1 reddish brown clay loam slightly moist gradual wavy common rounded moderate fragments with clay films",
        "Bt2 brown clay dry diffuse irregular many subrounded strong fragments with strong blocky structure"
    )
)

derive_soil_horizons(field_notes)

profile <- soil_profile_from_table(field_notes, site_id = "pedon-001")
plot_soil_description(field_notes, site_id = "pedon-001")

write_soil_json(profile, "example.soil.json")
```

# Supported input modes

- Depth ranges in each row, such as `0-18 cm` and `18-52 cm`
- Top depths only, such as `0`, `18`, `52`, with an explicit
  `profile_bottom`

# Top-depth example

``` r
field_notes <- data.frame(
    Depth = c("0", "18", "52"),
    description = c(
        "Ap dark brown silt loam moist",
        "Bt1 reddish brown clay loam slightly moist",
        "Bt2 brown clay dry"
    )
)

derive_soil_horizons(field_notes, profile_bottom = 95)
plot_soil_description(field_notes, site_id = "pedon-002", profile_bottom = 95)
```

# Derived columns

- `Horizon`: inferred horizon label, or generated fallback labels
- `Top` and `Bottom`: parsed numeric depth boundaries in centimeters
- `Texture`, `Moisture`, and `Color`: rule-based fields extracted from
  `description`
- `BoundaryGrade` and `BoundaryShape`: horizon limit distinctness and
  topography
- `CoarseAbundance`, `CoarseShape`, and `CoarseGrade`: coarse fragment
  descriptors
- `Notes`: remaining free text after structured tokens are removed

# Field specification

- See the field schema document in `docs/soil-description-fields.md`.
