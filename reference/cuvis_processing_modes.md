# CUVIS Processing Modes

Named integer vector of processing modes matching the CUVIS SDK C enum
values. Used internally by
[`cuvis_reprocess()`](https://cttir.github.io/cuvis.r/reference/cuvis_reprocess.md).

## Usage

``` r
cuvis_processing_modes
```

## Format

A named integer vector of length 5.

## Value

A named integer vector mapping mode names to SDK enum values.

## Details

- `Raw` (0): Raw sensor data, no processing

- `DarkSubtract` (1): Dark current subtracted

- `Reflectance` (2): Normalized reflectance (0-1)

- `SpectralRadiance` (3): Calibrated to physical radiance (W/m^2/sr/nm)

- `Preview` (5): Low-resolution preview only

## Examples

``` r
cuvis_processing_modes
#>              Raw     DarkSubtract      Reflectance SpectralRadiance 
#>                0                1                2                3 
#>          Preview 
#>                5 
names(cuvis_processing_modes)
#> [1] "Raw"              "DarkSubtract"     "Reflectance"      "SpectralRadiance"
#> [5] "Preview"         
```
