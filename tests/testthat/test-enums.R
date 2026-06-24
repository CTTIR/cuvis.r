# Tests for cuvis-enums.R -- pure-R lookups and the proc-mode-name helper.
# No SDK required: these are plain R data structures and a small helper.

test_that("cuvis_processing_modes has expected named integer values", {
  m <- cuvis_processing_modes
  expect_type(m, "integer")
  expect_identical(m[["Raw"]], 0L)
  expect_identical(m[["DarkSubtract"]], 1L)
  expect_identical(m[["Reflectance"]], 2L)
  expect_identical(m[["SpectralRadiance"]], 3L)
  expect_identical(m[["Preview"]], 5L)
  # Slot 4 is intentionally absent from the public modes vector
  expect_false(4L %in% m)
})

test_that("cuvis_reference_types has expected named integer values", {
  r <- cuvis_reference_types
  expect_type(r, "integer")
  expect_identical(unname(r), 0:4)
  expect_identical(
    names(r),
    c("Dark", "White", "WhiteDark", "SpRad", "Distance")
  )
})

test_that("internal item-type / tiff lookups are stable", {
  expect_identical(cuvis.r:::cuvis_session_item_types[["all_frames"]], 0L)
  expect_identical(cuvis.r:::cuvis_session_item_types[["no_gaps"]], 1L)
  expect_identical(cuvis.r:::cuvis_session_item_types[["references"]], 2L)

  expect_identical(cuvis.r:::cuvis_tiff_formats[["Single"]], 0L)
  expect_identical(cuvis.r:::cuvis_tiff_formats[["MultiChannel"]], 1L)
  expect_identical(cuvis.r:::cuvis_tiff_formats[["MultiPage"]], 2L)

  expect_identical(cuvis.r:::cuvis_tiff_compression[["None"]], 0L)
  expect_identical(cuvis.r:::cuvis_tiff_compression[["LZW"]], 1L)
})

test_that("string -> integer lookups match the public enums", {
  expect_identical(cuvis.r:::.proc_mode_lookup[["raw"]], 0L)
  expect_identical(cuvis.r:::.proc_mode_lookup[["dark_subtract"]], 1L)
  expect_identical(cuvis.r:::.proc_mode_lookup[["reflectance"]], 2L)
  expect_identical(cuvis.r:::.proc_mode_lookup[["spectral_radiance"]], 3L)
  expect_identical(cuvis.r:::.proc_mode_lookup[["preview"]], 5L)

  expect_identical(cuvis.r:::.ref_type_lookup[["dark"]], 0L)
  expect_identical(cuvis.r:::.ref_type_lookup[["distance"]], 4L)
})

test_that(".get_proc_mode_name maps each valid C enum value", {
  f <- cuvis.r:::.get_proc_mode_name
  expect_identical(f(0L), "Raw")
  expect_identical(f(1L), "DarkSubtract")
  expect_identical(f(2L), "Reflectance")
  expect_identical(f(3L), "SpectralRadiance")
  expect_identical(f(5L), "Preview")
})

test_that(".get_proc_mode_name returns Unknown for gaps and out-of-range", {
  f <- cuvis.r:::.get_proc_mode_name
  expect_identical(f(4L), "Unknown")   # NA slot in the names vector
  expect_identical(f(99L), "Unknown")  # beyond the vector
  expect_identical(f(-1L), "Unknown")  # negative index
})

test_that(".get_proc_mode_name handles numeric (double) input", {
  expect_identical(cuvis.r:::.get_proc_mode_name(2), "Reflectance")
})
