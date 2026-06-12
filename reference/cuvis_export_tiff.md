# Export a Measurement to TIFF Format

Export a Measurement to TIFF Format

## Usage

``` r
cuvis_export_tiff(
  measurement,
  dir,
  format = c("MultiChannel", "Single", "MultiPage"),
  compression = c("None", "LZW"),
  permissive = TRUE
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

## Value

Invisible `dir`.
