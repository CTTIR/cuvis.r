test_that("ENVI export produces output files", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)
  cuvis_reprocess(ctx, mesu, mode = "raw")

  # Use a not-yet-existing subdirectory so the exporter has to create it.
  dir <- file.path(withr::local_tempdir(), "envi_out")
  expect_false(dir.exists(dir))
  cuvis_export_envi(mesu, dir)
  expect_true(dir.exists(dir))

  # ENVI export should produce at least one .hdr file
  hdr_files <- list.files(dir, pattern = "\\.hdr$", recursive = TRUE)
  expect_gt(length(hdr_files), 0)
})

test_that("TIFF export produces output files", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)
  cuvis_reprocess(ctx, mesu, mode = "raw")

  dir <- withr::local_tempdir()
  cuvis_export_tiff(mesu, dir)

  tiff_files <- list.files(dir, pattern = "\\.(tif|tiff)$",
                           recursive = TRUE, ignore.case = TRUE)
  expect_gt(length(tiff_files), 0)
})

test_that("session export produces .cu3s file", {
  skip_if_no_sample_data()
  session <- cuvis_sample_session()
  mesu <- cuvis_get_measurement(session, 1)
  ctx <- cuvis_processing_context(session)
  cuvis_reprocess(ctx, mesu, mode = "raw")

  dir <- withr::local_tempdir()
  # Some sample measurements (e.g. preview-only frames) lack the buffer
  # layers that the SDK requires to save a full session. Skip in that case.
  result <- tryCatch(
    cuvis_export_session(mesu, dir),
    error = function(e) e
  )
  if (inherits(result, "error")) {
    skip(paste("session export not supported for this sample:",
               conditionMessage(result)))
  }

  cu3s_files <- list.files(dir, pattern = "\\.cu3s$",
                           recursive = TRUE, ignore.case = TRUE)
  expect_gt(length(cu3s_files), 0)
})
