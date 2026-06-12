# CUVIS Processing Modes

Named integer vector of processing modes matching the CUVIS SDK C enum
values. Used internally by
[`cuvis_reprocess()`](https://cttir.github.io/cuvis.r/reference/cuvis_reprocess.md).

## Usage

``` r
cuvis_processing_modes
```

## Format

An object of class `integer` of length 5.

## Details

- `Raw` (0): Raw sensor data, no processing

- `DarkSubtract` (1): Dark current subtracted

- `Reflectance` (2): Normalized reflectance (0-1)

- `SpectralRadiance` (3): Calibrated to physical radiance (W/m^2/sr/nm)

- `Preview` (5): Low-resolution preview only
