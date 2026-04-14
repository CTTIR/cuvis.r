#' Initialize the CUVIS SDK
#'
#' Must be called before any other cuvis.r function. Loads the Cubert CUVIS
#' SDK and configures the user settings directory.
#'
#' @param settings_dir Character. Path to CUVIS user settings directory.
#'   If `NULL` (default), uses the `CUVIS_SETTINGS` environment variable,
#'   or a temporary directory.
#'
#' @return Invisible `NULL`.
#'
#' @examples
#' \dontrun{
#' cuvis_init()
#' # ... use SDK ...
#' cuvis_shutdown()
#' }
#' @export
cuvis_init <- function(settings_dir = NULL) {
  if (is.null(settings_dir)) {
    settings_dir <- Sys.getenv("CUVIS_SETTINGS", unset = "")
    if (!nzchar(settings_dir)) {
      settings_dir <- tempdir()
    }
  }
  settings_dir <- normalizePath(settings_dir, mustWork = FALSE)
  if (!dir.exists(settings_dir)) {
    dir.create(settings_dir, recursive = TRUE)
  }
  .Call("rcuvis_init", settings_dir)
  invisible(NULL)
}

#' Shut Down the CUVIS SDK
#'
#' Releases all SDK resources. Call when done using cuvis.r functions.
#'
#' @return Invisible `NULL`.
#' @export
cuvis_shutdown <- function() {
  .Call("rcuvis_shutdown")
  invisible(NULL)
}

#' Get CUVIS SDK Version
#'
#' Note: The SDK must be initialized with [cuvis_init()] before calling
#' this function.
#'
#' @return Character string with the SDK version.
#' @export
cuvis_version <- function() {
  .Call("rcuvis_version")
}

#' Check if CUVIS SDK is Available
#'
#' Tests whether the Cubert CUVIS SDK library is linked and usable.
#'
#' @return Logical. `TRUE` if the SDK is available, `FALSE` otherwise.
#' @export
cuvis_available <- function() {
  tryCatch(
    isTRUE(.Call("rcuvis_available")),
    error = function(e) FALSE
  )
}
