# soilgraph (development version)

## Breaking changes

* **Deprecated** `derive_soil_horizons()` — the free-text description parser is
  fragile for real-world field notes and redundant when structured input is
  available. Use `soil_profile_from_table()` with a structured data frame
  instead (#1).
* **Deprecated** `plot_soil_description()` and `plot_soil_description_fragments()`
  — these wrapper functions depend on the free-text parser. Build a profile with
  `soil_profile_from_table()` and pass it to `plot_soil_profile()`,
  `plot_soil_profile_fragments()`, or `plot_soil_profile_advanced()` (#1).

## New features

* `plot_soil_profile_fragments()` and `plot_soil_profile_advanced()` now render
  horizon fills as stitched polygons that follow boundary engine paths, so
  boundary topography and distinctness shape the fill geometry directly instead
  of being shown only as overlay lines. Transition zones for gradual/diffuse
  contacts are now path-following ribbons rather than fixed-height rectangles.

* `soil_profile_from_table()` now accepts **structured data frames** with
  explicit columns (`Top`, `Bottom`, `Horizon`, `Texture`, `Color`,
  `BoundaryGrade`, `BoundaryShape`, `CoarseAbundance`, etc.) as the primary
  tabular entry point. Both `PascalCase` and `snake_case` column names are
  recognized. The legacy `Depth`/`description` pathway still works but emits a
  deprecation warning (#1).
* Shipped a versioned **JSON Schema** (`inst/extdata/soil-profile.schema.json`,
  v0.2.0) formalizing the `.soil.json` format with full vocabulary constraints
  for boundary, coarse fragment, and morphology fields (#1).
* Added `lifecycle` as an imported dependency for deprecation badges.

## Internal

* Extracted `derive_soil_horizons_internal()`, `build_profile_from_derived()`,
  and `build_profile_from_structured()` as internal helpers to separate the
  legacy and structured pathways cleanly.
* Developer workflow: added pre-commit hooks, lintr, Makefile, and CONTRIBUTING guide.

# soilgraph 0.1.0

* Structured soil objects (`new_soil_horizon()`, `new_soil_profile()`).
* Field description parser (`derive_soil_horizons()`, `soil_profile_from_table()`).
* Coarse fragment graphical engine with irregular polygon rendering.
* Horizon boundary graphical engine with shape and grade distortion.
* Five plotting functions: `plot_soil_profile()`, `plot_soil_profile_fragments()`,
  `plot_soil_profile_advanced()`, `plot_soil_description()`,
  `plot_soil_description_fragments()`.
* `.soil.json` import/export via `read_soil_json()` and `write_soil_json()`.
* Four vignettes: Getting Started, Graphical Engines, Soil Data Model,
  Rendering Examples Gallery.
