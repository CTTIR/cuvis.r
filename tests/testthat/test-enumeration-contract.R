test_that("enumeration validates item type and integer index before SDK", {
  session <- structure(list(handle = NULL, count = 2L), class = "cuvis_session")
  expect_error(cuvis_session_count(session, "invalid"), "Unknown item_type")
  expect_error(cuvis_get_measurement(session, NA_real_), "finite integer")
  expect_error(cuvis_get_measurement(session, 1.5), "finite integer")
})
# SDK integration still requires independent
# no_gaps/all_frames/references fixtures and nominal FPS evidence;
# this unit test is not SDK qualification.

test_that("session counts and nominal FPS forward SDK calls", {
  session <- structure(list(handle = "fake-handle", count = 2L),
    class = "cuvis_session"
  )
  requests <- list()
  sdk <- function(name, handle, ...) {
    requests[[length(requests) + 1L]] <<- list(
      name = name, handle = handle,
      args = list(...)
    )
    if (name == "rcuvis_session_get_fps") {
      return(25)
    }
    7L
  }
  count <- cuvis_session_count
  environment(count) <- list2env(list(.Call = sdk), parent = environment(count))
  expect_identical(count(session, "all_frames"), 7L)
  expect_identical(requests[[1]]$name, "rcuvis_session_get_size")
  expect_identical(
    requests[[1]]$args[[1]],
    cuvis_session_item_types[["all_frames"]]
  )
  fps <- cuvis_session_fps
  environment(fps) <- list2env(list(.Call = sdk), parent = environment(fps))
  expect_identical(fps(session), 25)
  expect_identical(requests[[2]]$name, "rcuvis_session_get_fps")
  for (missing in list(0, NA_real_, Inf, numeric())) {
    environment(fps) <- list2env(list(.Call = function(...) missing),
      parent = environment(cuvis_session_fps)
    )
    expect_identical(fps(session), NA_real_)
  }
})

test_that("measurement bounds use requested enumeration", {
  session <- structure(
    list(handle = "fake-handle", count = 2L, path = "fixture"),
    class = "cuvis_session"
  )
  get <- cuvis_get_measurement
  environment(get) <- list2env(
    list(cuvis_session_count = function(session,
                                        item_type) {
      if (item_type == "all_frames") 5L else 1L
    }, .Call = function(...) "fake-measurement"),
    parent = environment(get)
  )
  expect_s3_class(get(session, 5L, "all_frames"), "cuvis_measurement")
  expect_error(get(session, 2L, "references"), "out of range")
})
