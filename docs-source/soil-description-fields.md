# Soil Description Field Specification

## Scope
This specification defines fields for storing a pedon description in a consistent way. The field set is based on terminology emphasized in:

- A Glossary of Terms Used in Soil Survey and Soil Classification
- A Summary of the Contributions of the International Committees for Revising Soil Taxonomy

The glossary supports the morphology terms used in field description (for example horizon, texture, consistence, redoximorphic features, ped and void surface features, depth, and contacts). The Soil Taxonomy committee summary reinforces the taxonomic importance of horizon attributes, redox features, boundary distinctness, texture and thickness, and depth-related criteria.

## Data Model
Use one profile record with a list of horizon records.

- Profile level: site and context metadata
- Horizon level: measured and interpreted morphology per layer

## Profile Fields

### Required

- profile_id: String. Unique identifier.
- system: String. Classification system name. Suggested values: Soil Taxonomy, WRB.
- observation_date: Date.
- observer: String.
- location:
  - latitude: Number
  - longitude: Number
  - elevation_m: Number or null

### Recommended

- landform: String
- slope_percent: Number
- parent_material: String
- drainage_class: String
- water_table_depth_cm: Number or null
- notes: String or null

### Classification Block

- classification:
  - order: String or null
  - suborder: String or null
  - great_group: String or null
  - subgroup: String or null
  - family: String or null
  - series: String or null
  - diagnostic_horizons: Array of strings
  - diagnostic_characteristics: Array of strings

## Horizon Fields

Each horizon object should include:

### Required

- top_cm: Number
- bottom_cm: Number
- horizon: String
- description: String

### Core Morphology

- texture_field: String or null
- texture_lab: String or null
- color_moist: String or null
- color_dry: String or null
- structure_type: String or null
- structure_grade: String or null
- structure_size: String or null
- consistence_moist: String or null
- consistence_wet: String or null
- consistence_dry: String or null
- roots_abundance: String or null
- roots_size: String or null
- pores_abundance: String or null
- pores_size: String or null

### Horizon Boundary

- boundary_grade: String or null
- boundary_shape: String or null

Suggested boundary_grade vocabulary:
- abrupt
- clear
- gradual
- diffuse

Suggested boundary_shape vocabulary:
- smooth
- wavy
- irregular
- broken
- discontinuous

### Redox and Wetness Features

- redox_features_present: Boolean
- redox_concentrations: String or null
- redox_depletions: String or null
- reduced_matrix: String or null
- saturation_expression: String or null

### Coarse and Rock Fragments

- coarse_fragments_volume_percent: Number or null
- coarse_fragments_abundance_class: String or null
- coarse_fragments_size_class: String or null
- coarse_fragments_shape: String or null
- coarse_fragments_grade: String or null
- rock_fragment_lithology: String or null

Suggested coarse_fragments_abundance_class vocabulary:
- very few
- few
- common
- many
- abundant

Suggested coarse_fragments_shape vocabulary:
- angular
- subangular
- subrounded
- rounded
- platy

### Ped and Void Surface Features

- clay_films_present: Boolean or null
- clay_films_location: String or null
- cutans_type: String or null
- concretions_type: String or null
- concretions_abundance: String or null

### Chemical and Cementation Indicators

- carbonates_present: Boolean or null
- effervescence_class: String or null
- gypsum_present: Boolean or null
- salts_present: Boolean or null
- cementation_class: String or null

### Physical Restrictions and Contacts

- restrictive_layer_type: String or null
- restrictive_layer_depth_cm: Number or null
- bedrock_type: String or null
- bedrock_depth_cm: Number or null

### Horizon Notes

- notes: String or null

## Minimum Viable Set for Parsing
When input is only Depth and description, parser output should minimally produce:

- horizon
- top_cm
- bottom_cm
- texture_field
- color_moist
- moisture_state
- boundary_grade
- boundary_shape
- coarse_fragments_abundance_class
- coarse_fragments_shape
- coarse_fragments_grade
- notes

## Validation Rules

- top_cm must be greater than or equal to 0
- bottom_cm must be greater than top_cm
- Horizons must be sorted by top_cm
- Horizons must not overlap
- Controlled vocabulary fields should store canonical values
- Unknown tokens should be preserved in notes and not discarded

## Interoperability Notes

- Keep raw description text for every horizon even after parsing
- Keep both field and laboratory texture where available
- Keep diagnostic_horizons and diagnostic_characteristics as arrays for taxonomic workflows
- Keep depth units in centimeters for all stored numeric depth fields
