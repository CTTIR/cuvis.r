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
* Stub builds no longer compile unused SDK finalizers, which removes
  `-Wunused-function` compiler warnings when the SDK is absent.
* Reworded the Title and Description, declared `Language: en-US`, and use the
  standard `Apache License (>= 2)` field without a restating LICENSE file in
  the source package.
* Removed CRAN badges until the package is on CRAN, excluded development
  tools and stale tarballs from the source package, and added an
  `inst/WORDLIST`.
* Updated the maintainer e-mail address to raban.heller@uni-ulm.de.

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
