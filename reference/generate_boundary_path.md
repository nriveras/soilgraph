# Horizon Boundary Engine

Generates irregular boundary lines between soil horizons based on
descriptive properties like boundary grade (distinctness) and shape
(topography). Generate a single irregular boundary line

## Usage

``` r
generate_boundary_path(
  depth_cm,
  boundary_shape = "smooth",
  boundary_grade = "clear",
  x_range = c(0, 1),
  seed = 1,
  boundary_id = "boundary"
)
```

## Arguments

- depth_cm:

  Numeric depth value (y-coordinate) of the boundary

- boundary_shape:

  Character: "smooth", "wavy", "irregular", "broken", "discontinuous"

- boundary_grade:

  Character: "abrupt", "clear", "gradual", "diffuse"

- x_range:

  Numeric vector of length 2: x-coordinate range (default: 0 to 1)

- seed:

  Random seed for reproducible generation

- boundary_id:

  Character: unique identifier for the boundary

## Value

Data frame with columns: x, y, boundary_id

## Details

Creates a path representing the boundary between two soil horizons with
irregularity based on boundary_shape and boundary_grade properties.
