# Get Wavelength Vector from a Measurement

Convenience function to extract just the wavelength vector from a
measurement's cube data.

## Usage

``` r
cuvis_get_wavelengths(measurement)
```

## Arguments

- measurement:

  A cuvis_measurement object.

## Value

Numeric vector of wavelengths in nm.

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)
  cuvis_reprocess(ctx, mesu, mode = "raw")
  head(cuvis_get_wavelengths(mesu))
}
```
