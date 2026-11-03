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
