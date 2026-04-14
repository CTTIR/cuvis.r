## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----install------------------------------------------------------------------
# remotes::install_github("r-heller/cuvis.r")

## ----init---------------------------------------------------------------------
# library(cuvis.r)
# 
# cuvis_init()

## ----load---------------------------------------------------------------------
# session <- cuvis_session("path/to/measurement.cu3s")
# print(session)

## ----mesu---------------------------------------------------------------------
# mesu <- cuvis_get_measurement(session, 1)
# print(mesu)

## ----metadata-----------------------------------------------------------------
# md <- cuvis_get_metadata(mesu)
# md$name
# md$integration_time
# md$serial_number
# md$product_name

## ----cube---------------------------------------------------------------------
# # First, process to generate the cube
# ctx <- cuvis_processing_context(session)
# cuvis_reprocess(ctx, mesu, mode = "raw")
# 
# cube <- cuvis_get_cube(mesu)
# dim(cube)                        # e.g., c(100, 100, 61)
# attr(cube, "wavelengths")        # wavelengths in nm

## ----ops----------------------------------------------------------------------
# # Mean reflectance per band
# band_means <- apply(cube, 3, mean, na.rm = TRUE)
# 
# # Extract a single band (e.g., band 30)
# single_band <- cube[, , 30]
# image(single_band, main = "Band 30")

## ----export-------------------------------------------------------------------
# # ENVI format (widely supported by remote sensing tools)
# cuvis_export_envi(mesu, "output/envi/")
# 
# # Multi-channel TIFF
# cuvis_export_tiff(mesu, "output/tiff/")

## ----shutdown-----------------------------------------------------------------
# cuvis_shutdown()

