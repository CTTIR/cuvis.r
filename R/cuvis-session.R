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
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   print(session)
#'   length(session)
#' }
#' @export
cuvis_session <- function(path) {
  path <- .cuvis_path(path, "path")
  path <- normalizePath(path, mustWork = TRUE)
  if (!grepl("\\.cu3s$", path, ignore.case = TRUE)) {
    cli_warn("File does not have .cu3s extension: {.path {path}}")
  }
  handle <- .cuvis_sdk_call(.Call("rcuvis_session_load", path))
  count <- .cuvis_sdk_call(.Call("rcuvis_session_get_size", handle,
                                 cuvis_session_item_types[["no_gaps"]]))

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

#' Count Session Items by SDK Enumeration Type
#'
#' Asks the SDK how many items of a given type a session file holds.
#'
#' @param session A `cuvis_session` object from [cuvis_session()].
#' @param item_type Character. One of `"no_gaps"` (default), `"all_frames"`
#'   or `"references"`.
#' @return A single integer: the exact SDK count for the requested
#'   enumeration.
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   cuvis_session_count(session)
#'   cuvis_session_count(session, "references")
#' }
#' @export
cuvis_session_count <- function(session, item_type = "no_gaps") {
  stopifnot(inherits(session, "cuvis_session"))
  if (!is.character(item_type) || length(item_type) != 1L || is.na(item_type) ||
        !item_type %in% names(cuvis_session_item_types)) {
    cli::cli_abort("Unknown item_type.")
  }
  .cuvis_sdk_call(.Call("rcuvis_session_get_size", session$handle,
                        cuvis_session_item_types[[item_type]]))
}

#' Read the Nominal Frame Rate of a Session
#'
#' Returns the frame rate the SDK reports for a session file.
#'
#' @param session A `cuvis_session` object from [cuvis_session()].
#' @return A single positive number (frames per second) as reported by the
#'   SDK, or `NA` when unavailable. It is never derived from timestamps.
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   cuvis_session_fps(session)
#' }
#' @export
cuvis_session_fps <- function(session) {
  stopifnot(inherits(session, "cuvis_session"))
  fps <- .cuvis_sdk_call(.Call("rcuvis_session_get_fps", session$handle))
  if (length(fps) != 1L || !is.finite(fps) || fps <= 0) {
    return(NA_real_)
  }
  fps
}
