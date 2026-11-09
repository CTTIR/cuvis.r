#' Initialize the CUVIS SDK
#'
#' Must be called before any other cuvis.r function. Loads the Cubert CUVIS
#' SDK and configures the user settings directory.
#'
#' @param settings_dir Character. Path to the CUVIS settings directory — the
#'   one holding `factory/` and `user/`. If `NULL` (default), the directory is
#'   discovered in this order: the `CUVIS_SETTINGS` environment variable, then
#'   the standard install locations for the platform, and only as a last resort
#'   a temporary directory.
#'
#' @details
#' The settings directory is not optional in practice. The SDK loads its
#' factory calibration from it, and pointing it at an empty directory makes
#' every subsequent `cuvis_proc_cont_apply()` fail with "Could not process
#' measurement" — which looks like a corrupt recording rather than a
#' configuration problem. Hence the search over real install locations before
#' falling back to a temporary directory, and the warning when it does.
#'
#' @return Invisible `NULL`.
#'
#' @examples
#' # Requires the proprietary Cubert CUVIS SDK. The SDK can be initialized
#' # only once per R process, so cuvis_shutdown() is called only at the very
#' # end of a session.
#' if (cuvis_available()) {
#'   cuvis_init()
#'   cuvis_is_initialized()
#' }
#' @export
cuvis_init <- function(settings_dir = NULL) {
  if (isTRUE(.cuvis_state$retired)) {
    cli::cli_abort("The CUVIS SDK was shut down. Restart R before initializing it again.")
  }
  if (!cuvis_available()) {
    cli::cli_abort("cuvis.r was installed without the CUVIS SDK. Reinstall with CUVIS_SDK set to the SDK path.")
  }
  if (is.null(settings_dir)) {
    settings_dir <- .cuvis_default_settings()
  }
  settings_dir <- normalizePath(.cuvis_path(settings_dir, "settings_dir"),
                                mustWork = FALSE)

  # Initialising an already-initialised SDK is a no-op, and re-initialising a
  # shut-down one does not restore a usable state: the next
  # cuvis_session_file_load() then dereferences a null handle and takes the R
  # process down. Callers that read several measurements in one session hit
  # this on the second read, so track the state and skip redundant work.
  if (isTRUE(.cuvis_state$initialized) &&
      identical(.cuvis_state$settings_dir, settings_dir)) {
    return(invisible(NULL))
  }
  if (isTRUE(.cuvis_state$initialized)) {
    cli::cli_abort("The SDK is already initialized with different settings. Restart R to change them.")
  }
  if (!dir.exists(settings_dir) &&
      !dir.create(settings_dir, recursive = TRUE)) {
    cli::cli_abort("Could not create the CUVIS settings directory.")
  }
  .Call("rcuvis_init", settings_dir)
  .cuvis_state$initialized <- TRUE
  .cuvis_state$settings_dir <- settings_dir
  invisible(NULL)
}


# Tracks whether the SDK is currently initialised, and with which settings
# directory. Lives in the package namespace so it survives across calls.
.cuvis_state <- new.env(parent = emptyenv())
.cuvis_state$initialized <- FALSE
.cuvis_state$settings_dir <- NULL
.cuvis_state$retired <- FALSE


#' Is the CUVIS SDK Currently Initialized?
#'
#' Reports whether [cuvis_init()] has been called successfully in this R
#' process and the SDK has not been shut down since.
#'
#' @return A single logical value.
#' @examples
#' cuvis_is_initialized()
#' @export
cuvis_is_initialized <- function() isTRUE(.cuvis_state$initialized)

# Locate the CUVIS settings directory (the one containing factory/ and user/).
# Returns a usable path, warning if it has to fall back to a temporary
# directory, because processing will then fail in a way that is hard to
# attribute to configuration.
.cuvis_default_settings <- function() {
  env <- Sys.getenv("CUVIS_SETTINGS", unset = "")
  if (nzchar(env)) return(env)

  candidates <- c(
    "/etc/cuvis",
    "/usr/local/etc/cuvis",
    if (nzchar(Sys.getenv("CUVIS"))) file.path(Sys.getenv("CUVIS"), "settings"),
    "C:/ProgramData/cuvis",
    "C:/Program Files/Cubert GmbH/Cuvis/settings"
  )
  candidates <- candidates[nzchar(candidates)]

  # a real settings directory carries factory/ or user/
  for (p in candidates) {
    if (dir.exists(p) && (dir.exists(file.path(p, "factory")) ||
                          dir.exists(file.path(p, "user")))) {
      return(p)
    }
  }
  # any existing candidate is still better than an empty temp dir
  hit <- candidates[dir.exists(candidates)]
  if (length(hit)) return(hit[1])

  cli::cli_warn(c(
    "No CUVIS settings directory found; falling back to a temporary directory.",
    "!" = "Processing measurements will likely fail with {.code Could not process measurement}.",
    "i" = "Set {.envvar CUVIS_SETTINGS} or pass {.arg settings_dir} to point at the
           directory containing {.path factory/} and {.path user/}."
  ))
  tempdir()
}

#' Shut Down the CUVIS SDK
#'
#' Releases all SDK resources. Call when done using cuvis.r functions.
#' The vendor permits initialization only once per process. After shutdown,
#' existing handles cannot be used and R must be restarted before another
#' [cuvis_init()] call. Keep one initialized SDK for a batch of measurements.
#'
#' @return Invisible `NULL`.
#' @examples
#' # Not run: requires the proprietary Cubert CUVIS SDK, and after shutdown
#' # the SDK cannot be initialized again in the same R process.
#' \dontrun{
#' cuvis_init()
#' # ... read, process and export measurements ...
#' cuvis_shutdown()
#' }
#' @export
cuvis_shutdown <- function() {
  if (!isTRUE(.cuvis_state$initialized)) {
    return(invisible(NULL))
  }
  .cuvis_state$initialized <- FALSE
  .cuvis_state$settings_dir <- NULL
  .cuvis_state$retired <- TRUE
  .Call("rcuvis_shutdown")
  invisible(NULL)
}

#' Get CUVIS SDK Version
#'
#' Note: The SDK must be initialized with [cuvis_init()] before calling
#' this function.
#'
#' @return Character string with the SDK version.
#' @examples
#' # Requires the proprietary Cubert CUVIS SDK.
#' if (cuvis_available()) {
#'   cuvis_init()
#'   cuvis_version()
#' }
#' @export
cuvis_version <- function() {
  .Call("rcuvis_version")
}

#' Check if CUVIS SDK is Available
#'
#' Tests whether the Cubert CUVIS SDK library was linked at installation.
#' This does not initialize the SDK or verify calibration, sample data or
#' runtime usability. See [cuvis_is_initialized()].
#'
#' @return Logical. `TRUE` if the SDK is available, `FALSE` otherwise.
#' @examples
#' cuvis_available()
#' @export
cuvis_available <- function() {
  tryCatch(
    isTRUE(.Call("rcuvis_available")),
    error = function(e) FALSE
  )
}
