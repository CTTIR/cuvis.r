.onLoad <- function(libname, pkgname) {
  # On Windows, add CUVIS bin directory to DLL search path so that
  # cuvis.dll and its dependencies can be found at runtime.
  if (.Platform$OS.type == "windows") {
    cuvis_bin <- .cuvis_windows_bin()
    if (!is.null(cuvis_bin) && dir.exists(cuvis_bin)) {
      Sys.setenv(PATH = paste(cuvis_bin, Sys.getenv("PATH"), sep = ";"))
    }
  }
}

.onUnload <- function(libpath) {
  tryCatch(
    .Call("rcuvis_shutdown"),
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
