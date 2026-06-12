# Export a Measurement to ENVI Format

Writes the measurement data as an ENVI header/binary file pair.

## Usage

``` r
cuvis_export_envi(measurement, dir, permissive = TRUE)
```

## Arguments

- measurement:

  A cuvis_measurement object.

- dir:

  Character. Output directory.

- permissive:

  Logical. Allow export even if some data is missing. Default `TRUE`.

## Value

Invisible `dir`.
