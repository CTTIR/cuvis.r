# Unit tests for cuvis-session.R without the SDK.

fake_session <- function(count = 3L, path = "/tmp/s.cu3s") {
  structure(list(handle = "sh", path = path, count = count),
            class = "cuvis_session")
}

# ---- cuvis_session loader (path validation) ---------------------------------
# The body of cuvis_session() calls into the C SDK via .Call(), which cannot be
# mocked (it has no namespace binding). We cover the path validation that runs
# before the SDK call; the .Call paths are exercised by the SDK-backed tests.

test_that("cuvis_session errors when the path does not exist", {
  expect_error(cuvis_session("/no/such/file.cu3s"))
})

# ---- S3 methods -------------------------------------------------------------

test_that("print.cuvis_session shows path and count", {
  s <- fake_session(count = 7L, path = "/data/run.cu3s")
  out <- paste(cli::cli_fmt(print(s)), collapse = " ")
  expect_match(out, "CUVIS Session")
  expect_match(out, "run.cu3s")
  expect_match(out, "7")
  expect_identical(suppressMessages(print(s)), s)
})

test_that("length.cuvis_session returns the measurement count", {
  expect_identical(length(fake_session(count = 9L)), 9L)
  expect_identical(length(fake_session(count = 0L)), 0L)
})

test_that("summary.cuvis_session lists measurements", {
  s <- fake_session(count = 2L, path = "/data/run.cu3s")
  md <- list(name = "m", integration_time = 10, processing_mode = 0L)

  local_mocked_bindings(
    cuvis_get_measurement = function(session, index = 1L, ...) {
      structure(list(handle = "h", index = index), class = "cuvis_measurement")
    },
    cuvis_get_metadata = function(measurement) md
  )

  out <- paste(cli::cli_fmt(summary(s)), collapse = " ")
  expect_match(out, "CUVIS Session Summary")
  expect_match(out, "run.cu3s")
  expect_match(out, "Raw")  # processing_mode 0
})

test_that("summary.cuvis_session truncates beyond ten measurements", {
  s <- fake_session(count = 25L)
  md <- list(name = "m", integration_time = 10, processing_mode = 1L)

  local_mocked_bindings(
    cuvis_get_measurement = function(session, index = 1L, ...) {
      structure(list(handle = "h", index = index), class = "cuvis_measurement")
    },
    cuvis_get_metadata = function(measurement) md
  )

  out <- paste(cli::cli_fmt(summary(s)), collapse = " ")
  expect_match(out, "and 15 more")
})

# ---- informative loader errors ----------------------------------------------

test_that("cuvis_session reports a missing file or a directory by name", {
  missing_file <- file.path(withr::local_tempdir(), "absent.cu3s")
  expect_error(cuvis_session(missing_file), "does not exist",
               class = "cuvis_error_file_not_found")
  expect_error(cuvis_session(missing_file), class = "cuvis_error")
  expect_error(cuvis_session(withr::local_tempdir()), "is a directory",
               class = "cuvis_error_bad_argument")
})

test_that("cuvis_session builds the object and warns about other extensions", {
  dir <- withr::local_tempdir()
  good <- file.path(dir, "run.CU3S")
  odd <- file.path(dir, "run.dat")
  file.create(good, odd)
  requests <- character()
  fixture <- native_fixture(function(name, ...) {
    requests <<- c(requests, name)
    if (name == "rcuvis_session_get_size") 4L else "session-handle"
  }, "cuvis_session")

  session <- fixture$cuvis_session(good)
  expect_s3_class(session, "cuvis_session")
  expect_identical(session$count, 4L)
  expect_identical(session$path, normalizePath(good))
  expect_identical(requests,
                   c("rcuvis_session_load", "rcuvis_session_get_size"))
  expect_warning(fixture$cuvis_session(odd), "cu3s extension")
})

# ---- argument validation ----------------------------------------------------

test_that("session accessors name the offending argument", {
  expect_error(cuvis_session_count(list()), "session",
               class = "cuvis_error_bad_argument")
  expect_error(cuvis_session_fps("x"), "cuvis_session",
               class = "cuvis_error_bad_argument")
  s <- fake_session()
  for (bad in list(NA_character_, c("no_gaps", "references"), 1L, NULL)) {
    expect_error(cuvis_session_count(s, bad), "Unknown item_type",
                 class = "cuvis_error_bad_argument")
  }
  expect_error(cuvis_session_count(s, "frames"), "all_frames")
})

# ---- print and summary edge cases -------------------------------------------

test_that("print.cuvis_session names its class", {
  out <- paste(cli::cli_fmt(print(fake_session())), collapse = " ")
  expect_match(out, "<cuvis_session>", fixed = TRUE)
})

test_that("summary.cuvis_session survives an index without a measurement", {
  s <- fake_session(count = 2L)
  md <- list(name = "m", integration_time = 10, processing_mode = NA_integer_)
  local_mocked_bindings(
    cuvis_get_measurement = function(session, index = 1L, ...) {
      if (index == 1L) {
        return(NULL)
      }
      structure(list(handle = "h", index = index), class = "cuvis_measurement")
    },
    cuvis_get_metadata = function(measurement) md
  )
  out <- paste(cli::cli_fmt(summary(s)), collapse = " ")
  expect_match(out, "[1] (no measurement)", fixed = TRUE)
  expect_match(out, "Unknown")  # missing processing mode
})
