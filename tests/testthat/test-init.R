test_that("cuvis_available returns logical", {
  expect_type(cuvis_available(), "logical")
})

test_that("cuvis_version returns string", {
  # Even in stub mode, version should return a string
  ver <- cuvis_version()
  expect_type(ver, "character")
  expect_true(nzchar(ver))
})

test_that("cuvis_init and shutdown work", {
  skip_if_no_sdk()
  expect_no_error(cuvis_init())
  expect_no_error(cuvis_shutdown())
})

test_that("cuvis_init accepts custom settings dir", {
  skip_if_no_sdk()
  tmp <- withr::local_tempdir()
  expect_no_error(cuvis_init(settings_dir = tmp))
  expect_no_error(cuvis_shutdown())
})
