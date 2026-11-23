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
  expect_error(cuvis_set_reference(list(), fake_mesu()), class = "cuvis_error_bad_argument")
  expect_error(cuvis_set_reference(fake_ctx(), list()), class = "cuvis_error_bad_argument")
})

test_that("cuvis_set_reference rejects an unknown reference type", {
  expect_error(
    cuvis_set_reference(fake_ctx(), fake_mesu(), type = "nope"),
    "should be one of"
  )
})

# ---- cuvis_has_reference ----------------------------------------------------

test_that("cuvis_has_reference validates the context", {
  expect_error(cuvis_has_reference(list()), class = "cuvis_error_bad_argument")
})

test_that("cuvis_has_reference rejects an unknown reference type", {
  expect_error(
    cuvis_has_reference(fake_ctx(), type = "nope"),
    "should be one of"
  )
})

# ---- cuvis_reprocess --------------------------------------------------------

test_that("cuvis_reprocess validates its object arguments", {
  expect_error(cuvis_reprocess(list(), fake_mesu()), class = "cuvis_error_bad_argument")
  expect_error(cuvis_reprocess(fake_ctx(), list()), class = "cuvis_error_bad_argument")
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

# ---- SDK forwarding with a stand-in for .Call -------------------------------

processing_fixture <- function(has = character()) {
  requests <- list()
  fixture <- native_fixture(function(name, ...) {
    args <- list(...)
    requests[[length(requests) + 1L]] <<- list(name = name, args = args)
    if (name == "rcuvis_proc_has_reference") {
      type <- names(cuvis.r:::.ref_type_lookup)[match(args[[2]],
                                                     cuvis.r:::.ref_type_lookup)]
      return(type %in% has)
    }
    if (name %in% c("rcuvis_proc_create_from_session",
                    "rcuvis_proc_create_from_mesu")) {
      return("context-handle")
    }
    NULL
  }, c("cuvis_processing_context", "cuvis_set_reference", "cuvis_has_reference",
       "cuvis_reprocess", "print.cuvis_processing_context",
       ".cuvis_context_references"))
  fixture$requests <- function() requests
  fixture
}

test_that("cuvis_processing_context accepts a session or a measurement", {
  fixture <- processing_fixture()
  session <- structure(list(handle = "sh"), class = "cuvis_session")
  ctx <- fixture$cuvis_processing_context(session, load_references = FALSE)
  expect_s3_class(ctx, "cuvis_processing_context")
  expect_identical(ctx$handle, "context-handle")
  ctx <- fixture$cuvis_processing_context(fake_mesu())
  requests <- fixture$requests()
  expect_identical(requests[[1]]$name, "rcuvis_proc_create_from_session")
  expect_identical(requests[[1]]$args, list("sh", FALSE))
  expect_identical(requests[[2]]$name, "rcuvis_proc_create_from_mesu")
  expect_identical(requests[[2]]$args, list("mh", TRUE))
  expect_error(fixture$cuvis_processing_context(session, load_references = NA),
               "TRUE or FALSE")
})

test_that("cuvis_set_reference forwards the SDK reference type", {
  fixture <- processing_fixture()
  ctx <- fixture$cuvis_set_reference(fake_ctx(), fake_mesu(), "white_dark")
  expect_true(ctx$references$white_dark)
  request <- fixture$requests()[[1]]
  expect_identical(request$name, "rcuvis_proc_set_reference")
  expect_identical(request$args, list("ch", "mh", 2L))
  expect_invisible(fixture$cuvis_set_reference(fake_ctx(), fake_mesu(), "dark"))
})

test_that("cuvis_has_reference returns the SDK answer", {
  fixture <- processing_fixture(has = "white")
  expect_true(fixture$cuvis_has_reference(fake_ctx(), "white"))
  expect_false(fixture$cuvis_has_reference(fake_ctx(), "dark"))
})

test_that("cuvis_reprocess names the references a mode is missing", {
  fixture <- processing_fixture(has = "dark")
  expect_error(fixture$cuvis_reprocess(fake_ctx(), fake_mesu()), "white")
  expect_error(fixture$cuvis_reprocess(fake_ctx(), fake_mesu()),
               "cuvis_set_reference")
  fixture <- processing_fixture()
  expect_error(
    fixture$cuvis_reprocess(fake_ctx(), fake_mesu(), mode = "dark_subtract"),
    "dark"
  )
  called <- vapply(fixture$requests(), function(x) x$name, character(1))
  expect_false(any(c("rcuvis_proc_set_args", "rcuvis_proc_apply") %in% called))
  expect_error(fixture$cuvis_reprocess(fake_ctx(), fake_mesu(), allow_recalib = 1),
               "TRUE or FALSE")
})

test_that("cuvis_reprocess sets the mode and applies it to the measurement", {
  fixture <- processing_fixture(has = c("dark", "white"))
  m <- fake_mesu()
  expect_invisible(fixture$cuvis_reprocess(fake_ctx(), m, allow_recalib = TRUE))
  expect_identical(fixture$cuvis_reprocess(fake_ctx(), m, mode = "raw"), m)
  requests <- fixture$requests()
  calls <- vapply(requests, function(x) x$name, character(1))
  set_args <- requests[calls == "rcuvis_proc_set_args"]
  expect_identical(set_args[[1]]$args, list("ch", 2L, TRUE))  # reflectance
  expect_identical(set_args[[2]]$args, list("ch", 0L, FALSE)) # raw
  expect_identical(sum(calls == "rcuvis_proc_apply"), 2L)
  # raw needs no reference, so the SDK is not asked for one
  expect_identical(sum(calls == "rcuvis_proc_has_reference"), 2L)
})

test_that("print asks the SDK which references a context holds", {
  # The R object records nothing (the caller did not keep the object returned
  # by cuvis_set_reference(), or the references came from the session file),
  # yet the SDK holds a dark and a white reference.
  fixture <- processing_fixture(has = c("dark", "white"))
  show <- fixture$print.cuvis_processing_context
  out <- paste(cli::cli_fmt(show(fake_ctx())), collapse = " ")
  expect_match(out, "<cuvis_processing_context>", fixed = TRUE)
  expect_match(out, "References set: dark, white", fixed = TRUE)

  fixture <- processing_fixture()
  show <- fixture$print.cuvis_processing_context
  out <- paste(cli::cli_fmt(show(fake_ctx(list(dark = TRUE)))), collapse = " ")
  expect_match(out, "No references set", fixed = TRUE)
  expect_no_match(out, "explicit")
})
