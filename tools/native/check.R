args <- commandArgs(TRUE)
dyn.load(args[[1]])
checks <- 0L
ok <- function(value) {
  stopifnot(isTRUE(value))
  checks <<- checks + 1L
}
fails <- function(expr, pattern) {
  error <- tryCatch({ force(expr); NULL }, error = identity)
  ok(inherits(error, "error") && grepl(pattern, conditionMessage(error)))
}
call <- function(name, ...) .Call(paste0("rcuvis_", name), ...)
fails(call("session_load", "1"), "not initialized")
fails(call("version"), "not initialized")
for (value in list(character(), NA_character_, 1L, c("1", "2"))) {
  fails(call("init", value), "one nonempty string")
}
call("init", tempdir())
ok(identical(call("version"), "synthetic-sdk"))
fails(call("init", tempdir()), "only once")
for (scenario in 1:12) {
  session <- call("session_load", as.character(scenario))
  measurement <- call("session_get_mesu", session, 0L, 0L)
  if (scenario > 4) {
    fails(call("mesu_get_cube", measurement), "buffer|dimensions|format")
    next
  }
  cube <- call("mesu_get_cube", measurement)
  ok(identical(dim(cube), c(2L, 3L, 4L)))
  ok(identical(attr(cube, "wavelengths"), c(450, 550, 650, 750)))
  for (row in 1:2) for (col in 1:3) for (band in 1:4) {
    index <- ((row - 1) * 3 + col - 1) * 4 + band - 1
    expected <- switch(scenario, index, 1000 + index, 3000000000 + index,
                       if (index == 0) NaN else index / 4)
    ok(isTRUE(all.equal(cube[row, col, band], expected)))
  }
}
for (value in list(integer(), NA_integer_, "1", 1, c(1L, 2L))) {
  fails(call("session_get_size", session, value), "one non-missing integer")
}
fails(call("session_get_mesu", session, -1L, 0L), "nonnegative")
ok(is.null(call("session_get_mesu", session, 99L, 0L)))
fails(call("mesu_get_cube", session), "measurement handle")
fails(call("exporter_create_cube", paste(rep("a", 256), collapse = ""), TRUE, FALSE),
      "path limit")
for (value in list(logical(), NA, 1, "TRUE", c(TRUE, FALSE))) {
  fails(call("exporter_create_cube", tempdir(), TRUE, value), "TRUE or FALSE")
}
for (overwrite in c(FALSE, TRUE)) {
  session <- call("session_load", as.character(20 + overwrite))
  exporter <- call("exporter_create_cube", tempdir(), TRUE, overwrite)
  call("exporter_apply", exporter, measurement)
  call("exporter_close", exporter)
  call("exporter_close", exporter)
  fails(call("exporter_apply", exporter, measurement), "freed or is invalid")
}
session <- call("session_load", "22")
exporter <- call("exporter_create_cube", tempdir(), TRUE, FALSE)
fails(call("exporter_apply", exporter, measurement), "cuvis_exporter_flush")
call("exporter_close", exporter)
source(file.path(args[[2]], "R", "cuvis-validation.R"))
source(file.path(args[[2]], "R", "cuvis-export.R"))
mesu <- structure(list(handle = measurement), class = "cuvis_measurement")
fails(cuvis_export_session(mesu, tempfile()), "cuvis_exporter_flush")
session <- call("session_load", "20")
output <- tempfile()
ok(identical(cuvis_export_session(mesu, output), normalizePath(output)))
call("shutdown")
call("shutdown")
fails(call("session_load", "1"), "shut down")
fails(call("mesu_get_cube", measurement), "shut down")
fails(call("exporter_apply", exporter, measurement), "shut down")
fails(call("init", tempdir()), "only once")
rm(session, measurement, exporter)
invisible(gc())
cat(checks, "native boundary checks passed using synthetic SDK responses\n")
