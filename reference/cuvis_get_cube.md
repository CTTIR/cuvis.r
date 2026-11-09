# Extract Hyperspectral Cube from a Measurement

Returns the 3D data cube as an R array with wavelength metadata.

## Usage

``` r
cuvis_get_cube(measurement)
```

## Arguments

- measurement:

  A cuvis_measurement object.

## Value

A numeric 3D array with dimensions `[rows, cols, bands]`. The
`"wavelengths"` attribute contains a numeric vector of band center
wavelengths in nanometers.

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
  cube <- cuvis_get_cube(mesu)
  dim(cube)
  range(attr(cube, "wavelengths"))
}
```
