#' CUVIS Processing Modes
#'
#' Named integer vector of processing modes matching the CUVIS SDK C enum values.
#' Used internally by [cuvis_reprocess()].
#'
#' @details
#' - `Raw` (0): Raw sensor data, no processing
#' - `DarkSubtract` (1): Dark current subtracted
#' - `Reflectance` (2): Normalized reflectance (0-1)
#' - `SpectralRadiance` (3): Calibrated to physical radiance (W/m^2/sr/nm)
#' - `Preview` (5): Low-resolution preview only
#'
#' @export
cuvis_processing_modes <- c(
  Raw = 0L,
  DarkSubtract = 1L,

  Reflectance = 2L,
  SpectralRadiance = 3L,
  Preview = 5L
)

#' CUVIS Reference Types
#'
#' Named integer vector of reference types matching the CUVIS SDK C enum values.
#' Used by [cuvis_set_reference()].
#'
#' @details
#' - `Dark` (0): Dark reference frame
#' - `White` (1): White reference frame
#' - `WhiteDark` (2): Dark reference for the white reference
#' - `SpRad` (3): Spectral radiance calibration
#' - `Distance` (4): Distance calibration
#'
#' @export
cuvis_reference_types <- c(
  Dark = 0L,
  White = 1L,
  WhiteDark = 2L,
  SpRad = 3L,
  Distance = 4L
)

#' CUVIS Session Item Types
#'
#' Named integer vector used to filter session file frames.
#'
#' @keywords internal
cuvis_session_item_types <- c(
  all_frames = 0L,
  no_gaps = 1L,
  references = 2L
)

#' CUVIS TIFF Formats
#'
#' @keywords internal
cuvis_tiff_formats <- c(
  Single = 0L,
  MultiChannel = 1L,
  MultiPage = 2L
)

#' CUVIS TIFF Compression Modes
#'
#' @keywords internal
cuvis_tiff_compression <- c(
  None = 0L,
  LZW = 1L
)

# Internal lookup: processing mode string -> integer
.proc_mode_lookup <- c(
  raw = 0L,
  dark_subtract = 1L,
  reflectance = 2L,
  spectral_radiance = 3L,
  preview = 5L
)

# Internal lookup: processing mode integer -> string (indexed by value + 1)
.proc_mode_names <- c(
  "Raw",              # 0
  "DarkSubtract",     # 1
  "Reflectance",      # 2
  "SpectralRadiance",  # 3
  NA_character_,      # 4 (unused)
  "Preview"           # 5
)

# Helper to get mode name from C enum value (0-based)
.get_proc_mode_name <- function(mode_int) {
  idx <- mode_int + 1L  # C enum is 0-based, R vector is 1-based
  if (idx >= 1L && idx <= length(.proc_mode_names) && !is.na(.proc_mode_names[idx])) {
    .proc_mode_names[idx]
  } else {
    "Unknown"
  }
}

# Internal lookup: reference type string -> integer
.ref_type_lookup <- c(
  dark = 0L,
  white = 1L,
  white_dark = 2L,
  sprad = 3L,
  distance = 4L
)
