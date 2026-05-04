.onLoad <- function(libname, pkgname) {
  # On Windows, add CUVIS bin directory to DLL search path so that
  # cuvis.dll and its dependencies can be found at runtime.
  if (.Platform$OS.type == "windows") {
    cuvis_bin <- NULL
    cuvis_sdk <- Sys.getenv("CUVIS_SDK", unset = "")
    cuvis_env <- Sys.getenv("CUVIS", unset = "")
    if (nzchar(cuvis_sdk)) {
      cuvis_bin <- file.path(cuvis_sdk, "bin")
    } else if (nzchar(cuvis_env)) {
      cuvis_bin <- cuvis_env
    } else {
      # Check default install locations
      candidates <- c(
        "C:/Program Files/Cuvis/bin",
        "C:/Program Files/Cubert GmbH/Cuvis/bin"
      )
      for (d in candidates) {
        if (dir.exists(d)) {
          cuvis_bin <- d
          break
        }
      }
    }
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
      "Install from https://cloud.cubert-gmbh.de/s/qpxkyWkycrmBK9m ",
      "and set the CUVIS_SDK environment variable."
    )
  }
}
