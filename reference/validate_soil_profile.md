# Validate a soil profile

Checks that the profile has valid horizons with correct depth ordering,
no overlapping layers, and each horizon's `bottom` is greater than its
`top`.

## Usage

``` r
validate_soil_profile(profile)
```

## Arguments

- profile:

  A `soil_profile` object.

## Value

The input profile, invisibly.

## Examples

``` r
h1 <- new_soil_horizon(0, 18, label = "Ap")
h2 <- new_soil_horizon(18, 52, label = "Bt1")
profile <- new_soil_profile("test", list(h1, h2))
validate_soil_profile(profile)
```
