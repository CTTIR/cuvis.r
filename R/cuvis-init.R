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
#' \dontrun{
#' cuvis_init()
#' # ... use SDK ...
#' cuvis_shutdown()
#' }
#' @export
cuvis_init <- function(settings_dir = NULL) {
  if (is.null(settings_dir)) {
    settings_dir <- .cuvis_default_settings()
  }
  settings_dir <- normalizePath(settings_dir, mustWork = FALSE)
  if (!dir.exists(settings_dir)) {
    dir.create(settings_dir, recursive = TRUE)
  }
  .Call("rcuvis_init", settings_dir)
  invisible(NULL)
}

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
    file.path(Sys.getenv("CUVIS", unset = ""), "settings"),
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
