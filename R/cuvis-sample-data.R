#' Get Path to Sample Data
#'
#' Returns the path to Cubert sample data. Searches in order:
#' 1. `.cuvis/` directory in the working directory or any parent (up to 5 levels)
#' 2. `CUVIS_DATA` environment variable
#' 3. SDK default install location
#'
#' @param file Character. Specific file name (e.g., `"test_mesu.cu3s"`).
#'   If `NULL`, returns the sample data root directory.
#'
#' @return Character path, or `NULL` if not found.
#' @export
cuvis_sample_data <- function(file = NULL) {
  dot_cuvis <- character(0)
  d <- getwd()
  for (i in seq_len(6L)) {
    cand <- file.path(d, ".cuvis")
    if (dir.exists(cand)) {
      dot_cuvis <- c(dot_cuvis, cand)
    }
    parent <- dirname(d)
    if (parent == d) break
    d <- parent
  }

  candidates <- c(
    dot_cuvis,
    Sys.getenv("CUVIS_DATA", unset = NA_character_),
    file.path(Sys.getenv("CUVIS_SDK", unset = ""), "sample_data"),
    "/opt/cuvis/sample_data"
  )
  candidates <- candidates[!is.na(candidates) & nzchar(candidates)]

  for (base in candidates) {
    if (is.null(file)) {
      if (dir.exists(base)) return(normalizePath(base))
    } else {
      found <- list.files(base, pattern = paste0("^", file, "$"),
                          recursive = TRUE, full.names = TRUE)
      if (length(found) > 0) return(normalizePath(found[1]))
    }
  }
  NULL
}

#' Load the Default Sample Session
#'
#' Convenience function that locates and loads the first `.cu3s` file
#' found in the sample data directories.
#'
#' @return A cuvis_session object, or `NULL` with a warning if sample
#'   data is not found.
#' @export
cuvis_sample_session <- function() {
  path <- cuvis_sample_data("test_mesu.cu3s")
  if (is.null(path)) {
    base <- cuvis_sample_data()
    if (!is.null(base)) {
      found <- list.files(base, pattern = "\\.cu3s$",
                          recursive = TRUE, full.names = TRUE)
      if (length(found) > 0) path <- found[1]
    }
  }
  if (is.null(path)) {
    cli_warn(c(
      "!" = "No sample .cu3s files found.",
      "i" = "Download from: {.url https://cloud.cubert-gmbh.de/s/SrkSRja5FKGS2Tw}",
      "i" = "Place in {.path .cuvis/} or set {.envvar CUVIS_DATA}."
    ))
    return(NULL)
  }
  cuvis_session(path)
}
