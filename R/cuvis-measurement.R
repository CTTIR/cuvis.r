#' Get a Measurement from a Session
#'
#' Extracts a single measurement from a session file by index.
#'
#' @param session A cuvis_session object.
#' @param index Integer. 1-based measurement index.
#' @param item_type Character. Type of items to enumerate: `"no_gaps"`
#'   (default), `"all_frames"`, or `"references"`.
#'
#' @return A `cuvis_measurement` S3 object, or `NULL` if no measurement
#'   exists at that index.
#' @export
cuvis_get_measurement <- function(session, index = 1L,
                                  item_type = "no_gaps") {
  stopifnot(inherits(session, "cuvis_session"))
  index <- as.integer(index)
  if (index < 1L || index > session$count) {
    cli_abort("Index {index} out of range [1, {session$count}].")
  }
  itype <- cuvis_session_item_types[[item_type]]
  if (is.null(itype)) {
    cli_abort("Unknown item_type: {.val {item_type}}. Use 'no_gaps', 'all_frames', or 'references'.")
  }
  # Convert to 0-based for C
  handle <- .Call("rcuvis_session_get_mesu", session$handle,
                  index - 1L, itype)
  if (is.null(handle)) {
    return(NULL)
  }
  structure(
    list(handle = handle, session_path = session$path, index = index),
    class = "cuvis_measurement"
  )
}

#' Get Measurement Metadata
#'
#' Returns metadata fields for a measurement including name, integration time,
#' serial number, processing mode, and more.
#'
#' @param measurement A cuvis_measurement object.
#' @return A named list with fields: `name`, `path`, `comment`,
#'   `integration_time` (ms), `averages`, `distance`, `serial_number`,
#'   `product_name`, `assembly`, `processing_mode` (integer),
#'   `capture_time` (ms since epoch), `measurement_flags` (integer).
#' @export
cuvis_get_metadata <- function(measurement) {
  stopifnot(inherits(measurement, "cuvis_measurement"))
  .Call("rcuvis_mesu_get_metadata", measurement$handle)
}

#' @export
print.cuvis_measurement <- function(x, ...) {
  md <- cuvis_get_metadata(x)
  mode_name <- if (md$processing_mode >= 1L &&
                   md$processing_mode <= length(.proc_mode_names)) {
    .proc_mode_names[md$processing_mode]
  } else {
    "Unknown"
  }
  cli_h3("CUVIS Measurement")
  cli_text("Name: {md$name}")
  cli_text("Integration time: {md$integration_time} ms")
  cli_text("Processing mode: {mode_name}")
  cli_text("Serial number: {md$serial_number}")
  invisible(x)
}

#' @export
summary.cuvis_measurement <- function(object, ...) {
  md <- cuvis_get_metadata(object)
  mode_name <- if (md$processing_mode >= 1L &&
                   md$processing_mode <= length(.proc_mode_names)) {
    .proc_mode_names[md$processing_mode]
  } else {
    "Unknown"
  }
  cli_h3("CUVIS Measurement Summary")
  cli_text("Name: {md$name}")
  cli_text("Path: {.path {md$path}}")
  cli_text("Comment: {md$comment}")
  cli_text("Integration time: {md$integration_time} ms")
  cli_text("Averages: {md$averages}")
  cli_text("Processing mode: {mode_name}")
  cli_text("Product: {md$product_name}")
  cli_text("Serial: {md$serial_number}")
  cli_text("Assembly: {md$assembly}")
  invisible(object)
}
