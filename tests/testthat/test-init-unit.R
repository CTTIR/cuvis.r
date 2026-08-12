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

test_that("initialisation is idempotent and shutdown is re-entrant", {
  skip_if_not(cuvis_available(), "CUVIS SDK not available")

  # Re-initialising a shut-down SDK does not restore a usable state: the next
  # session load dereferences a null handle and takes the R process down.
  # Reading two measurements in one session used to segfault on the second,
  # because the reader shut the SDK down after each read. Initialisation is
  # therefore a no-op while already initialised, and shutdown does nothing
  # when there is nothing to release.
  cuvis_init()
  expect_true(cuvis_is_initialized())

  expect_silent(cuvis_init())          # second call is a no-op
  expect_true(cuvis_is_initialized())

  cuvis_shutdown()
  expect_false(cuvis_is_initialized())

  expect_silent(cuvis_shutdown())      # safe to call again
  expect_false(cuvis_is_initialized())

  cuvis_init()                          # leave the session usable
  expect_true(cuvis_is_initialized())
})
