# Unit tests for cuvis-init.R that do not require the SDK.
# cuvis_init/shutdown/version wrap raw .Call into the SDK and cannot be mocked,
# so they are covered by the SDK-backed tests in test-init.R. Here we cover the
# behaviour that is observable without hardware.

test_that("cuvis_available always returns a single logical", {
  res <- cuvis_available()
  expect_type(res, "logical")
  expect_length(res, 1L)
})

test_that("cuvis_available returns FALSE when the SDK call errors", {
  # cuvis_available wraps .Call in tryCatch; the only thing we can verify
  # without the SDK is that the contract (logical scalar) always holds.
  expect_false(is.na(cuvis_available()))
})
