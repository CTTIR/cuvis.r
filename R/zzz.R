.onUnload <- function(libpath) {
  tryCatch(
    .cuvis_sdk_call(.Call("rcuvis_shutdown")),
    error = function(e) NULL
  )
  library.dynam.unload("cuvis.r", libpath)
}

.onAttach <- function(libname, pkgname) {
  sdk <- tryCatch(
    .Call("rcuvis_available"),
    error = function(e) FALSE
  )

  if (!isTRUE(sdk)) {
    packageStartupMessage(
      "Note: Cubert CUVIS SDK not detected. ",
      "Install from https://github.com/cubert-hyperspectral/cuvis.sdk/releases ",
      "and set the CUVIS_SDK environment variable."
    )
  }
}

# Evaluate `code`, an SDK call. On Windows the SDK bin directory is put in
# front of PATH while the call runs, so that DLLs the SDK loads at run time
# can be found, and PATH is restored afterwards: the package never leaves the
# user's environment changed.
.cuvis_sdk_call <- function(code, os = .Platform$OS.type) {
  if (identical(os, "windows")) {
    cuvis_bin <- .cuvis_windows_bin()
    if (!is.null(cuvis_bin) && dir.exists(cuvis_bin)) {
      old_path <- Sys.getenv("PATH")
      Sys.setenv(PATH = paste(cuvis_bin, old_path, sep = ";"))
      on.exit(Sys.setenv(PATH = old_path), add = TRUE)
    }
  }
  code
}

# Accept an installation root, a legacy bin path, or sdk/cuvis_c headers.
.cuvis_windows_bin <- function(sdk = Sys.getenv("CUVIS_SDK", unset = ""),
                               legacy = Sys.getenv("CUVIS", unset = "")) {
  root <- if (nzchar(sdk)) sdk else legacy
  candidates <- if (nzchar(root)) {
    c(file.path(root, "bin"), file.path(root, "../../bin"), root)
  } else {
    c("C:/Program Files/Cuvis/bin", "C:/Program Files/Cubert GmbH/Cuvis/bin")
  }
  found <- candidates[dir.exists(candidates)]
  if (length(found)) normalizePath(found[[1]], winslash = "/") else NULL
}
