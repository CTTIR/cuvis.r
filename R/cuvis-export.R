#' Export a Measurement to ENVI Format
#'
#' Writes the measurement data as an ENVI header/binary file pair.
#'
#' @param measurement A cuvis_measurement object.
#' @param dir Character. Output directory.
#' @param permissive Logical. Allow export even if some data is missing.
#'   Default `TRUE`.
#' @param overwrite Logical. Default `FALSE` requires a new or empty output
#'   directory. Set `TRUE` only when replacement of existing output is intended.
#'
#' @return Invisible `dir`.
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   mesu <- cuvis_get_measurement(session, 1)
#'   ctx <- cuvis_processing_context(session)
#'   cuvis_reprocess(ctx, mesu, mode = "raw")
#'   out <- cuvis_export_envi(mesu, file.path(tempdir(), "cuvis-envi"))
#'   list.files(out)
#'   unlink(out, recursive = TRUE)
#' }
#' @export
cuvis_export_envi <- function(measurement, dir, permissive = TRUE,
                              overwrite = FALSE) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  .cuvis_flag(permissive, "permissive")
  dir <- .cuvis_export_dir(dir, overwrite)
  exp_handle <- .Call("rcuvis_exporter_create_envi", dir,
                      as.logical(permissive))
  .cuvis_export_apply(exp_handle, measurement$handle)
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
#' @param overwrite Logical. Default `FALSE` requires a new or empty output
#'   directory. Set `TRUE` only when replacement of existing output is intended.
#'
#' @return Invisible `dir`.
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   mesu <- cuvis_get_measurement(session, 1)
#'   ctx <- cuvis_processing_context(session)
#'   cuvis_reprocess(ctx, mesu, mode = "raw")
#'   out <- cuvis_export_tiff(mesu, file.path(tempdir(), "cuvis-tiff"))
#'   list.files(out)
#'   unlink(out, recursive = TRUE)
#' }
#' @export
cuvis_export_tiff <- function(measurement, dir,
                              format = c("MultiChannel", "Single", "MultiPage"),
                              compression = c("None", "LZW"),
                              permissive = TRUE, overwrite = FALSE) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  format <- match.arg(format)
  compression <- match.arg(compression)
  .cuvis_flag(permissive, "permissive")
  dir <- .cuvis_export_dir(dir, overwrite)
  fmt_int <- cuvis_tiff_formats[[format]]
  comp_int <- cuvis_tiff_compression[[compression]]
  exp_handle <- .Call("rcuvis_exporter_create_tiff", dir, fmt_int, comp_int,
                      as.logical(permissive))
  .cuvis_export_apply(exp_handle, measurement$handle)
  invisible(dir)
}

#' Export a Measurement to a New Session File
#'
#' Saves the measurement as a new `.cu3s` session file.
#'
#' @param measurement A cuvis_measurement object.
#' @param dir Character. Output directory for the `.cu3s` file.
#' @param permissive Logical. Default `TRUE`.
#' @param overwrite Logical. Default `FALSE` requires a new or empty output
#'   directory and disables SDK file replacement. Set `TRUE` only when
#'   replacement of existing output is intended.
#'
#' @return Invisible `dir`.
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   mesu <- cuvis_get_measurement(session, 1)
#'   ctx <- cuvis_processing_context(session)
#'   cuvis_reprocess(ctx, mesu, mode = "raw")
#'   out <- cuvis_export_session(mesu, file.path(tempdir(), "cuvis-cu3s"))
#'   list.files(out)
#'   unlink(out, recursive = TRUE)
#' }
#' @export
cuvis_export_session <- function(measurement, dir, permissive = TRUE,
                                 overwrite = FALSE) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  .cuvis_flag(permissive, "permissive")
  dir <- .cuvis_export_dir(dir, overwrite)
  exp_handle <- .Call("rcuvis_exporter_create_cube", dir,
                      as.logical(permissive), overwrite)
  .cuvis_export_apply(exp_handle, measurement$handle)
  invisible(dir)
}

# Always release promptly. Preserve a primary apply/flush error if cleanup also
# fails, while reporting the cleanup failure separately.
.cuvis_export_apply <- function(exporter, measurement) {
  closed <- FALSE
  on.exit({
    if (!closed) {
      tryCatch(.Call("rcuvis_exporter_close", exporter), error = function(e) {
        cli::cli_warn("Exporter cleanup failed: {conditionMessage(e)}")
      })
    }
  }, add = TRUE)
  .Call("rcuvis_exporter_apply", exporter, measurement)
  .Call("rcuvis_exporter_close", exporter)
  closed <- TRUE
  invisible(NULL)
}
