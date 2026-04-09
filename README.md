# Soilgraph

The usual way to classify soils is by pit description. There are two main classification systems:
+ **Soil Taxonomy**: Developed by the USDA, widely adopted in the Americas, Asia, Oceania and Africa.
+ **World Reference Base for Soil Resources (WRB)**: FAO, used more in Europe. Focus is soil as a physical medium.

The current package can:
+ Define a **standardised field specification** for soil profile descriptions (JSON Schema + tabular format).
+ Store and exchange soil descriptions in the `.soil.json` format.
+ Build structured profiles from **explicit tabular data** or from `.soil.json` files.
+ Render publication-ready **visualisations** of soil profiles with graphical engines for irregular horizon boundaries and coarse fragments.

## Package scope

soilgraph focuses on two responsibilities:

| Responsibility | Entry points |
|---|---|
| **Standardise** a soil description specification | `soil_profile_from_table()`, `read_soil_json()`, `write_soil_json()`, JSON Schema |
| **Visualise** soil profiles from structured data | `plot_soil_profile()`, `plot_soil_profile_fragments()`, `plot_soil_profile_advanced()` |

> **Note:** The free-text description parser (`derive_soil_horizons()`) and the
> convenience wrappers `plot_soil_description()` / `plot_soil_description_fragments()`
> are **deprecated** as of the current development version. Users should prepare
> structured data (explicit columns or `.soil.json`) instead of relying on
> regex-based text extraction. See the migration examples below.

# Main workflow (structured table — preferred)

```r
library(soilgraph)

horizons_df <- data.frame(
    Top = c(0, 18, 52),
    Bottom = c(18, 52, 95),
    Horizon = c("Ap", "Bt1", "Bt2"),
    Texture = c("silt loam", "clay loam", "clay"),
    Color = c("#5C4033", "#8A5A44", "#A66A4C"),
    Moisture = c("moist", "slightly moist", "dry"),
    BoundaryGrade = c("clear", "gradual", "diffuse"),
    BoundaryShape = c("smooth", "wavy", "irregular"),
    CoarseAbundance = c("few", "common", "many"),
    CoarseShape = c("subangular", "rounded", "subrounded"),
    CoarseGrade = c("weak", "moderate", "strong"),
    stringsAsFactors = FALSE
)

profile <- soil_profile_from_table(
    horizons_df,
    site_id = "pedon-001",
    classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf")
)

plot_soil_profile(profile)
plot_soil_profile_advanced(profile, seed = 42)

write_soil_json(profile, "example.soil.json")
```

# JSON workflow

```r
# Read a .soil.json file
profile <- read_soil_json("example.soil.json")
plot_soil_profile_advanced(profile)
```

# Manual horizon construction

```r
h1 <- new_soil_horizon(0, 18, label = "Ap", color = "#5C4033",
    texture = "silt loam", boundary_grade = "clear", boundary_shape = "smooth")
h2 <- new_soil_horizon(18, 52, label = "Bt1", color = "#8A5A44",
    texture = "clay loam", boundary_grade = "gradual", boundary_shape = "wavy")
h3 <- new_soil_horizon(52, 95, label = "Bt2", color = "#A66A4C",
    texture = "clay", boundary_grade = "diffuse", boundary_shape = "irregular")

profile <- new_soil_profile("pedon-001", list(h1, h2, h3),
    classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf"))

plot_soil_profile_advanced(profile, seed = 42)
```

# Field specification

See the field schema document in `docs-source/soil-description-fields.md` and
the versioned JSON Schema in `inst/extdata/soil-profile.schema.json`.
