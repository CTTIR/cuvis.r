# Unit tests for cuvis-sample-data.R -- this file is pure R (filesystem and
# environment-variable search), so it is fully testable without the SDK.

test_that("cuvis_sample_data finds a .cuvis directory in the working dir", {
  root <- withr::local_tempdir()
  dir.create(file.path(root, ".cuvis"))

  withr::local_dir(root)
  withr::local_envvar(c(CUVIS_DATA = "", CUVIS_SDK = ""))

  res <- cuvis_sample_data()
  expect_false(is.null(res))
  expect_identical(normalizePath(res), normalizePath(file.path(root, ".cuvis")))
})

test_that("cuvis_sample_data walks up to a parent .cuvis directory", {
  root <- withr::local_tempdir()
  dir.create(file.path(root, ".cuvis"))
  nested <- file.path(root, "a", "b")
  dir.create(nested, recursive = TRUE)

  withr::local_dir(nested)
  withr::local_envvar(c(CUVIS_DATA = "", CUVIS_SDK = ""))

  res <- cuvis_sample_data()
  expect_identical(normalizePath(res), normalizePath(file.path(root, ".cuvis")))
})

test_that("cuvis_sample_data locates a named file via CUVIS_DATA", {
  data_dir <- withr::local_tempdir()
  sub <- file.path(data_dir, "nested")
  dir.create(sub)
  target <- file.path(sub, "test_mesu.cu3s")
  file.create(target)

  # cd somewhere with no .cuvis so the env-var branch is taken
  empty <- withr::local_tempdir()
  withr::local_dir(empty)
  withr::local_envvar(c(CUVIS_DATA = data_dir, CUVIS_SDK = ""))

  res <- cuvis_sample_data("test_mesu.cu3s")
  expect_identical(normalizePath(res), normalizePath(target))
})

test_that("cuvis_sample_data returns NULL when nothing is found", {
  empty <- withr::local_tempdir()
  withr::local_dir(empty)
  withr::local_envvar(c(CUVIS_DATA = "", CUVIS_SDK = ""))

  expect_null(cuvis_sample_data("missing_file.cu3s"))
})

test_that("cuvis_sample_data returns NULL for a missing root directory", {
  empty <- withr::local_tempdir()
  withr::local_dir(empty)
  withr::local_envvar(c(CUVIS_DATA = "", CUVIS_SDK = ""))

  expect_null(cuvis_sample_data())
})

# ---- cuvis_sample_session ---------------------------------------------------

test_that("cuvis_sample_session loads the located sample file", {
  local_mocked_bindings(
    cuvis_sample_data = function(file = NULL) "/tmp/test_mesu.cu3s",
    cuvis_session = function(path) {
      structure(list(handle = "h", path = path, count = 1L),
                class = "cuvis_session")
    }
  )
  s <- cuvis_sample_session()
  expect_s3_class(s, "cuvis_session")
  expect_identical(s$path, "/tmp/test_mesu.cu3s")
})

test_that("cuvis_sample_session falls back to scanning for a .cu3s file", {
  base <- withr::local_tempdir()
  found_file <- file.path(base, "other.cu3s")
  file.create(found_file)

  local_mocked_bindings(
    cuvis_sample_data = function(file = NULL) {
      if (is.null(file)) base else NULL  # named lookup misses, root hits
    },
    cuvis_session = function(path) {
      structure(list(handle = "h", path = path, count = 1L),
                class = "cuvis_session")
    }
  )
  s <- cuvis_sample_session()
  expect_s3_class(s, "cuvis_session")
  expect_match(s$path, "other.cu3s")
})

test_that("cuvis_sample_session warns and returns NULL when nothing is found", {
  local_mocked_bindings(cuvis_sample_data = function(file = NULL) NULL)
  expect_warning(res <- cuvis_sample_session(), "No sample .cu3s files")
  expect_null(res)
})
