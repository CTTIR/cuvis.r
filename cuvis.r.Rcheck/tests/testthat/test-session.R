test_that("cuvis_session loads a .cu3s file", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())
  session <- cuvis_sample_session()
  expect_s3_class(session, "cuvis_session")
  expect_gt(length(session), 0)
})

test_that("cuvis_session print method works", {
  skip_if_no_sample_data()
  cuvis_init()
  withr::defer(cuvis_shutdown())
  session <- cuvis_sample_session()
  expect_output(print(session), "CUVIS Session")
})

test_that("cuvis_session rejects non-existent files", {
  skip_if_no_sdk()
  cuvis_init()
  withr::defer(cuvis_shutdown())
  expect_error(cuvis_session("nonexistent_file.cu3s"))
})
