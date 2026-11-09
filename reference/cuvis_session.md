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
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  print(session)
  length(session)
}
```
