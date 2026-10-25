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
    mode_name <- .get_proc_mode_name(md$processing_mode)
    cli_text("  [{i}] {md$name} \u2014 {mode_name}, {md$integration_time} ms")
  }
  if (object$count > 10L) {
    cli_text("  ... and {object$count - 10L} more")
  }
  invisible(object)
}

#' Count session items by SDK enumeration type
#' @param session A cuvis_session.
#' @param item_type One of no_gaps, all_frames, references.
#' @return Exact SDK count for the requested enumeration.
#' @export
cuvis_session_count <- function(session, item_type = "no_gaps") {
  stopifnot(inherits(session, "cuvis_session"))
  if (length(item_type) != 1L || is.na(item_type) ||
        !item_type %in% names(cuvis_session_item_types)) {
    cli::cli_abort("Unknown item_type.")
  }
  .Call("rcuvis_session_get_size", session$handle,
        cuvis_session_item_types[[item_type]])
}

#' Read source nominal session frame rate
#' @param session A cuvis_session.
#' @return Positive SDK FPS or NA when unavailable. Never derived from
#' timestamps.
#' @export
cuvis_session_fps <- function(session) {
  stopifnot(inherits(session, "cuvis_session"))
  fps <- .Call("rcuvis_session_get_fps", session$handle)
  if (length(fps) != 1L || !is.finite(fps) || fps <= 0) {
    return(NA_real_)
  }
  fps
}
