# Soil Profile Graphical Engines

## Overview

Soilgraph provides sophisticated custom graphical engines for rendering soil profile visualizations with scientific accuracy and visual fidelity. These engines translate soil description properties into visually interpretable graphical elements.

## Architecture

The graphical system is organized into three main components:

### 1. Coarse Fragment Engine (`R/graphics_coarse_fragments.R`)

Generates irregular polygon shapes representing coarse fragments (rocks, gravel, etc.) based on soil description properties.

**Key Features:**
- **Polygon-based rendering**: Fragments are rendered as irregular closed polygons rather than simple points
- **Type-specific shapes**: Different fragment types (gravel, cobble, stone, boulder, channer, flagstone) have characteristic shape parameters
- **Multi-property encoding**: Fragment visualization encodes:
  - **Size**: Determined by size class (very fine → very coarse)
  - **Opacity**: Determined by fragment grade/cementation (weak → very strong)
  - **Shape irregularity**: Determined by fragment type
  - **Abundance**: Number of fragments per horizon determined by abundance descriptor

**Fragment Type Parameters:**

| Type | Vertices | Irregularity | Aspect Ratio | Description |
|------|----------|--------------|--------------|-------------|
| Gravel | 6 | 0.35 | 1.0 | Rounded, equant |
| Cobble | 7 | 0.25 | 1.1 | Slightly elongated, smooth |
| Stone | 5 | 0.40 | 1.3 | Angular, prominent edges |
| Boulder | 8 | 0.20 | 0.95 | Large, smooth, equant |
| Channer | 4 | 0.50 | 2.2 | Very flat, plate-like |
| Flagstone | 4 | 0.45 | 2.5 | Extremely flat, sheet-like |

**Usage:**

```r
library(soilgraph)

# Create a profile with coarse fragments
profile <- new_soil_profile(
    site_id = "pedon-001",
    horizons = list(
        new_soil_horizon(
            top = 0,
            bottom = 20,
            label = "A",
            color = "#8B7355",
            coarse_type = "gravel",      # Fragment type
            coarse_size = "medium",      # Size class
            coarse_abundance = "common", # Abundance
            coarse_grade = "moderate",   # Cementation/grade
            coarse_color = "#5A4A3A"     # Fragment color
        )
    )
)

# Render with fragment polygons
plot_soil_profile_advanced(profile, show_fragments = TRUE)
```

### 2. Horizon Boundary Engine (`R/graphics_boundaries.R`)

Generates irregular boundary lines between soil horizons, encoding boundary distinctness and topography.

**Key Features:**
- **Shape encoding**: Boundary topography (smooth, wavy, irregular, broken, discontinuous) is rendered as path distortion
- **Grade encoding**: Boundary distinctness (abrupt, clear, gradual, diffuse) is rendered as smoothing and line type
- **Transition zones**: Optional semi-transparent zones represent gradual/diffuse boundaries
- **Smooth mathematical generation**: Uses cumulative noise, windowing, and filtering for realistic boundaries

**Boundary Properties:**

| Property | Values | Visual Effect |
|----------|--------|---------------|
| Shape | smooth, wavy, irregular, broken, discontinuous | Path distortion pattern |
| Grade | abrupt, clear, gradual, diffuse | Line smoothing and thickness |

**Shape Distortion Patterns:**

- **smooth**: No distortion - straight line
- **wavy**: Regular sinusoidal variation (0.6 cm amplitude)
- **irregular**: Cumulative noise with mean-centering
- **broken**: Segmented with sharp discontinuities
- **discontinuous**: Patchy disturbances

**Usage:**

```r
# Profile with varied boundaries
profile <- new_soil_profile(
    site_id = "pedon-002",
    horizons = list(
        new_soil_horizon(
            top = 0,
            bottom = 20,
            label = "A",
            boundary_shape = "smooth",     # Boundary topography
            boundary_grade = "clear"       # Boundary distinctness
        ),
        new_soil_horizon(
            top = 20,
            bottom = 50,
            label = "Bt",
            boundary_shape = "wavy",
            boundary_grade = "gradual"     # Will show transition zone
        ),
        new_soil_horizon(
            top = 50,
            bottom = 95,
            label = "C",
            boundary_shape = "irregular",
            boundary_grade = "diffuse"     # Will show large transition zone
        )
    )
)

# Render with enhanced boundaries
plot_soil_profile_advanced(
    profile,
    show_boundaries = TRUE,
    show_transition_zones = TRUE
)
```

### 3. Visualization Utilities (`R/graphics_utils.R`)

Provides essential helper functions, validation, and theming for the graphical system.

**Key Utilities:**

- `is_valid_color()`: Validates color specifications
- `build_horizon_plot_data()`: Extracts and prepares horizon data for visualization
- `describe_soil_profile()`: Creates accessibility descriptions
- `validate_soil_profile()`: Ensures profile integrity
- `theme_soil_profile()`: Provides optimized ggplot2 theme
- `get_horizon_palette()`: Returns appropriate color palettes
- `create_fragment_encoding()`: Maps properties to visual attributes
- `create_boundary_encoding()`: Maps boundary properties to visual parameters
- `get_contrasting_text_color()`: Ensures text readability

**Usage:**

```r
# Validation
validate_soil_profile(profile)

# Get optimization theme
my_plot + theme_soil_profile(base_size = 14)

# Get appropriate color palette
colors <- get_horizon_palette(n = 3, palette = "Terrain 2")

# Get text color for given background
text_color <- get_contrasting_text_color("#8B7355")
```

## Advanced Plotting Functions

### `plot_soil_profile_advanced()`

The primary function for rendering profiles with all graphical engines.

**Parameters:**

```r
plot_soil_profile_advanced(
    profile,                      # soil_profile object
    show_fragments = TRUE,       # Render coarse fragments as polygons
    show_boundaries = TRUE,      # Render irregular boundaries
    show_transition_zones = TRUE,# Show gradual/diffuse transition zones
    seed = 1                     # Reproducible randomization
)
```

**Returns:** A `ggplot2` object

**Example:**

```r
# Full visualization with all features
plot_soil_profile_advanced(profile, seed = 123)

# Boundary-focused visualization
plot_soil_profile_advanced(
    profile,
    show_fragments = FALSE,
    show_transition_zones = TRUE
)

# Fragments-only visualization
plot_soil_profile_advanced(
    profile,
    show_boundaries = FALSE,
    show_transition_zones = FALSE
)
```

## Technical Details

### Fragment Shape Generation

Fragment shapes are generated procedurally:

1. **Base geometry**: Vertices arranged in regular polygon (n=4 to 8)
2. **Radius perturbation**: Each vertex's distance from center randomized by ±irregularity factor
3. **Aspect ratio application**: Y-coordinates scaled to represent type (e.g., channer elongation)
4. **Vertex noise**: Fine-grained noise added to create natural irregularity
5. **Polygon closure**: First and last points are identical to close the path

```
Fragment Shape Pipeline:
┌─────────────────────────────────────────┐
│ Fragment Properties                      │
│ (type, size, grade, color)              │
└──────────────┬──────────────────────────┘
               │
       ┌───────▼────────┐
       │ Type → Params  │
       │ Look-up table  │
       └───────┬────────┘
               │
       ┌───────▼──────────────────┐
       │ Generate base vertices   │
       │ at angles from center    │
       └───────┬──────────────────┘
               │
       ┌───────▼──────────────────┐
       │ Apply irregularity       │
       │ Random radius variation  │
       └───────┬──────────────────┘
               │
       ┌───────▼──────────────────┐
       │ Apply aspect ratio       │
       │ Elongate/compress        │
       └───────┬──────────────────┘
               │
       ┌───────▼──────────────────┐
       │ Add vertex noise         │
       │ Refine irregularity      │
       └───────┬──────────────────┘
               │
       ┌───────▼──────────────────┐
       │ Close polygon            │
       │ Duplicate first point    │
       └───────┬──────────────────┘
               │
       ┌───────▼────────────────┐
       │ Output: Polygon coords │
       │ for geom_polygon       │
       └────────────────────────┘
```

### Boundary Generation

Boundaries are generated with shape and grade encoding:

1. **Base path**: 200 x-coordinates evenly spaced from 0 to 1
2. **Shape distortion**: Type-specific y-offset pattern applied
3. **Grade smoothing**: Tukey smoothing window adjusted by grade
4. **Grade scaling**: Final distortion magnitude scaled by distinctness

```
Boundary Generation Pipeline:
┌──────────────────────────────┐
│ Boundary Properties          │
│ shape, grade, depth          │
└──────────┬───────────────────┘
           │
   ┌───────▼─────────┐
   │ Generate base   │
   │ x-coordinates   │
   └───────┬─────────┘
           │
   ┌───────▼──────────────────┐
   │ Apply shape distortion   │
   │ (smooth/wavy/irregular)  │
   └───────┬──────────────────┘
           │
   ┌───────▼──────────────────┐
   │ Smooth by window size    │
   │ based on grade           │
   └───────┬──────────────────┘
           │
   ┌───────▼──────────────────┐
   │ Scale by grade factor    │
   │ (abrupt=1.0, diffuse=0.15)
   └───────┬──────────────────┘
           │
   ┌───────▼──────────────────┐
   │ Output: Path coordinates │
   │ for geom_path           │
   └──────────────────────────┘
```

## Property Encoding Reference

### Coarse Fragment Size Classes

| Class | Marker Size | Polygon Role |
|-------|-------------|--------------|
| Very Fine | 1.0 | Small, detailed polygons |
| Fine | 1.3 | Modest-sized polygons |
| Small | 1.6 | Medium polygons |
| Medium | 2.0 | Standard polygon size |
| Coarse | 2.6 | Large polygons |
| Large | 3.2 | Very large polygons |
| Very Coarse | 3.8 | Maximum polygon size |

### Coarse Fragment Grade (Opacity)

| Grade | Alpha | Visual Effect |
|-------|-------|---------------|
| Very Weak | 0.30 | Faint, barely visible |
| Weak | 0.45 | Subtle, low contrast |
| Moderate | 0.65 | Standard, medium contrast |
| Strong | 0.82 | Prominent, high contrast |
| Very Strong | 0.95 | Highly salient, maximum contrast |

### Coarse Fragment Abundance

| Descriptor | Count | Visual Density |
|-----------|-------|-----------------|
| Very Few | 6 | Sparse distribution |
| Few | 10 | Light coverage |
| Common | 18 | Moderate coverage |
| Many | 30 | Dense coverage |
| Abundant | 42 | Very dense coverage |

## Examples

### Complete Example: Multi-Horizon Profile

```r
library(soilgraph)

# Create detailed profile
profile <- new_soil_profile(
    site_id = "Chile-Pedon-001",
    classification = list(
        system = "Soil Taxonomy",
        taxon = "Typic Hapludalf"
    ),
    metadata = list(
        country = "Chile",
        land_use = "cropland",
        slope_percent = 4
    ),
    horizons = list(
        new_soil_horizon(
            top = 0,
            bottom = 18,
            label = "Ap",
            texture = "silt loam",
            color = "#5C4033",
            moisture = "moist",
            boundary_grade = "clear",
            boundary_shape = "smooth",
            coarse_type = "gravel",
            coarse_shape = "subangular",
            coarse_abundance = "few",
            coarse_grade = "weak",
            coarse_size = "fine",
            coarse_color = "#3A322A",
            notes = "Granular structure"
        ),
        new_soil_horizon(
            top = 18,
            bottom = 52,
            label = "Bt1",
            texture = "clay loam",
            color = "#8A5A44",
            moisture = "moist",
            boundary_grade = "gradual",
            boundary_shape = "wavy",
            coarse_type = "cobble",
            coarse_shape = "rounded",
            coarse_abundance = "common",
            coarse_grade = "moderate",
            coarse_size = "medium",
            coarse_color = "#4A4238",
            coarse_percent = 15,
            notes = "Clay films on ped faces"
        ),
        new_soil_horizon(
            top = 52,
            bottom = 95,
            label = "Bt2",
            texture = "clay",
            color = "#A66A4C",
            moisture = "slightly moist",
            boundary_grade = "diffuse",
            boundary_shape = "irregular",
            coarse_type = "stone",
            coarse_shape = "subangular",
            coarse_abundance = "many",
            coarse_grade = "strong",
            coarse_size = "coarse",
            coarse_color = "#3A3228",
            coarse_percent = 25,
            notes = "Strong clay accumulation"
        )
    )
)

# Render advanced visualization
plot_soil_profile_advanced(profile, seed = 123)

# Save to file
ggplot2::ggsave("soil_profile_advanced.png", width = 8, height = 10, dpi = 300)
```

### Example: Comparing Different Rendering Modes

```r
# Basic rendering
p1 <- plot_soil_profile(profile)

# Fragment-focused
p2 <- plot_soil_profile_advanced(
    profile,
    show_boundaries = FALSE,
    show_transition_zones = FALSE
)

# Boundary-focused
p3 <- plot_soil_profile_advanced(
    profile,
    show_fragments = FALSE
)

# Full advanced
p4 <- plot_soil_profile_advanced(profile)

# Combine plots for comparison
gridExtra::grid.arrange(p1, p2, p3, p4, nrow = 2)
```

## Performance Considerations

- **Fragment generation**: O(n × m × v) where n = horizons, m = fragments/horizon, v = vertices/fragment
- **Boundary generation**: O(n × p) where n = boundaries, p = points/boundary (typically 200)
- **Randomization**: Controlled via seed parameter for reproducibility
- **Memory**: Fragment data scales with abundance; optimize for large profiles by reducing seed variation

## Integration with Existing Functions

The new engines integrate seamlessly with existing soilgraph functions:

- **`new_soil_horizon()`**: Accept enhanced coarse fragment properties
- **`soil_profile_from_table()`**: Automatically populate fragment properties from descriptions
- **`write_soil_json()`/`read_soil_json()`**: Preserve fragment properties in serialization
- **`plot_soil_description()`**: Unmodified; serves as basic rendering
- **`plot_soil_description_fragments()`**: Uses point-based rendering (original)
- **`plot_soil_profile_advanced()`**: New function; uses polygon-based rendering

## Future Enhancements

Potential extensions to the graphical engines:

1. **Pedogenic feature rendering**: Visual representation of redoximorphic features, iron-manganese concretions
2. **Root representation**: Stylized rendering of root distribution and density
3. **Pore space visualization**: Geometric representation of void structure
4. **Interactive exploration**: Shiny-based interactive profile exploration
5. **3D visualization**: Three-dimensional profile blocks with cross-sectional views
6. **Export formats**: Vector graphics (SVG), PDF, and 3D formats (OBJ, STL)

## References

- Soil Taxonomy (USDA): Official horizon boundary terminology
- A Glossary of Terms Used in Soil Survey: Consistence and structure terms
- World Reference Base (FAO): WRB-specific boundary characterization
