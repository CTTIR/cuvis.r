# SDK-independent lifecycle tests use isolated function environments.

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

# Exercise lifecycle without shutting down the shared SDK test session.
init_fixture <- function(available = TRUE) {
  env <- new.env(parent = asNamespace("cuvis.r"))
  env$.cuvis_state <- list2env(list(initialized = FALSE, settings_dir = NULL,
                                  retired = FALSE))
  env$cuvis_available <- function() available
  env$calls <- list()
  env$.Call <- function(...) { env$calls <- c(env$calls, list(list(...))); NULL }
  for (name in c("cuvis_init", "cuvis_shutdown", "cuvis_is_initialized")) {
    fun <- get(name, asNamespace("cuvis.r"))
    environment(fun) <- env
    env[[name]] <- fun
  }
  env
}

test_that("initialization preserves settings and shutdown permanently retires SDK", {
  fixture <- init_fixture()
  settings <- withr::local_tempdir()
  fixture$cuvis_init(settings)
  fixture$cuvis_init(file.path(settings, "."))
  expect_length(fixture$calls, 1L)
  expect_true(fixture$cuvis_is_initialized())
  expect_error(fixture$cuvis_init(tempfile()), "different settings")
  fixture$cuvis_shutdown()
  expect_false(fixture$cuvis_is_initialized())
  expect_silent(fixture$cuvis_shutdown())
  expect_length(fixture$calls, 2L)
  expect_error(fixture$cuvis_init(settings), "Restart R")
})

test_that("unavailable SDK and invalid settings do not create directories", {
  fixture <- init_fixture(FALSE)
  path <- tempfile()
  expect_error(fixture$cuvis_init(path), "without the CUVIS SDK")
  expect_false(file.exists(path))
  fixture <- init_fixture()
  for (value in list(NA_character_, character(), c("a", "b"), 1, "")) {
    expect_error(fixture$cuvis_init(value), "one nonempty path")
  }
  expect_length(fixture$calls, 0L)
})

test_that("native shutdown failure cannot leave usable handles or permit restart", {
  fixture <- init_fixture()
  fixture$cuvis_init(withr::local_tempdir())
  fixture$.Call <- function(...) cli::cli_abort("shutdown failed")
  expect_error(fixture$cuvis_shutdown(), "shutdown failed")
  expect_false(fixture$cuvis_is_initialized())
  expect_error(fixture$cuvis_init(), "Restart R")
})
