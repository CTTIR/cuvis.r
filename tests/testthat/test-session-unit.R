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
