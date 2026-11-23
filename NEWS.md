# cuvis.r 0.2.0

## CRAN preparation

* Every exported function and object now has an example. Examples that need
  the proprietary Cubert CUVIS SDK and its sample data run only when
  `cuvis_available()` is `TRUE` and the data are found; `cuvis_shutdown()`
  stays in `\dontrun{}` because the SDK cannot be re-initialized in the same
  R process.
* Documented return values for the enumeration vectors,
  `cuvis_session_count()`, `cuvis_session_fps()` and `cuvis_has_reference()`.
* Tests against the real SDK are skipped on CRAN.
* Loading the package no longer changes `PATH`. On Windows the SDK `bin`
  directory is put on `PATH` only while an SDK call runs, and `PATH` is
  restored afterwards.
* Stub builds no longer compile unused SDK finalizers, which removes
  `-Wunused-function` compiler warnings when the SDK is absent.
* Reworded the Title and Description, declared `Language: en-US`, and use the
  standard `Apache License (>= 2)` field without a restating LICENSE file in
  the source package.
* Removed CRAN badges until the package is on CRAN, excluded development
  tools and stale tarballs from the source package, and added an
  `inst/WORDLIST`.
* Updated the maintainer e-mail address to raban.heller@uni-ulm.de.

## Bug fixes

* `cuvis_init()` now records the resolved settings directory after creating
  it. Before, a settings directory that did not exist yet (a relative path, or
  a path through a symbolic link such as the macOS temporary directory) was
  recorded unresolved, so a second `cuvis_init()` call with the same directory
  was refused as "already initialized with different settings".
* `print()` for a processing context now asks the SDK which references the
  context holds. References loaded from the session file, or set with
  `cuvis_set_reference()` without keeping the returned object, were reported
  as "No explicit references set".
* `print()` and `summary()` for measurements and sessions no longer fail when
  the SDK cannot return metadata (for example after `cuvis_shutdown()`), when
  a session index has no measurement, or when the processing mode is missing.
  Print methods now name the object class in their header.
* Functions that take a session, a measurement or a processing context report
  a wrong object with an error that names the argument and what was supplied,
  instead of a bare `inherits()` assertion. These errors, and the error for an
  unknown `item_type`, carry the condition classes `cuvis_error_bad_argument`
  and `cuvis_error`.
* `cuvis_session()` reports a missing file (class
  `cuvis_error_file_not_found`) or a directory before the SDK is called.
* `cuvis_get_measurement()` and `cuvis_session_count()` check `item_type`
  before the SDK is asked and list the valid values in the error.
* cli (>= 3.5.0) is now required, the first version with the formatting used
  in these messages.

## Documentation

* The vignettes show a single band with the image orientation (the earlier
  `image()` call drew it rotated) and plot raw signal and reflectance in
  separate, labeled panels with color-blind-safe colors instead of two
  curves on an unlabeled second axis. The list of calibration stages in the
  calibration vignette renders as a list again.
* `cuvis_get_cube()` documents the index order and orientation of the array.
  `cuvis_get_wavelengths()` and `cuvis_version()` document their return value
  when the SDK reports no wavelengths and in a stub installation.

## Packaging

* The pkgdown reference index is grouped by workflow step and the articles
  are indexed, with the introduction first.
* The README lists every exported function, installs with pak from
  `CTTIR/cuvis.r` and keeps the developer notes above the closing sections.
  `URL` and `BugReports` use the organization name as spelled on GitHub.

## Earlier development changes

* Prevent SDK calls through handles after shutdown and reject reinitialization
  or settings changes that violate the vendor's one-initialization contract.
* Validate cube buffer sizes and use wide offsets before reading native memory.
* Require explicit export overwrite permission, reject oversized paths, and
  validate scalar paths and logical arguments before native calls.
* Flush SDK output before returning and release exporters immediately; propagate
  flush failures and preserve primary errors during cleanup.
* Match sample filenames literally. Improve SDK discovery for Unix and Windows,
  require a matching library, and support explicit stub installation.
* Add native synthetic-response and configure regression checks; keep real SDK,
  calibration and file-format qualification as separate release requirements.
* Remove an unresolved draft DOI and document supported platforms and first use.
* Standardize the named v5 package logo across README, documentation pages
  and available application headers, with matching light and dark artwork.
* `cuvis_get_measurement()` now raises an informative error for an unknown
  `item_type` instead of a cryptic "subscript out of bounds" error.

# cuvis.r 0.1.0

* Initial release.
* R bindings for the Cubert CUVIS C SDK via `.Call()` interface.
* Support for loading `.cu3s` session files (`cuvis_session()`).
* Measurement extraction and metadata access.
* 3D cube extraction as R arrays with wavelength attributes.
* Full calibration pipeline: dark subtract, spectral radiance, reflectance.
* Export to ENVI, TIFF, and `.cu3s` formats.
* Stub mode for installation without the SDK present.
* Configure script for automatic SDK detection on Linux, macOS, and Windows.
