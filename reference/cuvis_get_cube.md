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
if (FALSE) { # \dontrun{
cuvis_init()
session <- cuvis_session("path/to/file.cu3s")
mesu <- cuvis_get_measurement(session, 1)
cube <- cuvis_get_cube(mesu)
dim(cube)                        # e.g., c(100, 100, 61)
attr(cube, "wavelengths")        # wavelengths in nm
cuvis_shutdown()
} # }
```
