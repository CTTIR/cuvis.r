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
wavelengths in nanometers; it is absent when the SDK buffer carries no
wavelengths.

## Details

The first index is the image row (the `y` coordinate of the SDK image
buffer, first image line first), the second the column (`x`) and the
third the band. Values are returned as doubles whatever the storage type
of the SDK buffer. Process the measurement with
[`cuvis_reprocess()`](https://cttir.github.io/cuvis.r/reference/cuvis_reprocess.md)
before extracting the cube, as in the example.

[`graphics::image()`](https://rdrr.io/r/graphics/image.html) draws the
first index of a matrix along the x axis from the bottom, so a band
shown with `image(cube[, , i])` appears rotated. See
[`vignette("cuvis-r-intro")`](https://cttir.github.io/cuvis.r/articles/cuvis-r-intro.md)
for a display with the image orientation.

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
