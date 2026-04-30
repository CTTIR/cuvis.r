test_that("cuvis_get_cube returns 3D array with wavelengths", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)

  # Need to process first to get cube data

  ctx <- cuvis_processing_context(session)
  cuvis_reprocess(ctx, mesu, mode = "raw")

  cube <- cuvis_get_cube(mesu)

  expect_true(is.array(cube))
  expect_length(dim(cube), 3)
  expect_true(all(dim(cube) > 0))

  wl <- attr(cube, "wavelengths")
  expect_true(is.numeric(wl))
  expect_equal(length(wl), dim(cube)[3])
  # Wavelengths should be monotonically increasing
  expect_true(all(diff(wl) > 0))
})

test_that("cuvis_get_wavelengths returns numeric vector", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)
  cuvis_reprocess(ctx, mesu, mode = "raw")

  wl <- cuvis_get_wavelengths(mesu)
  expect_true(is.numeric(wl))
  expect_true(length(wl) > 0)
})
