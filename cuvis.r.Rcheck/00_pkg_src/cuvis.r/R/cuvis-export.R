#' Export a Measurement to ENVI Format
#'
#' Writes the measurement data as an ENVI header/binary file pair.
#'
#' @param measurement A cuvis_measurement object.
#' @param dir Character. Output directory.
#' @param permissive Logical. Allow export even if some data is missing.
#'   Default `TRUE`.
#'
#' @return Invisible `dir`.
#' @export
cuvis_export_envi <- function(measurement, dir, permissive = TRUE) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  dir <- normalizePath(dir, mustWork = FALSE)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  exp_handle <- .Call("rcuvis_exporter_create_envi", dir,
                      as.logical(permissive))
  .Call("rcuvis_exporter_apply", exp_handle, measurement$handle)
  invisible(dir)
}

#' Export a Measurement to TIFF Format
#'
#' @param measurement A cuvis_measurement object.
#' @param dir Character. Output directory.
#' @param format Character. TIFF format: `"MultiChannel"` (default),
#'   `"Single"`, or `"MultiPage"`.
#' @param compression Character. Compression mode: `"None"` (default)
#'   or `"LZW"`.
#' @param permissive Logical. Default `TRUE`.
#'
#' @return Invisible `dir`.
#' @export
cuvis_export_tiff <- function(measurement, dir,
                              format = c("MultiChannel", "Single", "MultiPage"),
                              compression = c("None", "LZW"),
                              permissive = TRUE) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  format <- match.arg(format)
  compression <- match.arg(compression)
  dir <- normalizePath(dir, mustWork = FALSE)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  fmt_int <- cuvis_tiff_formats[[format]]
  comp_int <- cuvis_tiff_compression[[compression]]
  exp_handle <- .Call("rcuvis_exporter_create_tiff", dir, fmt_int, comp_int,
                      as.logical(permissive))
  .Call("rcuvis_exporter_apply", exp_handle, measurement$handle)
  invisible(dir)
}

#' Export a Measurement to a New Session File
#'
#' Saves the measurement as a new `.cu3s` session file.
#'
#' @param measurement A cuvis_measurement object.
#' @param dir Character. Output directory for the `.cu3s` file.
#' @param permissive Logical. Default `TRUE`.
#'
#' @return Invisible `dir`.
#' @export
cuvis_export_session <- function(measurement, dir, permissive = TRUE) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  dir <- normalizePath(dir, mustWork = FALSE)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  exp_handle <- .Call("rcuvis_exporter_create_cube", dir,
                      as.logical(permissive))
  .Call("rcuvis_exporter_apply", exp_handle, measurement$handle)
  invisible(dir)
}
