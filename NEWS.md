# soilgraph 0.1.0

* Initial CRAN release.
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
