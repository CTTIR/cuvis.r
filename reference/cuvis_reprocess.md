# Reprocess a Measurement to a New Calibration Level

Applies processing context settings to a measurement, converting it to
the requested calibration level (e.g., reflectance).

## Usage

``` r
cuvis_reprocess(
  ctx,
  measurement,
  mode = c("reflectance", "spectral_radiance", "dark_subtract", "raw", "preview"),
  allow_recalib = FALSE
)
```

## Arguments

- ctx:

  A cuvis_processing_context with references set.

- measurement:

  A cuvis_measurement to reprocess.

- mode:

  Character. Target processing mode: `"reflectance"` (default),
  `"spectral_radiance"`, `"dark_subtract"`, `"raw"`, or `"preview"`.

- allow_recalib:

  Logical. Allow recalibration if needed. Default `FALSE`.

## Value

The same cuvis_measurement object, reprocessed in place. Extract the
cube with
[`cuvis_get_cube()`](https://cttir.github.io/cuvis.r/reference/cuvis_get_cube.md).

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
  if (cuvis_has_reference(ctx, "dark") && cuvis_has_reference(ctx, "white")) {
    cuvis_reprocess(ctx, mesu, mode = "reflectance")
  }
}
```
