# Construct a soil horizon

Construct a soil horizon

## Usage

``` r
new_soil_horizon(
  top,
  bottom,
  label = NULL,
  texture = NULL,
  color = NULL,
  moisture = NULL,
  boundary_grade = NULL,
  boundary_shape = NULL,
  coarse_abundance = NULL,
  coarse_shape = NULL,
  coarse_grade = NULL,
  coarse_type = NULL,
  coarse_size = NULL,
  coarse_color = NULL,
  coarse_percent = NULL,
  notes = NULL
)
```

## Arguments

- top:

  Top depth in centimeters.

- bottom:

  Bottom depth in centimeters.

- label:

  Horizon label, such as `A` or `Bt1`.

- texture:

  Optional texture description.

- color:

  Optional display color or color description.

- moisture:

  Optional moisture state.

- boundary_grade:

  Optional horizon boundary distinctness.

- boundary_shape:

  Optional horizon boundary topography.

- coarse_abundance:

  Optional coarse fragment abundance.

- coarse_shape:

  Optional coarse fragment shape.

- coarse_grade:

  Optional coarse fragment grade.

- coarse_type:

  Optional coarse fragment type.

- coarse_size:

  Optional coarse fragment size class.

- coarse_color:

  Optional coarse fragment color.

- coarse_percent:

  Optional coarse fragment proportion (0-100).

- notes:

  Optional free-text notes.

## Value

A `soil_horizon` object.
