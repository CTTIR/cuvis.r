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
