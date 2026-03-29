# Changelog

## soilgraph 0.1.0

- Initial CRAN release.
- Structured soil objects
  ([`new_soil_horizon()`](https://nriveras.github.io/soilgraph/reference/new_soil_horizon.md),
  [`new_soil_profile()`](https://nriveras.github.io/soilgraph/reference/new_soil_profile.md)).
- Field description parser
  ([`derive_soil_horizons()`](https://nriveras.github.io/soilgraph/reference/derive_soil_horizons.md),
  [`soil_profile_from_table()`](https://nriveras.github.io/soilgraph/reference/soil_profile_from_table.md)).
- Coarse fragment graphical engine with irregular polygon rendering.
- Horizon boundary graphical engine with shape and grade distortion.
- Five plotting functions:
  [`plot_soil_profile()`](https://nriveras.github.io/soilgraph/reference/plot_soil_profile.md),
  [`plot_soil_profile_fragments()`](https://nriveras.github.io/soilgraph/reference/plot_soil_profile_fragments.md),
  [`plot_soil_profile_advanced()`](https://nriveras.github.io/soilgraph/reference/plot_soil_profile_advanced.md),
  [`plot_soil_description()`](https://nriveras.github.io/soilgraph/reference/plot_soil_description.md),
  [`plot_soil_description_fragments()`](https://nriveras.github.io/soilgraph/reference/plot_soil_description_fragments.md).
- `.soil.json` import/export via
  [`read_soil_json()`](https://nriveras.github.io/soilgraph/reference/read_soil_json.md)
  and
  [`write_soil_json()`](https://nriveras.github.io/soilgraph/reference/write_soil_json.md).
- Four vignettes: Getting Started, Graphical Engines, Soil Data Model,
  Rendering Examples Gallery.
