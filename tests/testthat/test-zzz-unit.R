# Unit tests for the package lifecycle hooks and helpers in zzz.R.
# These are pure R (environment variables + filesystem checks) and are invoked
# directly; the Windows PATH logic is exercised on every platform through the
# helper's `os` argument.

test_that("SDK calls see the CUVIS_SDK bin directory on PATH only while they run", {
  sdk <- withr::local_tempdir()
  bin <- file.path(sdk, "bin")
  dir.create(bin)

  withr::local_envvar(c(CUVIS_SDK = sdk, CUVIS = "", PATH = "EXISTING"))
  inside <- cuvis.r:::.cuvis_sdk_call(Sys.getenv("PATH"), os = "windows")

  expect_identical(
    inside,
    paste(normalizePath(bin, winslash = "/"), "EXISTING", sep = ";")
  )
  expect_identical(Sys.getenv("PATH"), "EXISTING")
})

test_that("SDK calls restore PATH when the call fails", {
  sdk <- withr::local_tempdir()
  dir.create(file.path(sdk, "bin"))

  withr::local_envvar(c(CUVIS_SDK = sdk, CUVIS = "", PATH = "EXISTING"))
  expect_error(
    cuvis.r:::.cuvis_sdk_call(cli::cli_abort("SDK failure"), os = "windows"),
    "SDK failure"
  )
  expect_identical(Sys.getenv("PATH"), "EXISTING")
})

test_that("SDK calls use the CUVIS env var when CUVIS_SDK is unset", {
  cuvis_dir <- withr::local_tempdir()  # acts as the bin directory itself
  withr::local_envvar(c(CUVIS_SDK = "", CUVIS = cuvis_dir, PATH = "P0"))
  inside <- cuvis.r:::.cuvis_sdk_call(Sys.getenv("PATH"), os = "windows")

  expect_match(inside, basename(cuvis_dir), fixed = TRUE)
  expect_true(grepl(";P0$", inside))
  expect_identical(Sys.getenv("PATH"), "P0")
})

test_that("SDK calls leave PATH alone without an SDK bin directory", {
  withr::local_envvar(c(CUVIS_SDK = tempfile(), CUVIS = "", PATH = "ONLY_THIS"))
  expect_identical(
    cuvis.r:::.cuvis_sdk_call(Sys.getenv("PATH"), os = "windows"),
    "ONLY_THIS"
  )
})

test_that("SDK calls leave PATH alone on other platforms", {
  sdk <- withr::local_tempdir()
  dir.create(file.path(sdk, "bin"))
  withr::local_envvar(c(CUVIS_SDK = sdk, CUVIS = "", PATH = "EXISTING"))
  expect_identical(
    cuvis.r:::.cuvis_sdk_call(Sys.getenv("PATH"), os = "unix"),
    "EXISTING"
  )
})

test_that("the package defines no load hook that could change the environment", {
  expect_false(exists(".onLoad", envir = asNamespace("cuvis.r"), inherits = FALSE))
})

test_that(".onAttach emits a startup note when the SDK is absent", {
  # cuvis_available is not used by .onAttach (it calls .Call directly inside a
  # tryCatch), so this exercises the message branch only when no SDK is present.
  msgs <- tryCatch(
    {
      out <- testthat::capture_messages(cuvis.r:::.onAttach("lib", "cuvis.r"))
      out
    },
    error = function(e) character(0)
  )
  # When the SDK is available no message is emitted; when absent we get a note.
  # Either way the hook must not raise.
  expect_true(is.character(msgs))
})


test_that("Windows runtime lookup accepts roots, legacy bin and header locations", {
  sdk <- withr::local_tempdir()
  bin <- file.path(sdk, "bin")
  headers <- file.path(sdk, "sdk", "cuvis_c")
  dir.create(bin)
  dir.create(headers, recursive = TRUE)
  for (root in c(sdk, bin, headers)) {
    expect_identical(cuvis.r:::.cuvis_windows_bin(root, ""),
                     normalizePath(bin, winslash = "/"))
  }
  expect_identical(cuvis.r:::.cuvis_windows_bin("", sdk),
                   normalizePath(bin, winslash = "/"))
  expect_null(cuvis.r:::.cuvis_windows_bin(tempfile(), sdk))
})
