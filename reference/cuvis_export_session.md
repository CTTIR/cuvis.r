# Export a Measurement to a New Session File

Saves the measurement as a new `.cu3s` session file.

## Usage

``` r
cuvis_export_session(measurement, dir, permissive = TRUE, overwrite = FALSE)
```

## Arguments

- measurement:

  A cuvis_measurement object.

- dir:

  Character. Output directory for the `.cu3s` file.

- permissive:

  Logical. Default `TRUE`.

- overwrite:

  Logical. Default `FALSE` requires a new or empty output directory and
  disables SDK file replacement. Set `TRUE` only when replacement of
  existing output is intended.

## Value

Invisible `dir`.

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
  out <- cuvis_export_session(mesu, file.path(tempdir(), "cuvis-cu3s"))
  list.files(out)
  unlink(out, recursive = TRUE)
}
```
