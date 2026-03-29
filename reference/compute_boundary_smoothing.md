# Apply boundary grade-based smoothing

Modulates distortion magnitude based on distinctness grade. Abrupt
boundaries have sharper transitions, gradual/diffuse are smoother.

## Usage

``` r
compute_boundary_smoothing(distortion, grade = "clear", seed = 1)
```

## Arguments

- distortion:

  Numeric vector of distortions

- grade:

  Character: boundary grade

- seed:

  Random seed

## Value

Numeric vector of smoothed distortions
