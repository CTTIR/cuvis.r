# Unit tests for cuvis-processing.R without the SDK.
# The .Call paths cannot be mocked, so we cover argument validation (which runs
# before the SDK call) and the pure-R print method.

fake_ctx <- function(references = list()) {
  structure(list(handle = "ch", references = references),
            class = "cuvis_processing_context")
}

fake_mesu <- function() {
  structure(list(handle = "mh"), class = "cuvis_measurement")
}

# ---- cuvis_processing_context -----------------------------------------------

test_that("cuvis_processing_context rejects an unsupported base object", {
  expect_error(cuvis_processing_context(42), "cuvis_session")
  expect_error(cuvis_processing_context(list()), "cuvis_measurement")
})

# ---- cuvis_set_reference ----------------------------------------------------

test_that("cuvis_set_reference validates its object arguments", {
  expect_error(cuvis_set_reference(list(), fake_mesu()), "inherits")
  expect_error(cuvis_set_reference(fake_ctx(), list()), "inherits")
})

test_that("cuvis_set_reference rejects an unknown reference type", {
  expect_error(
    cuvis_set_reference(fake_ctx(), fake_mesu(), type = "nope"),
    "should be one of"
  )
})

# ---- cuvis_has_reference ----------------------------------------------------

test_that("cuvis_has_reference validates the context", {
  expect_error(cuvis_has_reference(list()), "inherits")
})

test_that("cuvis_has_reference rejects an unknown reference type", {
  expect_error(
    cuvis_has_reference(fake_ctx(), type = "nope"),
    "should be one of"
  )
})

# ---- cuvis_reprocess --------------------------------------------------------

test_that("cuvis_reprocess validates its object arguments", {
  expect_error(cuvis_reprocess(list(), fake_mesu()), "inherits")
  expect_error(cuvis_reprocess(fake_ctx(), list()), "inherits")
})

test_that("cuvis_reprocess rejects an unknown mode", {
  expect_error(
    cuvis_reprocess(fake_ctx(), fake_mesu(), mode = "nope"),
    "should be one of"
  )
})

# ---- print.cuvis_processing_context -----------------------------------------

test_that("print method reports no references when none are set", {
  out <- paste(cli::cli_fmt(print(fake_ctx())), collapse = " ")
  expect_match(out, "CUVIS Processing Context")
  expect_match(out, "No explicit references")
})

test_that("print method lists the references that are set", {
  ctx <- fake_ctx(references = list(dark = TRUE, white = TRUE))
  out <- paste(cli::cli_fmt(print(ctx)), collapse = " ")
  expect_match(out, "References set")
  expect_match(out, "dark")
  expect_match(out, "white")
})

test_that("print method ignores references flagged FALSE", {
  ctx <- fake_ctx(references = list(dark = TRUE, white = FALSE))
  out <- paste(cli::cli_fmt(print(ctx)), collapse = " ")
  expect_match(out, "dark")
  expect_no_match(out, "white")
})

test_that("print.cuvis_processing_context returns its argument invisibly", {
  ctx <- fake_ctx()
  expect_invisible(print(ctx))
  expect_identical(suppressMessages(print(ctx)), ctx)
})
