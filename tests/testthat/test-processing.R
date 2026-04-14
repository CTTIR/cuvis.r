test_that("cuvis_processing_context can be created from session", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())
  session <- cuvis_sample_session()
  ctx <- cuvis_processing_context(session)
  expect_s3_class(ctx, "cuvis_processing_context")
})

test_that("cuvis_reprocess works with raw mode", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())

  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)

  result <- cuvis_reprocess(ctx, mesu, mode = "raw")
  expect_s3_class(result, "cuvis_measurement")
})

test_that("cuvis_reprocess works with dark_subtract mode", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())

  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)

  result <- cuvis_reprocess(ctx, mesu, mode = "dark_subtract")
  expect_s3_class(result, "cuvis_measurement")
})

test_that("cuvis_reprocess works with reflectance mode", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())

  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)

  result <- cuvis_reprocess(ctx, mesu, mode = "reflectance")
  expect_s3_class(result, "cuvis_measurement")
})

test_that("cuvis_has_reference returns logical", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())

  session <- cuvis_sample_session()
  ctx <- cuvis_processing_context(session)

  has_dark <- cuvis_has_reference(ctx, "dark")
  expect_type(has_dark, "logical")

  has_white <- cuvis_has_reference(ctx, "white")
  expect_type(has_white, "logical")
})

test_that("cuvis_reprocess rejects invalid mode", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())

  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)

  expect_error(cuvis_reprocess(ctx, mesu, mode = "invalid_mode"))
})
