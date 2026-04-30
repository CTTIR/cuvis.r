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

# Initialize the SDK once for the entire test run. The CUVIS SDK does not
# support repeated init/shutdown cycles within a single process, so per-test
# init/shutdown calls would crash the second iteration. We register a
# teardown so the SDK is released cleanly when the suite finishes.
if (cuvis.r::cuvis_available()) {
  cuvis.r::cuvis_init()
  withr::defer(cuvis.r::cuvis_shutdown(), teardown_env())
}
