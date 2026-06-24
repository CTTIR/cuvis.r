# Unit tests for cuvis-measurement.R without the SDK.

fake_session <- function(count = 5L) {
  structure(list(handle = "sh", path = "/tmp/s.cu3s", count = count),
            class = "cuvis_session")
}

fake_mesu <- function() {
  structure(list(handle = "mh", session_path = "/tmp/s.cu3s", index = 1L),
            class = "cuvis_measurement")
}

# ---- cuvis_get_measurement validation ---------------------------------------

test_that("cuvis_get_measurement rejects non-session input", {
  expect_error(cuvis_get_measurement(list(), 1), "inherits")
})

test_that("cuvis_get_measurement enforces the index range", {
  s <- fake_session(count = 3L)
  expect_error(cuvis_get_measurement(s, 0), "out of range")
  expect_error(cuvis_get_measurement(s, 4), "out of range")
  expect_error(cuvis_get_measurement(s, -1), "out of range")
})

test_that("cuvis_get_measurement rejects an unknown item_type", {
  s <- fake_session(count = 3L)
  # item_type is validated after the range check, so use a valid index
  expect_error(
    cuvis_get_measurement(s, 1, item_type = "does_not_exist"),
    "Unknown item_type"
  )
})

# ---- cuvis_get_metadata validation ------------------------------------------

test_that("cuvis_get_metadata rejects non-measurement input", {
  expect_error(cuvis_get_metadata(list()), "inherits")
})

# ---- print / summary S3 methods ---------------------------------------------

mock_md <- function() {
  list(
    name = "snap_001", path = "/data/snap_001", comment = "a comment",
    integration_time = 17.5, averages = 1L, distance = 1000,
    serial_number = "BS999", product_name = "ULTRIS", assembly = "asm-1",
    processing_mode = 2L, capture_time = 0, measurement_flags = 0L
  )
}

test_that("print.cuvis_measurement renders key metadata fields", {
  local_mocked_bindings(cuvis_get_metadata = function(measurement) mock_md())
  m <- fake_mesu()
  out <- cli::cli_fmt(print(m))
  joined <- paste(out, collapse = " ")
  expect_match(joined, "CUVIS Measurement")
  expect_match(joined, "snap_001")
  expect_match(joined, "17.5")
  expect_match(joined, "Reflectance")        # processing_mode 2 -> name
  expect_match(joined, "BS999")
})

test_that("print.cuvis_measurement returns its argument invisibly", {
  local_mocked_bindings(cuvis_get_metadata = function(measurement) mock_md())
  m <- fake_mesu()
  expect_invisible(print(m))
  expect_identical(suppressMessages(print(m)), m)
})

test_that("summary.cuvis_measurement renders the extended field set", {
  local_mocked_bindings(cuvis_get_metadata = function(measurement) mock_md())
  m <- fake_mesu()
  out <- paste(cli::cli_fmt(summary(m)), collapse = " ")
  expect_match(out, "CUVIS Measurement Summary")
  expect_match(out, "ULTRIS")
  expect_match(out, "asm-1")
  expect_match(out, "a comment")
})

test_that("measurement S3 methods resolve mode names via the helper", {
  md <- mock_md()
  md$processing_mode <- 5L  # Preview
  local_mocked_bindings(cuvis_get_metadata = function(measurement) md)
  m <- fake_mesu()
  out <- paste(cli::cli_fmt(print(m)), collapse = " ")
  expect_match(out, "Preview")
})
