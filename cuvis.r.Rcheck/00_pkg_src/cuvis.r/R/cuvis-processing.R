#' Create a Processing Context for Calibration
#'
#' Creates a processing context from a session file or measurement. This
#' context holds calibration references and processing parameters for
#' reprocessing measurements.
#'
#' @param base A cuvis_session or cuvis_measurement object.
#' @param load_references Logical. If `TRUE` (default), automatically loads
#'   references embedded in the session file.
#'
#' @return A `cuvis_processing_context` S3 object.
#' @export
cuvis_processing_context <- function(base, load_references = TRUE) {
  if (inherits(base, "cuvis_session")) {
    handle <- .Call("rcuvis_proc_create_from_session", base$handle,
                    as.logical(load_references))
  } else if (inherits(base, "cuvis_measurement")) {
    handle <- .Call("rcuvis_proc_create_from_mesu", base$handle,
                    as.logical(load_references))
  } else {
    cli_abort("Expected a {.cls cuvis_session} or {.cls cuvis_measurement} object.")
  }
  structure(
    list(handle = handle, references = list()),
    class = "cuvis_processing_context"
  )
}

#' Set a Calibration Reference
#'
#' Assigns a reference measurement (dark, white, etc.) to a processing context.
#'
#' @param ctx A cuvis_processing_context object.
#' @param measurement A cuvis_measurement object (the reference frame).
#' @param type Character. One of `"dark"`, `"white"`, `"white_dark"`,
#'   `"sprad"`, or `"distance"`.
#'
#' @return Invisible `ctx` (modified in place via external pointer).
#' @export
cuvis_set_reference <- function(ctx, measurement,
                                type = c("dark", "white", "white_dark",
                                         "sprad", "distance")) {
  stopifnot(inherits(ctx, "cuvis_processing_context"))
  stopifnot(inherits(measurement, "cuvis_measurement"))
  type <- match.arg(type)
  type_int <- .ref_type_lookup[[type]]
  .Call("rcuvis_proc_set_reference", ctx$handle, measurement$handle,
        type_int)
  ctx$references[[type]] <- TRUE
  invisible(ctx)
}

#' Check if a Reference is Set
#'
#' @param ctx A cuvis_processing_context object.
#' @param type Character. Reference type to check.
#' @return Logical.
#' @export
cuvis_has_reference <- function(ctx,
                                type = c("dark", "white", "white_dark",
                                         "sprad", "distance")) {
  stopifnot(inherits(ctx, "cuvis_processing_context"))
  type <- match.arg(type)
  type_int <- .ref_type_lookup[[type]]
  .Call("rcuvis_proc_has_reference", ctx$handle, type_int)
}

#' Reprocess a Measurement to a New Calibration Level
#'
#' Applies processing context settings to a measurement, converting it to the
#' requested calibration level (e.g., reflectance).
#'
#' @param ctx A cuvis_processing_context with references set.
#' @param measurement A cuvis_measurement to reprocess.
#' @param mode Character. Target processing mode: `"reflectance"` (default),
#'   `"spectral_radiance"`, `"dark_subtract"`, `"raw"`, or `"preview"`.
#' @param allow_recalib Logical. Allow recalibration if needed. Default `FALSE`.
#'
#' @return The same cuvis_measurement object, reprocessed in place.
#'   Extract the cube with [cuvis_get_cube()].
#' @export
cuvis_reprocess <- function(ctx, measurement,
                            mode = c("reflectance", "spectral_radiance",
                                     "dark_subtract", "raw", "preview"),
                            allow_recalib = FALSE) {
  stopifnot(inherits(ctx, "cuvis_processing_context"))
  stopifnot(inherits(measurement, "cuvis_measurement"))
  mode <- match.arg(mode)
  mode_int <- .proc_mode_lookup[[mode]]
  .Call("rcuvis_proc_set_args", ctx$handle, mode_int,
        as.logical(allow_recalib))
  .Call("rcuvis_proc_apply", ctx$handle, measurement$handle)
  invisible(measurement)
}

#' @export
print.cuvis_processing_context <- function(x, ...) {
  cli_h3("CUVIS Processing Context")
  refs <- names(x$references[vapply(x$references, isTRUE, logical(1))])
  if (length(refs) > 0) {
    cli_text("References set: {paste(refs, collapse = ', ')}")
  } else {
    cli_text("No explicit references set (may have loaded from session)")
  }
  invisible(x)
}
