test_that("cuvis_get_measurement returns measurement object", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  expect_s3_class(mesu, "cuvis_measurement")
})

test_that("cuvis_get_metadata returns named list", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  md <- cuvis_get_metadata(mesu)
  expect_type(md, "list")
  expect_true("name" %in% names(md))
  expect_true("integration_time" %in% names(md))
  expect_true("serial_number" %in% names(md))
  expect_true("product_name" %in% names(md))
  expect_true("processing_mode" %in% names(md))
})

test_that("cuvis_get_measurement validates index range", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  expect_error(cuvis_get_measurement(session, 0))
  expect_error(cuvis_get_measurement(session, session$count + 1L))
})

test_that("print method for measurement works", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  out <- paste(capture.output(print(mesu), type = "message"),
               capture.output(print(mesu)), collapse = "\n")
  expect_match(out, "CUVIS Measurement")
})
