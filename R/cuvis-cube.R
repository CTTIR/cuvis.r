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
#' \dontrun{
#' cuvis_init()
#' session <- cuvis_session("path/to/file.cu3s")
#' mesu <- cuvis_get_measurement(session, 1)
#' cube <- cuvis_get_cube(mesu)
#' dim(cube)                        # e.g., c(100, 100, 61)
#' attr(cube, "wavelengths")        # wavelengths in nm
#' cuvis_shutdown()
#' }
#' @export
cuvis_get_cube <- function(measurement) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  .Call("rcuvis_mesu_get_cube", measurement$handle)
}

#' Get Wavelength Vector from a Measurement
#'
#' Convenience function to extract just the wavelength vector from a
#' measurement's cube data.
#'
#' @param measurement A cuvis_measurement object.
#' @return Numeric vector of wavelengths in nm.
#' @export
cuvis_get_wavelengths <- function(measurement) {
  cube <- cuvis_get_cube(measurement)
  attr(cube, "wavelengths")
}
