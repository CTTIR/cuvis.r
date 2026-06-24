# Unit tests for cuvis-cube.R that do not require the SDK.
# cuvis_get_cube's body is a single .Call into the C SDK, so we exercise its
# input validation here and mock it where it is a dependency of other code.

test_that("cuvis_get_cube rejects non-measurement input", {
  expect_error(cuvis_get_cube(list()), "inherits")
  expect_error(cuvis_get_cube(42))
  expect_error(cuvis_get_cube("not a measurement"))
})

test_that("cuvis_get_wavelengths extracts the wavelengths attribute", {
  cube <- array(0, dim = c(2, 2, 3))
  attr(cube, "wavelengths") <- c(450, 550, 650)

  local_mocked_bindings(cuvis_get_cube = function(measurement) cube)

  m <- structure(list(handle = "h"), class = "cuvis_measurement")
  wl <- cuvis_get_wavelengths(m)
  expect_identical(wl, c(450, 550, 650))
})

test_that("cuvis_get_wavelengths returns NULL when attribute is absent", {
  local_mocked_bindings(
    cuvis_get_cube = function(measurement) array(0, dim = c(1, 1, 1))
  )
  m <- structure(list(handle = "h"), class = "cuvis_measurement")
  expect_null(cuvis_get_wavelengths(m))
})
