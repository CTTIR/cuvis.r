#' Extract Hyperspectral Cube from a Measurement
#'
#' Returns the 3D data cube as an R array with wavelength metadata.
#'
#' @param measurement A cuvis_measurement object.
#'
#' @details
#' The first index is the image row (the `y` coordinate of the SDK image
#' buffer, first image line first), the second the column (`x`) and the third
#' the band. Values are returned as doubles whatever the storage type of the
#' SDK buffer. Process the measurement with [cuvis_reprocess()] before
#' extracting the cube, as in the example.
#'
#' [graphics::image()] draws the first index of a matrix along the x axis from
#' the bottom, so a band shown with `image(cube[, , i])` appears rotated. See
#' `vignette("cuvis-r-intro")` for a display with the image orientation.
#'
#' @return A numeric 3D array with dimensions `[rows, cols, bands]`.
#'   The `"wavelengths"` attribute contains a numeric vector of band center
#'   wavelengths in nanometers; it is absent when the SDK buffer carries no
#'   wavelengths.
#'
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   mesu <- cuvis_get_measurement(session, 1)
#'   ctx <- cuvis_processing_context(session)
#'   cuvis_reprocess(ctx, mesu, mode = "raw")
#'   cube <- cuvis_get_cube(mesu)
#'   dim(cube)
#'   range(attr(cube, "wavelengths"))
#' }
#' @export
cuvis_get_cube <- function(measurement) {
  .cuvis_check_class(measurement, "cuvis_measurement", "measurement")
  .cuvis_sdk_call(.Call("rcuvis_mesu_get_cube", measurement$handle))
}

#' Get Wavelength Vector from a Measurement
#'
#' Convenience function to extract just the wavelength vector from a
#' measurement's cube data.
#'
#' @param measurement A cuvis_measurement object.
#' @return Numeric vector of wavelengths in nm, or `NULL` when the SDK buffer
#'   carries no wavelengths.
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   mesu <- cuvis_get_measurement(session, 1)
#'   ctx <- cuvis_processing_context(session)
#'   cuvis_reprocess(ctx, mesu, mode = "raw")
#'   head(cuvis_get_wavelengths(mesu))
#' }
#' @export
cuvis_get_wavelengths <- function(measurement) {
  cube <- cuvis_get_cube(measurement)
  attr(cube, "wavelengths")
}
