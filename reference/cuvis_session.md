# Load a Cubert Session File

Opens a `.cu3s` session file containing one or more hyperspectral
measurements with their calibration references.

## Usage

``` r
cuvis_session(path)
```

## Arguments

- path:

  Character. Path to a `.cu3s` session file.

## Value

A `cuvis_session` S3 object (wrapping an external pointer to the SDK
session handle). Use
[`cuvis_get_measurement()`](https://cttir.github.io/cuvis.r/reference/cuvis_get_measurement.md)
to extract individual measurements.

## Examples

``` r
if (FALSE) { # \dontrun{
cuvis_init()
session <- cuvis_session("path/to/measurement.cu3s")
print(session)
cuvis_shutdown()
} # }
```
