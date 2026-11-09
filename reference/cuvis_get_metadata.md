# Get Measurement Metadata

Returns metadata fields for a measurement including name, integration
time, serial number, processing mode, and more.

## Usage

``` r
cuvis_get_metadata(measurement)
```

## Arguments

- measurement:

  A cuvis_measurement object.

## Value

A named list with fields: `name`, `path`, `comment`, `integration_time`
(ms), `averages`, `distance`, `serial_number`, `product_name`,
`assembly`, `processing_mode` (integer), `capture_time` (ms since
epoch), `measurement_flags` (integer).

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  mesu <- cuvis_get_measurement(session, 1)
  str(cuvis_get_metadata(mesu))
}
```
