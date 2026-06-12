# Calibration Workflow with cuvis.r

## Overview

This vignette demonstrates the full calibration pipeline for Cubert
hyperspectral data: loading raw measurements, setting dark and white
references, and reprocessing to calibrated reflectance.

## Calibration Pipeline

Cubert cameras capture raw sensor data that must be calibrated through
several stages: 1. **Raw** – unprocessed sensor readout 2. **Dark
subtract** – dark current noise removed 3. **Spectral radiance** –
calibrated to physical units (W/m^2/sr/nm) 4. **Reflectance** –
normalized by white reference (values 0–1)

## Step-by-Step Workflow

### 1. Initialize and Load Data

``` r

library(cuvis.r)

cuvis_init()

# Load the measurement session
session <- cuvis_session("path/to/measurement.cu3s")
mesu <- cuvis_get_measurement(session, 1)
```

### 2. Create Processing Context

The processing context holds calibration state and is created from the
session file. If the session already contains embedded references, they
are loaded automatically:

``` r

ctx <- cuvis_processing_context(session, load_references = TRUE)

# Check which references were loaded
cuvis_has_reference(ctx, "dark")
cuvis_has_reference(ctx, "white")
```

### 3. Set References (if needed)

If the session does not contain embedded references, load them from
separate files:

``` r

# Load dark reference
dark_session <- cuvis_session("path/to/dark.cu3s")
dark_mesu <- cuvis_get_measurement(dark_session, 1)
cuvis_set_reference(ctx, dark_mesu, "dark")

# Load white reference
white_session <- cuvis_session("path/to/white.cu3s")
white_mesu <- cuvis_get_measurement(white_session, 1)
cuvis_set_reference(ctx, white_mesu, "white")
```

### 4. Reprocess to Reflectance

``` r

cuvis_reprocess(ctx, mesu, mode = "reflectance")

# Extract the calibrated cube
cube <- cuvis_get_cube(mesu)
dim(cube)

# Reflectance values should be roughly in [0, 1]
range(cube, na.rm = TRUE)
```

### 5. Compare Processing Levels

``` r

# Get raw data first
mesu_raw <- cuvis_get_measurement(session, 1)
cuvis_reprocess(ctx, mesu_raw, mode = "raw")
cube_raw <- cuvis_get_cube(mesu_raw)

# Compare a single pixel spectrum
pixel_raw <- cube_raw[50, 50, ]
pixel_ref <- cube[50, 50, ]
wavelengths <- attr(cube, "wavelengths")

plot(wavelengths, pixel_raw, type = "l", col = "gray",
     xlab = "Wavelength (nm)", ylab = "Value",
     main = "Raw vs Reflectance")
par(new = TRUE)
plot(wavelengths, pixel_ref, type = "l", col = "blue",
     axes = FALSE, xlab = "", ylab = "")
axis(4)
legend("topright", c("Raw", "Reflectance"),
       col = c("gray", "blue"), lty = 1)
```

### 6. Export Calibrated Data

``` r

# Export as ENVI (compatible with terra, stars, hsdar, etc.)
cuvis_export_envi(mesu, "output/calibrated/")

# Export as multi-channel TIFF
cuvis_export_tiff(mesu, "output/tiff/",
                  format = "MultiChannel", compression = "LZW")
```

### 7. Shutdown

``` r

cuvis_shutdown()
```

## Integration with hyperspectR

If you have the [hyperspectR](https://github.com/r-heller/hyperspectR)
package installed, it uses cuvis.r as a backend:

``` r

library(hyperspectR)

# Reads .cu3s files using cuvis.r internally
cube <- hs_read_cubert("measurement.cu3s")

# Full hyperspectR analysis pipeline
hs_plot_clinical(cube)
```
