# cuvis.r (development version)

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
