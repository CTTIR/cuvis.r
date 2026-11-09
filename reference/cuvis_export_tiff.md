# Export a Measurement to TIFF Format

Export a Measurement to TIFF Format

## Usage

``` r
cuvis_export_tiff(
  measurement,
  dir,
  format = c("MultiChannel", "Single", "MultiPage"),
  compression = c("None", "LZW"),
  permissive = TRUE,
  overwrite = FALSE
)
```

## Arguments

- measurement:

  A cuvis_measurement object.

- dir:

  Character. Output directory.

- format:

  Character. TIFF format: `"MultiChannel"` (default), `"Single"`, or
  `"MultiPage"`.

- compression:

  Character. Compression mode: `"None"` (default) or `"LZW"`.

- permissive:

  Logical. Default `TRUE`.

- overwrite:

  Logical. Default `FALSE` requires a new or empty output directory. Set
  `TRUE` only when replacement of existing output is intended.

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
  out <- cuvis_export_tiff(mesu, file.path(tempdir(), "cuvis-tiff"))
  list.files(out)
  unlink(out, recursive = TRUE)
}
```
