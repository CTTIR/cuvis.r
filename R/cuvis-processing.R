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
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   ctx <- cuvis_processing_context(session)
#'   ctx
#' }
#' @export
cuvis_processing_context <- function(base, load_references = TRUE) {
  .cuvis_flag(load_references, "load_references")
  if (inherits(base, "cuvis_session")) {
    handle <- .cuvis_sdk_call(.Call("rcuvis_proc_create_from_session",
                                    base$handle, as.logical(load_references)))
  } else if (inherits(base, "cuvis_measurement")) {
    handle <- .cuvis_sdk_call(.Call("rcuvis_proc_create_from_mesu",
                                    base$handle, as.logical(load_references)))
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
#' @return Invisible `ctx`. The reference is stored in the SDK processing
#'   context behind the external pointer, so it takes effect whether or not
#'   the returned object is kept; check it with [cuvis_has_reference()].
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   ctx <- cuvis_processing_context(session)
#'   refs <- cuvis_session_count(session, "references")
#'   if (refs > 0) {
#'     dark <- cuvis_get_measurement(session, 1, item_type = "references")
#'     cuvis_set_reference(ctx, dark, type = "dark")
#'   }
#' }
#' @export
cuvis_set_reference <- function(ctx, measurement,
                                type = c("dark", "white", "white_dark",
                                         "sprad", "distance")) {
  .cuvis_check_class(ctx, "cuvis_processing_context", "ctx")
  .cuvis_check_class(measurement, "cuvis_measurement", "measurement")
  type <- match.arg(type)
  type_int <- .ref_type_lookup[[type]]
  .cuvis_sdk_call(.Call("rcuvis_proc_set_reference", ctx$handle,
                        measurement$handle, type_int))
  ctx$references[[type]] <- TRUE
  invisible(ctx)
}

#' Check if a Reference is Set
#'
#' @param ctx A cuvis_processing_context object.
#' @param type Character. Reference type to check: `"dark"`, `"white"`,
#'   `"white_dark"`, `"sprad"` or `"distance"`.
#' @return A single logical value: `TRUE` if the context holds a reference
#'   of that type.
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   ctx <- cuvis_processing_context(session)
#'   cuvis_has_reference(ctx, "dark")
#'   cuvis_has_reference(ctx, "white")
#' }
#' @export
cuvis_has_reference <- function(ctx,
                                type = c("dark", "white", "white_dark",
                                         "sprad", "distance")) {
  .cuvis_check_class(ctx, "cuvis_processing_context", "ctx")
  type <- match.arg(type)
  type_int <- .ref_type_lookup[[type]]
  .cuvis_sdk_call(.Call("rcuvis_proc_has_reference", ctx$handle, type_int))
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
#' @examples
#' # Runs only where the proprietary Cubert CUVIS SDK and its sample data
#' # are installed; elsewhere cuvis_available() is FALSE and nothing happens.
#' if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
#'   cuvis_init()
#'   session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
#'   mesu <- cuvis_get_measurement(session, 1)
#'   ctx <- cuvis_processing_context(session)
#'   cuvis_reprocess(ctx, mesu, mode = "raw")
#'   if (cuvis_has_reference(ctx, "dark") && cuvis_has_reference(ctx, "white")) {
#'     cuvis_reprocess(ctx, mesu, mode = "reflectance")
#'   }
#' }
#' @export
cuvis_reprocess <- function(ctx, measurement,
                            mode = c("reflectance", "spectral_radiance",
                                     "dark_subtract", "raw", "preview"),
                            allow_recalib = FALSE) {
  .cuvis_flag(allow_recalib, "allow_recalib")
  .cuvis_check_class(ctx, "cuvis_processing_context", "ctx")
  .cuvis_check_class(measurement, "cuvis_measurement", "measurement")
  mode <- match.arg(mode)
  mode_int <- .proc_mode_lookup[[mode]]

  # Check the references the requested mode needs before asking the SDK. Its
  # own failure is an opaque "Could not process measurement", which is
  # indistinguishable from a corrupt recording -- yet the usual cause is
  # mundane: reference captures (dark/white/blank frames) cannot themselves be
  # turned into reflectance, because they are what reflectance is computed
  # against.
  needed <- switch(mode,
    reflectance    = c("dark", "white"),
    dark_subtract  = "dark",
    character(0)
  )
  missing <- needed[!vapply(needed, function(t) isTRUE(cuvis_has_reference(ctx, t)),
                            logical(1))]
  if (length(missing)) {
    cli_abort(c(
      "Cannot process this measurement as {.val {mode}}.",
      "x" = "The processing context has no {.val {missing}} reference{?s}.",
      "i" = "Reference captures (dark, white, blank) have no reflectance of
             their own -- read them with {.code mode = \"raw\"}.",
      "i" = "For an ordinary measurement, check that the session file carries
             its references, or set them with {.fn cuvis_set_reference}."
    ))
  }

  .cuvis_sdk_call(.Call("rcuvis_proc_set_args", ctx$handle, mode_int,
                        as.logical(allow_recalib)))
  .cuvis_sdk_call(.Call("rcuvis_proc_apply", ctx$handle, measurement$handle))
  invisible(measurement)
}

#' @export
print.cuvis_processing_context <- function(x, ...) {
  cli_h3("CUVIS Processing Context {.cls cuvis_processing_context}")
  refs <- .cuvis_context_references(x)
  if (isTRUE(refs$from_sdk)) {
    if (length(refs$set) > 0) {
      cli_text("References set: {paste(refs$set, collapse = ', ')}")
    } else {
      cli_text("No references set")
    }
  } else if (length(refs$set) > 0) {
    cli_text("References set: {paste(refs$set, collapse = ', ')}")
  } else {
    cli_text("No explicit references set (may have loaded from session)")
  }
  invisible(x)
}

# Which references does a processing context hold? The SDK is asked first: it
# also knows references loaded from the session file, and references set with
# cuvis_set_reference() when the caller did not keep the returned object. If
# the SDK cannot answer (stub build, SDK shut down), fall back to what
# cuvis_set_reference() recorded on the R object.
.cuvis_context_references <- function(ctx) {
  types <- names(.ref_type_lookup)
  queried <- tryCatch(
    vapply(types, function(type) isTRUE(cuvis_has_reference(ctx, type)),
           logical(1)),
    error = function(e) NULL
  )
  if (!is.null(queried)) {
    return(list(set = types[queried], from_sdk = TRUE))
  }
  recorded <- vapply(types, function(type) isTRUE(ctx$references[[type]]),
                     logical(1))
  list(set = types[recorded], from_sdk = FALSE)
}
