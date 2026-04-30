test_that("cuvis_session loads a .cu3s file", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  expect_s3_class(session, "cuvis_session")
  expect_gt(length(session), 0)
})

test_that("cuvis_session print method works", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  out <- paste(capture.output(print(session), type = "message"),
               capture.output(print(session)), collapse = "\n")
  expect_match(out, "CUVIS Session")
})

test_that("cuvis_session rejects non-existent files", {
  skip_if_no_sdk()
  expect_error(cuvis_session("nonexistent_file.cu3s"))
})
