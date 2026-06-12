# CUVIS Reference Types

Named integer vector of reference types matching the CUVIS SDK C enum
values. Used by
[`cuvis_set_reference()`](https://cttir.github.io/cuvis.r/reference/cuvis_set_reference.md).

## Usage

``` r
cuvis_reference_types
```

## Format

An object of class `integer` of length 5.

## Details

- `Dark` (0): Dark reference frame

- `White` (1): White reference frame

- `WhiteDark` (2): Dark reference for the white reference

- `SpRad` (3): Spectral radiance calibration

- `Distance` (4): Distance calibration
