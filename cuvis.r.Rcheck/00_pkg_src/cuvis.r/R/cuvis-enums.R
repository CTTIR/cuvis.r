#' CUVIS Processing Modes
#'
#' Named integer vector of processing modes matching the CUVIS SDK C enum values.
#' Used internally by [cuvis_reprocess()].
#'
#' @details
#' - `Preview` (1): Low-resolution preview
#' - `Raw` (2): Raw sensor data, no processing
#' - `DarkSubtract` (3): Dark current subtracted
#' - `Reflectance` (4): Normalized reflectance (0-1)
#' - `SpectralRadiance` (5): Calibrated to physical radiance (W/m^2/sr/nm)
#'
#' @export
cuvis_processing_modes <- c(
  Preview = 1L,
  Raw = 2L,

  DarkSubtract = 3L,
  Reflectance = 4L,
  SpectralRadiance = 5L
)

#' CUVIS Reference Types
#'
#' Named integer vector of reference types matching the CUVIS SDK C enum values.
#' Used by [cuvis_set_reference()].
#'
#' @details
#' - `Dark` (1): Dark reference frame
#' - `White` (2): White reference frame
#' - `WhiteDark` (3): Dark reference for the white reference
#' - `SpRad` (4): Spectral radiance calibration
#' - `Distance` (5): Distance calibration
#'
#' @export
cuvis_reference_types <- c(
  Dark = 1L,
  White = 2L,

  WhiteDark = 3L,
  SpRad = 4L,
  Distance = 5L
)

#' CUVIS Session Item Types
#'
#' Named integer vector used to filter session file frames.
#'
#' @keywords internal
cuvis_session_item_types <- c(
  all_frames = 1L,
  no_gaps = 2L,

  references = 3L
)

#' CUVIS TIFF Formats
#'
#' @keywords internal
cuvis_tiff_formats <- c(
  Single = 1L,
  MultiChannel = 2L,
  MultiPage = 3L
)

#' CUVIS TIFF Compression Modes
#'
#' @keywords internal
cuvis_tiff_compression <- c(
  None = 1L,
  LZW = 2L
)

# Internal lookup: processing mode string -> integer
.proc_mode_lookup <- c(
  preview = 1L,
  raw = 2L,
  dark_subtract = 3L,
  reflectance = 4L,
  spectral_radiance = 5L
)

# Internal lookup: processing mode integer -> string
.proc_mode_names <- c(
  "Preview", "Raw", "DarkSubtract", "Reflectance", "SpectralRadiance"
)

# Internal lookup: reference type string -> integer
.ref_type_lookup <- c(
  dark = 1L,
  white = 2L,
  white_dark = 3L,
  sprad = 4L,
  distance = 5L
)
