# cuvis.r: Interface to the Cubert 'CUVIS' Hyperspectral Imaging SDK

Provides an interface to the Cubert 'CUVIS' C software development kit
(SDK) for reading, processing and exporting hyperspectral imaging data
recorded with Cubert snapshot cameras. It supports loading proprietary
'.cu3s' session files, applying the full calibration pipeline (dark
subtraction, white reference normalization, spectral radiance,
reflectance) and exporting to standard formats ('ENVI', 'TIFF'). The
interface mirrors the API of 'cuvis.python'
<https://github.com/cubert-hyperspectral/cuvis.python>. The 'CUVIS' SDK
is not distributed with this package and must be installed separately;
without it the package installs in a stub mode in which
cuvis_available() returns FALSE and SDK operations are unavailable.

## See also

Useful links:

- <https://github.com/cttir/cuvis.r>

- <https://cttir.github.io/cuvis.r/>

- Report bugs at <https://github.com/cttir/cuvis.r/issues>

## Author

**Maintainer**: R. Heller <raban.heller@uni-ulm.de>
([ORCID](https://orcid.org/0000-0001-8006-9742))

Authors:

- R. Heller <raban.heller@uni-ulm.de>
  ([ORCID](https://orcid.org/0000-0001-8006-9742))
