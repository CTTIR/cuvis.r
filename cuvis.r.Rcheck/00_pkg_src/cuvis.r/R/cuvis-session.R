#' Load a Cubert Session File
#'
#' Opens a `.cu3s` session file containing one or more hyperspectral
#' measurements with their calibration references.
#'
#' @param path Character. Path to a `.cu3s` session file.
#'
#' @return A `cuvis_session` S3 object (wrapping an external pointer to the
#'   SDK session handle). Use [cuvis_get_measurement()] to extract individual
#'   measurements.
#'
#' @examples
#' \dontrun{
#' cuvis_init()
#' session <- cuvis_session("path/to/measurement.cu3s")
#' print(session)
#' cuvis_shutdown()
#' }
#' @export
cuvis_session <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  if (!grepl("\\.cu3s$", path, ignore.case = TRUE)) {
    cli_warn("File does not have .cu3s extension: {.path {path}}")
  }
  handle <- .Call("rcuvis_session_load", path)
  count <- .Call("rcuvis_session_get_size", handle,
                 cuvis_session_item_types[["no_gaps"]])

  structure(
    list(handle = handle, path = path, count = count),
    class = "cuvis_session"
  )
}

#' @export
print.cuvis_session <- function(x, ...) {
  cli_h3("CUVIS Session")
  cli_text("Path: {.path {x$path}}")
  cli_text("Measurements: {x$count}")
  invisible(x)
}

#' @export
length.cuvis_session <- function(x) x$count

#' @export
summary.cuvis_session <- function(object, ...) {
  cli_h3("CUVIS Session Summary")
  cli_text("File: {.path {basename(object$path)}}")
  cli_text("Measurements: {object$count}")
  for (i in seq_len(min(object$count, 10L))) {
    mesu <- cuvis_get_measurement(object, i)
    md <- cuvis_get_metadata(mesu)
    mode_name <- if (md$processing_mode >= 1L &&
                     md$processing_mode <= length(.proc_mode_names)) {
      .proc_mode_names[md$processing_mode]
    } else {
      "Unknown"
    }
    cli_text("  [{i}] {md$name} \u2014 {mode_name}, {md$integration_time} ms")
  }
  if (object$count > 10L) {
    cli_text("  ... and {object$count - 10L} more")
  }
  invisible(object)
}
