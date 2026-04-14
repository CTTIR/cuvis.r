.onLoad <- function(libname, pkgname) {
  # Nothing — user must call cuvis_init() explicitly
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
