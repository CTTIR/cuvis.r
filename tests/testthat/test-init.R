test_that("cuvis_available returns logical", {
  expect_type(cuvis_available(), "logical")
})

test_that("cuvis_version returns string", {
  ver <- cuvis_version()
  expect_type(ver, "character")
  expect_true(nzchar(ver))
})

test_that("cuvis_init is idempotent when SDK already initialized", {
  skip_if_no_sdk()
  # setup.R has already initialized the SDK; calling init again should be safe
  expect_no_error(cuvis_init())
})
