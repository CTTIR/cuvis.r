# Helper functions to skip tests when SDK or sample data are not available

skip_if_no_sdk <- function() {
  testthat::skip_if_not(
    cuvis.r::cuvis_available(),
    "CUVIS SDK not installed -- skipping cuvis.r tests"
  )
}

skip_if_no_sample_data <- function() {
  skip_if_no_sdk()
  path <- cuvis.r::cuvis_sample_data()
  testthat::skip_if(
    is.null(path),
    "No sample .cu3s data found -- skipping data tests"
  )
}
