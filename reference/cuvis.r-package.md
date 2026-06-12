# cuvis.r: R Bindings for the Cubert CUVIS Hyperspectral SDK

Provides R bindings to the Cubert CUVIS C SDK for reading, processing,
and exporting hyperspectral imaging data from Cubert snapshot cameras.
Supports loading proprietary '.cu3s' session files, applying the full
calibration pipeline (dark subtraction, white reference normalization,
spectral radiance, reflectance), and exporting to standard formats
(ENVI, TIFF). Requires the Cubert CUVIS SDK to be installed separately.
This package mirrors the API of 'cuvis.python'
(<https://github.com/cubert-hyperspectral/cuvis.python>) for R users.

## See also

Useful links:

- <https://github.com/r-heller/cuvis.r>

- <https://r-heller.github.io/cuvis.r/>

- Report bugs at <https://github.com/r-heller/cuvis.r/issues>

## Author

**Maintainer**: Raban Heller <raban.heller@charite.de>
([ORCID](https://orcid.org/0000-0001-8006-9742))
