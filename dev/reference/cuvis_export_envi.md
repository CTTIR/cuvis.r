# Export a Measurement to ENVI Format

Writes the measurement data as an ENVI header/binary file pair.

## Usage

``` r
cuvis_export_envi(measurement, dir, permissive = TRUE, overwrite = FALSE)
```

## Arguments

- measurement:

  A cuvis_measurement object.

- dir:

  Character. Output directory.

- permissive:

  Logical. Allow export even if some data is missing. Default `TRUE`.

- overwrite:

  Logical. Default `FALSE` requires a new or empty output directory. Set
  `TRUE` only when replacement of existing output is intended.

## Value

Invisible `dir`.
