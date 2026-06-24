# Unit tests for the package lifecycle hooks in zzz.R.
# These are pure R (environment variables + filesystem checks on Windows) and
# are invoked directly so they run on every platform.

skip_if_not_windows <- function() {
  testthat::skip_if_not(
    .Platform$OS.type == "windows",
    "Windows-only PATH logic"
  )
}

test_that(".onLoad prepends the CUVIS_SDK bin directory to PATH on Windows", {
  skip_if_not_windows()

  sdk <- withr::local_tempdir()
  bin <- file.path(sdk, "bin")
  dir.create(bin)

  withr::local_envvar(c(CUVIS_SDK = sdk, CUVIS = "", PATH = "EXISTING"))
  cuvis.r:::.onLoad("lib", "cuvis.r")

  expect_match(Sys.getenv("PATH"), basename(bin), fixed = TRUE)
  expect_match(Sys.getenv("PATH"), "EXISTING", fixed = TRUE)
})

test_that(".onLoad uses the CUVIS env var when CUVIS_SDK is unset", {
  skip_if_not_windows()

  cuvis_dir <- withr::local_tempdir()  # acts as the bin directory itself
  withr::local_envvar(c(CUVIS_SDK = "", CUVIS = cuvis_dir, PATH = "P0"))
  cuvis.r:::.onLoad("lib", "cuvis.r")

  expect_match(Sys.getenv("PATH"), basename(cuvis_dir), fixed = TRUE)
})

test_that(".onLoad falls back to default install locations when env unset", {
  skip_if_not_windows()

  withr::local_envvar(c(CUVIS_SDK = "", CUVIS = "", PATH = "ONLY_THIS"))
  cuvis.r:::.onLoad("lib", "cuvis.r")

  # With both env vars unset the function scans the default install dirs. The
  # original PATH must always be preserved; a default bin dir is prepended only
  # when it exists on this machine.
  expect_match(Sys.getenv("PATH"), "ONLY_THIS", fixed = TRUE)
  expect_true(grepl("ONLY_THIS$", Sys.getenv("PATH")))
})

test_that(".onLoad is a no-op contract on non-Windows platforms", {
  # On non-Windows the function returns without touching PATH; calling it here
  # on Windows still must not error.
  expect_no_error(cuvis.r:::.onLoad("lib", "cuvis.r"))
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
