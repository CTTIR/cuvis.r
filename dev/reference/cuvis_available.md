# Check if CUVIS SDK is Available

Tests whether the Cubert CUVIS SDK library was linked at installation.
This does not initialize the SDK or verify calibration, sample data or
runtime usability. See
[`cuvis_is_initialized()`](https://cttir.github.io/cuvis.r/dev/reference/cuvis_is_initialized.md).

## Usage

``` r
cuvis_available()
```

## Value

Logical. `TRUE` if the SDK is available, `FALSE` otherwise.
