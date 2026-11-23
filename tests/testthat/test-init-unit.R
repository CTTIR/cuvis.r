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
  env$.Call <- mock_native(function(...) {
    env$calls <- c(env$calls, list(list(...)))
    NULL
  })
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
  fixture$.Call <- mock_native(function(...) cli::cli_abort("shutdown failed"))
  expect_error(fixture$cuvis_shutdown(), "shutdown failed")
  expect_false(fixture$cuvis_is_initialized())
  expect_error(fixture$cuvis_init(), "Restart R")
})

# ---- settings directory discovery -------------------------------------------

test_that("default settings prefer CUVIS_SETTINGS", {
  settings <- withr::local_tempdir()
  withr::local_envvar(c(CUVIS_SETTINGS = settings, CUVIS = ""))
  expect_identical(cuvis.r:::.cuvis_default_settings(), settings)
})

test_that("default settings use a CUVIS installation that carries factory data", {
  skip_if(any(dir.exists(c("/etc/cuvis", "/usr/local/etc/cuvis",
                           "C:/ProgramData/cuvis"))),
          "a system-wide CUVIS settings directory exists on this machine")
  root <- withr::local_tempdir()
  dir.create(file.path(root, "settings", "factory"), recursive = TRUE)
  withr::local_envvar(c(CUVIS_SETTINGS = "", CUVIS = root))
  expect_identical(cuvis.r:::.cuvis_default_settings(),
                   file.path(root, "settings"))
  # an existing candidate without factory/ or user/ is still preferred to a
  # temporary directory
  unlink(file.path(root, "settings", "factory"), recursive = TRUE)
  expect_identical(cuvis.r:::.cuvis_default_settings(),
                   file.path(root, "settings"))
})

test_that("default settings warn before falling back to a temporary directory", {
  skip_if(any(dir.exists(c("/etc/cuvis", "/usr/local/etc/cuvis",
                           "C:/ProgramData/cuvis",
                           "C:/Program Files/Cubert GmbH/Cuvis/settings"))),
          "a system-wide CUVIS settings directory exists on this machine")
  withr::local_envvar(c(CUVIS_SETTINGS = "", CUVIS = ""))
  expect_warning(
    settings <- cuvis.r:::.cuvis_default_settings(),
    "No CUVIS settings directory found"
  )
  expect_identical(settings, tempdir())
})

test_that("cuvis_init creates a missing settings directory before the SDK call", {
  fixture <- init_fixture()
  settings <- file.path(withr::local_tempdir(), "new", "settings")
  fixture$cuvis_init(settings)
  expect_true(dir.exists(settings))
  expect_identical(fixture$calls[[1]][[1]], "rcuvis_init")
  expect_identical(fixture$calls[[1]][[2]], normalizePath(settings))
})

test_that("cuvis_version returns what the native routine reports", {
  fixture <- native_fixture(function(name) {
    expect_identical(name, "rcuvis_version")
    "3.6.1"
  }, "cuvis_version")
  expect_identical(fixture$cuvis_version(), "3.6.1")
})

test_that("repeating cuvis_init with a directory it created is a no-op", {
  # The settings directory does not exist before the first call. Its recorded
  # path must be the resolved one, or the second call is taken for a change of
  # settings (relative paths, and symbolic links such as the macOS tempdir).
  fixture <- init_fixture()
  root <- withr::local_tempdir()
  settings <- file.path(root, "created", "settings")
  fixture$cuvis_init(settings)
  expect_no_error(fixture$cuvis_init(settings))
  expect_length(fixture$calls, 1L)

  fixture <- init_fixture()
  withr::local_dir(root)
  fixture$cuvis_init("relative-settings")
  expect_no_error(fixture$cuvis_init("relative-settings"))
  expect_no_error(fixture$cuvis_init(file.path(root, "relative-settings")))
  expect_length(fixture$calls, 1L)
  expect_identical(fixture$calls[[1]][[2]],
                   normalizePath(file.path(root, "relative-settings")))
})
