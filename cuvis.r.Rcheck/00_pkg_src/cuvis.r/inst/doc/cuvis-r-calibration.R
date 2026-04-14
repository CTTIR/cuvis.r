## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----init---------------------------------------------------------------------
# library(cuvis.r)
# 
# cuvis_init()
# 
# # Load the measurement session
# session <- cuvis_session("path/to/measurement.cu3s")
# mesu <- cuvis_get_measurement(session, 1)

## ----ctx----------------------------------------------------------------------
# ctx <- cuvis_processing_context(session, load_references = TRUE)
# 
# # Check which references were loaded
# cuvis_has_reference(ctx, "dark")
# cuvis_has_reference(ctx, "white")

## ----refs---------------------------------------------------------------------
# # Load dark reference
# dark_session <- cuvis_session("path/to/dark.cu3s")
# dark_mesu <- cuvis_get_measurement(dark_session, 1)
# cuvis_set_reference(ctx, dark_mesu, "dark")
# 
# # Load white reference
# white_session <- cuvis_session("path/to/white.cu3s")
# white_mesu <- cuvis_get_measurement(white_session, 1)
# cuvis_set_reference(ctx, white_mesu, "white")

## ----reprocess----------------------------------------------------------------
# cuvis_reprocess(ctx, mesu, mode = "reflectance")
# 
# # Extract the calibrated cube
# cube <- cuvis_get_cube(mesu)
# dim(cube)
# 
# # Reflectance values should be roughly in [0, 1]
# range(cube, na.rm = TRUE)

## ----compare------------------------------------------------------------------
# # Get raw data first
# mesu_raw <- cuvis_get_measurement(session, 1)
# cuvis_reprocess(ctx, mesu_raw, mode = "raw")
# cube_raw <- cuvis_get_cube(mesu_raw)
# 
# # Compare a single pixel spectrum
# pixel_raw <- cube_raw[50, 50, ]
# pixel_ref <- cube[50, 50, ]
# wavelengths <- attr(cube, "wavelengths")
# 
# plot(wavelengths, pixel_raw, type = "l", col = "gray",
#      xlab = "Wavelength (nm)", ylab = "Value",
#      main = "Raw vs Reflectance")
# par(new = TRUE)
# plot(wavelengths, pixel_ref, type = "l", col = "blue",
#      axes = FALSE, xlab = "", ylab = "")
# axis(4)
# legend("topright", c("Raw", "Reflectance"),
#        col = c("gray", "blue"), lty = 1)

## ----export-------------------------------------------------------------------
# # Export as ENVI (compatible with terra, stars, hsdar, etc.)
# cuvis_export_envi(mesu, "output/calibrated/")
# 
# # Export as multi-channel TIFF
# cuvis_export_tiff(mesu, "output/tiff/",
#                   format = "MultiChannel", compression = "LZW")

## ----shutdown-----------------------------------------------------------------
# cuvis_shutdown()

## ----hyperspectr--------------------------------------------------------------
# library(hyperspectR)
# 
# # Reads .cu3s files using cuvis.r internally
# cube <- hs_read_cubert("measurement.cu3s")
# 
# # Full hyperspectR analysis pipeline
# hs_plot_clinical(cube)

