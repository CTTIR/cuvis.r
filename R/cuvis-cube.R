#' Extract Hyperspectral Cube from a Measurement
#'
#' Returns the 3D data cube as an R array with wavelength metadata.
#'
#' @param measurement A cuvis_measurement object.
#'
#' @return A numeric 3D array with dimensions `[rows, cols, bands]`.
#'   The `"wavelengths"` attribute contains a numeric vector of band center
#'   wavelengths in nanometers.
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
  stopifnot(inherits(measurement, "cuvis_measurement"))
  .cuvis_sdk_call(.Call("rcuvis_mesu_get_cube", measurement$handle))
}

#' Get Wavelength Vector from a Measurement
#'
#' Convenience function to extract just the wavelength vector from a
#' measurement's cube data.
#'
#' @param measurement A cuvis_measurement object.
#' @return Numeric vector of wavelengths in nm.
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
