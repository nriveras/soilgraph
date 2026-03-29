# Package index

## Core Data Structures

Create and validate soil profile objects.

- [`new_soil_horizon()`](https://nriveras.github.io/soilgraph/reference/new_soil_horizon.md)
  : Construct a soil horizon
- [`new_soil_profile()`](https://nriveras.github.io/soilgraph/reference/new_soil_profile.md)
  : Construct a soil profile
- [`validate_soil_profile()`](https://nriveras.github.io/soilgraph/reference/validate_soil_profile.md)
  : Validate a soil profile

## Description Parsing

Parse field description tables into structured soil data.

- [`derive_soil_horizons()`](https://nriveras.github.io/soilgraph/reference/derive_soil_horizons.md)
  : Derive horizons from a two-column field description table
- [`soil_profile_from_table()`](https://nriveras.github.io/soilgraph/reference/soil_profile_from_table.md)
  : Build a soil profile from a two-column field description table

## Visualization

Plot soil profiles from objects or field description tables.

- [`plot_soil_profile()`](https://nriveras.github.io/soilgraph/reference/plot_soil_profile.md)
  : Plot a soil profile
- [`plot_soil_profile_fragments()`](https://nriveras.github.io/soilgraph/reference/plot_soil_profile_fragments.md)
  : Plot a soil profile with encoded coarse fragment properties
- [`plot_soil_profile_advanced()`](https://nriveras.github.io/soilgraph/reference/plot_soil_profile_advanced.md)
  : Plot soil profile with advanced graphical engines
- [`plot_soil_description()`](https://nriveras.github.io/soilgraph/reference/plot_soil_description.md)
  : Plot a soil profile from a two-column field description table
- [`plot_soil_description_fragments()`](https://nriveras.github.io/soilgraph/reference/plot_soil_description_fragments.md)
  : Plot a field description table with encoded coarse fragment
  properties

## Data Import / Export

Read and write soil profiles in `.soil.json` format.

- [`read_soil_json()`](https://nriveras.github.io/soilgraph/reference/read_soil_json.md)
  : Read a soil profile from JSON
- [`write_soil_json()`](https://nriveras.github.io/soilgraph/reference/write_soil_json.md)
  : Write a soil profile to JSON

## Graphics Engine — Boundaries

Generate irregular horizon boundary lines encoding shape (smooth, wavy,
irregular, broken, discontinuous) and grade (abrupt, clear, gradual,
diffuse).

- [`generate_boundary_path()`](https://nriveras.github.io/soilgraph/reference/generate_boundary_path.md)
  : Horizon Boundary Engine
- [`generate_boundary_distortion()`](https://nriveras.github.io/soilgraph/reference/generate_boundary_distortion.md)
  : Generate positional distortion for boundary shape
- [`compute_boundary_smoothing()`](https://nriveras.github.io/soilgraph/reference/compute_boundary_smoothing.md)
  : Apply boundary grade-based smoothing
- [`build_boundary_paths()`](https://nriveras.github.io/soilgraph/reference/build_boundary_paths.md)
  : Build boundary paths for all horizons in a profile
- [`layer_horizon_boundaries()`](https://nriveras.github.io/soilgraph/reference/layer_horizon_boundaries.md)
  : Render boundary lines as ggplot2 geometries
- [`build_boundary_transition_zones()`](https://nriveras.github.io/soilgraph/reference/build_boundary_transition_zones.md)
  : Create a transition zone visualization for gradual/diffuse
  boundaries
- [`layer_boundary_transition_zones()`](https://nriveras.github.io/soilgraph/reference/layer_boundary_transition_zones.md)
  : Layer for rendering transition zones
- [`create_boundary_encoding()`](https://nriveras.github.io/soilgraph/reference/create_boundary_encoding.md)
  : Encode boundary properties into visual representation

## Graphics Engine — Coarse Fragments

Generate irregular polygon shapes for rock fragments encoding type,
size, abundance, and cementation grade.

- [`generate_fragment_shape()`](https://nriveras.github.io/soilgraph/reference/generate_fragment_shape.md)
  : Coarse Fragment Engine
- [`build_fragment_polygons()`](https://nriveras.github.io/soilgraph/reference/build_fragment_polygons.md)
  : Build complete fragment layout for entire profile
- [`generate_horizon_fragments()`](https://nriveras.github.io/soilgraph/reference/generate_horizon_fragments.md)
  : Generate layout of coarse fragments for a horizon
- [`layer_coarse_fragments()`](https://nriveras.github.io/soilgraph/reference/layer_coarse_fragments.md)
  : Render coarse fragments as geom_polygon layer
- [`coarse_fragment_count()`](https://nriveras.github.io/soilgraph/reference/coarse_fragment_count.md)
  : Helper function to count fragments based on abundance
- [`coarse_grade_to_alpha()`](https://nriveras.github.io/soilgraph/reference/coarse_grade_to_alpha.md)
  : Map grade to transparency
- [`coarse_size_to_marker()`](https://nriveras.github.io/soilgraph/reference/coarse_size_to_marker.md)
  : Map size class to marker size
- [`normalize_fragment_type()`](https://nriveras.github.io/soilgraph/reference/normalize_fragment_type.md)
  : Normalize fragment type
- [`normalized_fragment_color()`](https://nriveras.github.io/soilgraph/reference/normalized_fragment_color.md)
  : Normalize fragment color
- [`create_fragment_encoding()`](https://nriveras.github.io/soilgraph/reference/create_fragment_encoding.md)
  : Encode fragment properties into visual encoding scheme

## Visualization Utilities

Themes, palettes, and helpers for soil profile graphics.

- [`build_horizon_plot_data()`](https://nriveras.github.io/soilgraph/reference/build_horizon_plot_data.md)
  : Get horizon plot data with all visualization properties
- [`describe_soil_profile()`](https://nriveras.github.io/soilgraph/reference/describe_soil_profile.md)
  : Generate a description of soil profile visualization
- [`theme_soil_profile()`](https://nriveras.github.io/soilgraph/reference/theme_soil_profile.md)
  : Create default theme for soil profile plots
- [`get_horizon_palette()`](https://nriveras.github.io/soilgraph/reference/get_horizon_palette.md)
  : Get color palette for horizons based on classification
- [`get_contrasting_text_color()`](https://nriveras.github.io/soilgraph/reference/get_contrasting_text_color.md)
  : Compute color contrast for accessibility
- [`is_valid_color()`](https://nriveras.github.io/soilgraph/reference/is_valid_color.md)
  : Visualization Utilities
