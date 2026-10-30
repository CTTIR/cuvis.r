test_that("export preserves existing files unless overwrite is explicit", {
  path <- withr::local_tempdir()
  original <- file.path(path, ".existing")
  writeLines("preserve me", original)
  for (export in list(cuvis_export_envi, cuvis_export_tiff, cuvis_export_session)) {
    measurement <- structure(list(handle = NULL), class = "cuvis_measurement")
    expect_error(export(measurement, path), "not empty")
    expect_identical(readLines(original), "preserve me")
  }
  expect_identical(cuvis.r:::.cuvis_export_dir(path, TRUE), normalizePath(path))
  expect_error(cuvis.r:::.cuvis_export_dir(original, TRUE), "existing file")
  expect_error(cuvis.r:::.cuvis_export_dir(paste(rep("a", 256), collapse = ""), FALSE),
               "255-byte")
})

test_that("flags reject missing, coerced and nonscalar inputs", {
  for (value in list(NA, logical(), c(TRUE, FALSE), 1, "TRUE", matrix(TRUE))) {
    expect_error(cuvis.r:::.cuvis_flag(value, "flag"), "TRUE or FALSE")
  }
  expect_identical(cuvis.r:::.cuvis_flag(FALSE, "flag"), FALSE)
})

test_that("session exporter forwards explicit replacement permission", {
  env <- new.env(parent = asNamespace("cuvis.r"))
  env$calls <- list()
  env$.Call <- function(...) { env$calls <- c(env$calls, list(list(...))); NULL }
  env$.cuvis_export_apply <- function(...) NULL
  export <- cuvis_export_session
  environment(export) <- env
  path <- withr::local_tempdir()
  measurement <- structure(list(handle = NULL), class = "cuvis_measurement")
  export(measurement, path)
  expect_identical(env$calls[[1]][[4]], FALSE)
  export(measurement, path, overwrite = TRUE)
  expect_identical(env$calls[[2]][[4]], TRUE)
})

test_that("sample filenames are literal and cannot escape their search root", {
  root <- withr::local_tempdir()
  dir.create(file.path(root, ".cuvis"))
  withr::local_dir(root)
  withr::local_envvar(c(CUVIS_SDK = "", CUVIS_DATA = ""))
  path <- file.path(root, ".cuvis", "sample[1].cu3s")
  writeLines("fixture", path)
  expect_identical(cuvis_sample_data("sample[1].cu3s"), normalizePath(path))
  expect_null(cuvis_sample_data("sample.*.cu3s"))
  for (file in list("../sample.cu3s", "sub/file", "sub\\file", NA_character_, "")) {
    expect_error(cuvis_sample_data(file))
  }
})

test_that("relative export path limits are checked before directory creation", {
  root <- withr::local_tempdir()
  withr::local_dir(root)
  name <- paste(rep("x", 250L), collapse = "")
  expect_error(cuvis.r:::.cuvis_export_dir(name, FALSE), "255-byte")
  expect_false(dir.exists(name))
})


test_that("export cleanup runs after success and preserves primary failures", {
  env <- new.env(parent = asNamespace("cuvis.r"))
  env$calls <- character()
  env$fail <- FALSE
  env$close_fail <- FALSE
  env$.Call <- function(name, ...) {
    env$calls <- c(env$calls, name)
    if (name == "rcuvis_exporter_apply" && env$fail) cli::cli_abort("flush failed")
    if (name == "rcuvis_exporter_close" && env$close_fail) cli::cli_abort("close failed")
    NULL
  }
  apply <- cuvis.r:::.cuvis_export_apply
  environment(apply) <- env
  expect_silent(apply(NULL, NULL))
  expect_identical(env$calls, c("rcuvis_exporter_apply", "rcuvis_exporter_close"))
  env$calls <- character()
  env$fail <- TRUE
  expect_error(apply(NULL, NULL), "flush failed")
  expect_identical(env$calls, c("rcuvis_exporter_apply", "rcuvis_exporter_close"))
  env$close_fail <- TRUE
  expect_warning(expect_error(apply(NULL, NULL), "flush failed"), "cleanup failed")
})
