# Unit tests for cuvis-export.R without the SDK.
# Each exporter validates its measurement argument and (for TIFF) its enum
# arguments before reaching the SDK .Call. Those validation paths are covered
# here; the actual export .Call paths are exercised by the SDK-backed tests.

fake_mesu <- function() {
  structure(list(handle = "mh"), class = "cuvis_measurement")
}

test_that("cuvis_export_envi rejects a non-measurement", {
  expect_error(cuvis_export_envi(list(), tempdir()), "inherits")
})

test_that("cuvis_export_tiff rejects a non-measurement", {
  expect_error(cuvis_export_tiff(list(), tempdir()), "inherits")
})

test_that("cuvis_export_session rejects a non-measurement", {
  expect_error(cuvis_export_session(list(), tempdir()), "inherits")
})

test_that("cuvis_export_tiff rejects an invalid format", {
  expect_error(
    cuvis_export_tiff(fake_mesu(), tempdir(), format = "Nope"),
    "should be one of"
  )
})

test_that("cuvis_export_tiff rejects an invalid compression", {
  expect_error(
    cuvis_export_tiff(fake_mesu(), tempdir(), compression = "gzip"),
    "should be one of"
  )
})
