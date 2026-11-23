# Package index

## SDK lifecycle

Check for the SDK, initialize it once per R process and shut it down.

- [`cuvis_available()`](https://cttir.github.io/cuvis.r/reference/cuvis_available.md)
  : Check if CUVIS SDK is Available
- [`cuvis_init()`](https://cttir.github.io/cuvis.r/reference/cuvis_init.md)
  : Initialise the CUVIS SDK
- [`cuvis_is_initialized()`](https://cttir.github.io/cuvis.r/reference/cuvis_is_initialized.md)
  : Is the CUVIS SDK Currently Initialised?
- [`cuvis_version()`](https://cttir.github.io/cuvis.r/reference/cuvis_version.md)
  : Get CUVIS SDK Version
- [`cuvis_shutdown()`](https://cttir.github.io/cuvis.r/reference/cuvis_shutdown.md)
  : Shut Down the CUVIS SDK

## Sessions and measurements

Open `.cu3s` session files and read measurements and their metadata.

- [`cuvis_session()`](https://cttir.github.io/cuvis.r/reference/cuvis_session.md)
  : Load a Cubert Session File
- [`cuvis_session_count()`](https://cttir.github.io/cuvis.r/reference/cuvis_session_count.md)
  : Count Session Items by SDK Enumeration Type
- [`cuvis_session_fps()`](https://cttir.github.io/cuvis.r/reference/cuvis_session_fps.md)
  : Read the Nominal Frame Rate of a Session
- [`cuvis_get_measurement()`](https://cttir.github.io/cuvis.r/reference/cuvis_get_measurement.md)
  : Get a Measurement from a Session
- [`cuvis_get_metadata()`](https://cttir.github.io/cuvis.r/reference/cuvis_get_metadata.md)
  : Get Measurement Metadata

## Calibration and processing

Set references and reprocess a measurement to a calibration level.

- [`cuvis_processing_context()`](https://cttir.github.io/cuvis.r/reference/cuvis_processing_context.md)
  : Create a Processing Context for Calibration
- [`cuvis_set_reference()`](https://cttir.github.io/cuvis.r/reference/cuvis_set_reference.md)
  : Set a Calibration Reference
- [`cuvis_has_reference()`](https://cttir.github.io/cuvis.r/reference/cuvis_has_reference.md)
  : Check if a Reference is Set
- [`cuvis_reprocess()`](https://cttir.github.io/cuvis.r/reference/cuvis_reprocess.md)
  : Reprocess a Measurement to a New Calibration Level

## Data cube

Extract the hyperspectral cube and its wavelengths as R objects.

- [`cuvis_get_cube()`](https://cttir.github.io/cuvis.r/reference/cuvis_get_cube.md)
  : Extract Hyperspectral Cube from a Measurement
- [`cuvis_get_wavelengths()`](https://cttir.github.io/cuvis.r/reference/cuvis_get_wavelengths.md)
  : Get Wavelength Vector from a Measurement

## Export

Write measurements to ENVI, TIFF or a new session file.

- [`cuvis_export_envi()`](https://cttir.github.io/cuvis.r/reference/cuvis_export_envi.md)
  : Export a Measurement to ENVI Format
- [`cuvis_export_tiff()`](https://cttir.github.io/cuvis.r/reference/cuvis_export_tiff.md)
  : Export a Measurement to TIFF Format
- [`cuvis_export_session()`](https://cttir.github.io/cuvis.r/reference/cuvis_export_session.md)
  : Export a Measurement to a New Session File

## Enumerations

SDK enumeration values used by the processing functions.

- [`cuvis_processing_modes`](https://cttir.github.io/cuvis.r/reference/cuvis_processing_modes.md)
  : CUVIS Processing Modes
- [`cuvis_reference_types`](https://cttir.github.io/cuvis.r/reference/cuvis_reference_types.md)
  : CUVIS Reference Types

## Sample data

Locate and load the vendor sample recordings.

- [`cuvis_sample_data()`](https://cttir.github.io/cuvis.r/reference/cuvis_sample_data.md)
  : Get Path to Sample Data
- [`cuvis_sample_session()`](https://cttir.github.io/cuvis.r/reference/cuvis_sample_session.md)
  : Load the Default Sample Session

## Package

Package overview.

- [`cuvis.r`](https://cttir.github.io/cuvis.r/reference/cuvis.r-package.md)
  [`cuvis.r-package`](https://cttir.github.io/cuvis.r/reference/cuvis.r-package.md)
  : cuvis.r: Interface to the Cubert 'CUVIS' Hyperspectral Imaging SDK
