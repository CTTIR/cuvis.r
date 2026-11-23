.cuvis_path <- function(path, name) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !nzchar(path) || !is.null(dim(path))) {
    cli::cli_abort("{name} must be one nonempty path string.")
  }
  path.expand(path)
}

.cuvis_flag <- function(value, name) {
  if (!is.logical(value) || length(value) != 1L || is.na(value) ||
      !is.null(dim(value))) {
    cli::cli_abort("{name} must be TRUE or FALSE.")
  }
  value
}

.cuvis_export_dir <- function(dir, overwrite) {
  dir <- .cuvis_path(dir, "dir")
  .cuvis_flag(overwrite, "overwrite")
  if (!grepl("^(/|[A-Za-z]:[/\\\\]|\\\\\\\\)", dir)) {
    dir <- file.path(getwd(), dir)
  }
  dir <- normalizePath(dir, mustWork = FALSE)
  if (nchar(enc2utf8(dir), type = "bytes") >= 256L) {
    cli::cli_abort("Export directory exceeds the SDK's 255-byte path limit.")
  }
  if (file.exists(dir) && !dir.exists(dir)) {
    cli::cli_abort("Export destination is an existing file.")
  }
  if (!overwrite && dir.exists(dir) && file.access(dir, 4L) != 0L) {
    cli::cli_abort("Cannot inspect the export directory; choose a readable empty directory.")
  }
  if (!overwrite && dir.exists(dir) &&
      length(list.files(dir, all.files = TRUE, no.. = TRUE))) {
    cli::cli_abort(c(
      "Export directory is not empty.",
      "i" = "Use a new directory, or set {.code overwrite = TRUE} to permit replacement."
    ))
  }
  if (!dir.exists(dir) && !dir.create(dir, recursive = TRUE)) {
    cli::cli_abort("Could not create the export directory.")
  }
  normalizePath(dir, mustWork = TRUE)
}

# Check that `x` is an object of class `class` created by this package. The
# error names the argument and what was received, and carries the classes
# `cuvis_error_bad_argument` and `cuvis_error` so callers can catch it.
.cuvis_check_class <- function(x, class, arg, call = rlang::caller_env()) {
  if (!inherits(x, class)) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a {.cls {class}} object.",
        "x" = "It is {.obj_type_friendly {x}}."
      ),
      class = c("cuvis_error_bad_argument", "cuvis_error"),
      call = call
    )
  }
  invisible(x)
}

# Check a session item type and return its SDK enumeration value.
.cuvis_item_type <- function(item_type, call = rlang::caller_env()) {
  valid <- names(cuvis_session_item_types)
  is_string <- is.character(item_type) && length(item_type) == 1L &&
    !is.na(item_type)
  if (!is_string || !item_type %in% valid) {
    got <- if (is_string) {
      cli::format_inline("{.val {item_type}}")
    } else {
      cli::format_inline("{.obj_type_friendly {item_type}}")
    }
    cli::cli_abort(
      c(
        "Unknown item_type.",
        "x" = "{.arg item_type} must be one of {.or {.val {valid}}}, not {got}."
      ),
      class = c("cuvis_error_bad_argument", "cuvis_error"),
      call = call
    )
  }
  cuvis_session_item_types[[item_type]]
}
