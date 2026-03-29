# Soil Description Data Model

## Overview

soilgraph uses a two-level data model: **profiles** contain
**horizons**. Each level carries its own set of properties. This article
documents the supported fields, vocabularies, and the `.soil.json`
storage format.

``` r
library(soilgraph)
```

## Profile-level fields

A `soil_profile` object stores site-level metadata alongside a list of
horizons: nbsp; \| Field \| Type \| Required \| Description \|
\|——-\|——\|———-\|————-\| \| `schema_version` \| string \| auto \| Schema
version (currently `"0.1.0"`) \| \| `site_id` \| string \| yes \| Unique
site identifier \| \| `classification$system` \| string \| yes \|
Classification system (`"Soil Taxonomy"`, `"WRB"`) \| \|
`classification$taxon` \| string \| no \| Taxon name
(e.g. `"Typic Hapludalf"`) \| \| `metadata` \| named list \| no \|
Arbitrary key-value pairs (country, land use, slope, etc.) \|

``` r
profile <- new_soil_profile(
  site_id = "pedon-042",
  horizons = list(
    new_soil_horizon(0, 25, label = "A"),
    new_soil_horizon(25, 60, label = "Bw")
  ),
  classification = list(system = "WRB", taxon = "Haplic Cambisol"),
  metadata = list(country = "Chile", slope_percent = 8, land_use = "forest")
)

profile$site_id
#> [1] "pedon-042"
profile$classification
#> $system
#> [1] "WRB"
#> 
#> $taxon
#> [1] "Haplic Cambisol"
profile$metadata
#> $country
#> [1] "Chile"
#> 
#> $slope_percent
#> [1] 8
#> 
#> $land_use
#> [1] "forest"
```

## Horizon-level fields

Each `soil_horizon` carries morphological properties. The table below
lists all supported fields:

### Core morphology

| Field      | Type    | Description                                   |
|------------|---------|-----------------------------------------------|
| `top`      | numeric | Top depth (cm) — **required**                 |
| `bottom`   | numeric | Bottom depth (cm) — **required**              |
| `label`    | string  | Horizon designation (e.g. `"Ap"`, `"Bt1"`)    |
| `texture`  | string  | Texture class (`"silt loam"`, `"clay"`, etc.) |
| `color`    | string  | Display color — hex code or R colour name     |
| `moisture` | string  | Moisture state (`"dry"`, `"moist"`, `"wet"`)  |
| `notes`    | string  | Free-text notes                               |

### Horizon boundary

| Field            | Type   | Recognized values                                        |
|------------------|--------|----------------------------------------------------------|
| `boundary_grade` | string | `abrupt`, `clear`, `gradual`, `diffuse`                  |
| `boundary_shape` | string | `smooth`, `wavy`, `irregular`, `broken`, `discontinuous` |

### Coarse fragments

| Field              | Type    | Recognized values                                                        |
|--------------------|---------|--------------------------------------------------------------------------|
| `coarse_abundance` | string  | `very few`, `few`, `common`, `many`, `abundant`                          |
| `coarse_shape`     | string  | `angular`, `subangular`, `subrounded`, `rounded`, `flat`                 |
| `coarse_grade`     | string  | `very weak`, `weak`, `moderate`, `strong`, `very strong`                 |
| `coarse_type`      | string  | `gravel`, `cobble`, `stone`, `boulder`, `channer`, `flagstone`           |
| `coarse_size`      | string  | `very fine`, `fine`, `small`, `medium`, `coarse`, `large`, `very coarse` |
| `coarse_color`     | string  | Fragment color — hex code or R colour name                               |
| `coarse_percent`   | numeric | Volume percentage (0–100)                                                |

``` r
h <- new_soil_horizon(
  top = 0, bottom = 18,
  label = "Ap",
  texture = "silt loam",
  color = "#5C4033",
  moisture = "moist",
  boundary_grade = "clear",
  boundary_shape = "smooth",
  coarse_abundance = "few",
  coarse_shape = "subangular",
  coarse_grade = "weak",
  coarse_type = "gravel",
  coarse_size = "fine",
  coarse_color = "#1B1B1B",
  coarse_percent = 5,
  notes = "Granular structure, abundant roots"
)
str(h, max.level = 1)
#> List of 16
#>  $ top             : num 0
#>  $ bottom          : num 18
#>  $ label           : chr "Ap"
#>  $ texture         : chr "silt loam"
#>  $ color           : chr "#5C4033"
#>  $ moisture        : chr "moist"
#>  $ boundary_grade  : chr "clear"
#>  $ boundary_shape  : chr "smooth"
#>  $ coarse_abundance: chr "few"
#>  $ coarse_shape    : chr "subangular"
#>  $ coarse_grade    : chr "weak"
#>  $ coarse_type     : chr "gravel"
#>  $ coarse_size     : chr "fine"
#>  $ coarse_color    : chr "#1B1B1B"
#>  $ coarse_percent  : num 5
#>  $ notes           : chr "Granular structure, abundant roots"
#>  - attr(*, "class")= chr [1:2] "soil_horizon" "list"
```

## Parsing natural language descriptions

[`derive_soil_horizons()`](https://nriveras.github.io/soilgraph/reference/derive_soil_horizons.md)
extracts structured data from free-text field descriptions. The parser
uses keyword dictionaries to recognize properties.

### Supported input formats

**Depth ranges** (e.g. `"0-18 cm"`):

``` r
notes_range <- data.frame(
  Depth = c("0-18 cm", "18-52 cm", "52-95 cm"),
  description = c(
    "Ap dark brown silt loam moist clear smooth few subangular weak fragments",
    "Bt1 reddish brown clay loam slightly moist gradual wavy common rounded moderate fragments",
    "Bt2 brown clay dry diffuse irregular many subrounded strong fragments"
  )
)

result <- derive_soil_horizons(notes_range)
result[, c("Horizon", "Top", "Bottom", "Texture", "Color", "BoundaryGrade")]
#>   Horizon Top Bottom   Texture   Color BoundaryGrade
#> 1      Ap   0     18 silt loam #5C4033         clear
#> 2     Bt1  18     52 clay loam #7B3F2A       gradual
#> 3     Bt2  52     95      clay #8B5A2B       diffuse
```

**Top depths only** (requires `profile_bottom`):

``` r
notes_top <- data.frame(
  Depth = c("0", "18", "52"),
  description = c(
    "Ap dark brown silt loam moist",
    "Bt1 reddish brown clay loam slightly moist",
    "Bt2 brown clay dry"
  )
)

result_top <- derive_soil_horizons(notes_top, profile_bottom = 95)
result_top[, c("Horizon", "Top", "Bottom")]
#>   Horizon Top Bottom
#> 1      Ap   0     18
#> 2     Bt1  18     52
#> 3     Bt2  52     95
```

### Recognized vocabulary

The parser matches against built-in dictionaries. Here are the main
categories:

**Texture classes**: sandy clay, sandy clay loam, sandy loam, loamy
sand, silt loam, silty clay, silty clay loam, clay loam, clay, loam,
silt, sand.

**Moisture states**: dry, slightly moist, moist, wet.

**Color names**: dark brown, reddish brown, brown, yellowish brown,
olive brown, gray, dark gray, dark reddish brown, red, yellowish red,
dark yellowish brown, pale brown, light brownish gray, very dark gray,
very dark brown, black, white.

**Boundary grades**: abrupt, clear, gradual, diffuse.

**Boundary shapes**: smooth, wavy, irregular, broken, discontinuous.

**Coarse fragment terms**: abundance (very few, few, common, many,
abundant), shape (angular, subangular, subrounded, rounded, flat), grade
(very weak, weak, moderate, strong, very strong).

## The `.soil.json` format

Profiles are serialized to a standardized JSON schema. The format
includes the full profile structure with all horizons and metadata.

``` r
profile_full <- soil_profile_from_table(
  notes_range,
  site_id = "pedon-001",
  classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf"),
  metadata = list(country = "Chile")
)

tmp <- tempfile(fileext = ".soil.json")
write_soil_json(profile_full, tmp)
cat(readLines(tmp), sep = "\n")
#> {
#>   "schema_version": "0.1.0",
#>   "site_id": "pedon-001",
#>   "classification": {
#>     "system": "Soil Taxonomy",
#>     "taxon": "Typic Hapludalf"
#>   },
#>   "metadata": {
#>     "country": "Chile"
#>   },
#>   "horizons": [
#>     {
#>       "top": 0,
#>       "bottom": 18,
#>       "label": "Ap",
#>       "texture": "silt loam",
#>       "color": "#5C4033",
#>       "moisture": "moist",
#>       "boundary_grade": "clear",
#>       "boundary_shape": "smooth",
#>       "coarse_abundance": "few",
#>       "coarse_shape": "subangular",
#>       "coarse_grade": "weak",
#>       "coarse_type": null,
#>       "coarse_size": null,
#>       "coarse_color": null,
#>       "coarse_percent": null,
#>       "notes": "fragments"
#>     },
#>     {
#>       "top": 18,
#>       "bottom": 52,
#>       "label": "Bt1",
#>       "texture": "clay loam",
#>       "color": "#7B3F2A",
#>       "moisture": "slightly moist",
#>       "boundary_grade": "gradual",
#>       "boundary_shape": "wavy",
#>       "coarse_abundance": "common",
#>       "coarse_shape": "rounded",
#>       "coarse_grade": "moderate",
#>       "coarse_type": null,
#>       "coarse_size": null,
#>       "coarse_color": null,
#>       "coarse_percent": null,
#>       "notes": "fragments"
#>     },
#>     {
#>       "top": 52,
#>       "bottom": 95,
#>       "label": "Bt2",
#>       "texture": "clay",
#>       "color": "#8B5A2B",
#>       "moisture": "dry",
#>       "boundary_grade": "diffuse",
#>       "boundary_shape": "irregular",
#>       "coarse_abundance": "many",
#>       "coarse_shape": "subrounded",
#>       "coarse_grade": "strong",
#>       "coarse_type": null,
#>       "coarse_size": null,
#>       "coarse_color": null,
#>       "coarse_percent": null,
#>       "notes": "fragments"
#>     }
#>   ]
#> }
```

### Example `.soil.json` structure

The bundled example file demonstrates the complete schema:

``` r
json_path <- system.file("extdata", "example.soil.json", package = "soilgraph")
example <- read_soil_json(json_path)

cat("Site ID:", example$site_id, "\n")
#> Site ID: pedon-001
cat("System:", example$classification$system, "\n")
#> System: Soil Taxonomy
cat("Taxon:", example$classification$taxon, "\n")
#> Taxon: Typic Hapludalf
cat("Horizons:", length(example$horizons), "\n")
#> Horizons: 3
cat("Total depth:", example$horizons[[length(example$horizons)]]$bottom, "cm\n")
#> Total depth: 95 cm
```

### Round-trip fidelity

Writing and reading back preserves all fields:

``` r
tmp2 <- tempfile(fileext = ".soil.json")
write_soil_json(example, tmp2)
reloaded <- read_soil_json(tmp2)

identical(example$site_id, reloaded$site_id)
#> [1] TRUE
identical(example$classification, reloaded$classification)
#> [1] TRUE
identical(length(example$horizons), length(reloaded$horizons))
#> [1] TRUE
```

## Validation

[`validate_soil_profile()`](https://nriveras.github.io/soilgraph/reference/validate_soil_profile.md)
checks the following constraints:

- The object has `soil_profile` class.
- `horizons` is a non-empty list of `soil_horizon` objects.
- Top depths are sorted in ascending order (shallow → deep).
- Each horizon’s `bottom > top`.
- No overlapping horizons.

``` r
# Valid profile passes silently
validate_soil_profile(profile)

# Invalid profiles throw informative errors
tryCatch(
  validate_soil_profile(list(not = "a profile")),
  error = function(e) message("Error: ", e$message)
)
#> Error: `profile` must be a `soil_profile`.
```

## Key USDA terminology

Some key terms from the USDA Soil Survey Manual used throughout
soilgraph:

- **Horizon**: A layer of soil approximately parallel to the soil
  surface, differing from adjacent layers in physical or chemical
  properties.
- **Boundary grade (distinctness)**: How sharply one horizon transitions
  to the next — abrupt (\< 2 cm), clear (2–5 cm), gradual (5–15 cm),
  diffuse (\> 15 cm).
- **Boundary shape (topography)**: The spatial pattern of the boundary —
  smooth, wavy, irregular, broken, or discontinuous.
- **Coarse fragments**: Rock or mineral particles \> 2 mm diameter.
  Classified by size, shape, and degree of weathering (cementation
  grade).
- **Texture class**: The relative proportion of sand, silt, and clay
  (e.g. “silt loam” = mostly silt with some sand and clay).
