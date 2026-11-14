## Submission

This is a new submission.

`cuvis.r` is an interface to the Cubert 'CUVIS' C SDK for hyperspectral
snapshot cameras. The SDK is proprietary but distributed free of charge by the
vendor (<https://github.com/cubert-hyperspectral/cuvis.sdk/releases>) for
Linux and Windows. It is declared in `SystemRequirements` and is **not**
required to install or check the package:

* `configure` / `configure.win` look for the SDK (`CUVIS_SDK`, `CUVIS` or the
  standard install locations). When it is not found, the package is compiled
  in a stub mode (`-DCUVIS_STUB`): every native entry point is still
  registered, `cuvis_available()` returns `FALSE`, and SDK operations raise an
  informative error.
* Examples that need the SDK and vendor sample data are wrapped in
  `if (cuvis_available() && ...)` and therefore do nothing on machines without
  the SDK. Only `cuvis_shutdown()` uses `\dontrun{}`: the vendor SDK cannot be
  re-initialized within the same R process, so running it would break any
  later example.
* Tests that need the SDK call `skip_on_cran()` and skip when
  `cuvis_available()` is `FALSE`; the remaining unit tests exercise argument
  validation, stub behaviour and the R-level logic.
* The vignettes show SDK usage with `eval = FALSE`.

## Test environments

* Local: macOS (aarch64-apple-darwin), R 4.6.1, 14 November 2026:
  full `R CMD check --as-cran` on the built source tarball, including
  PDF manual compilation with TinyTeX (TeX Live 2026) and HTML manual
  validation. This supersedes the earlier local check environment.
* GitHub Actions (r-lib/actions v2, `--as-cran`):
  * macOS-latest (release)
  * windows-latest (release)
  * ubuntu-latest (devel, release, oldrel-1)

All environments build the stub variant because the SDK is not installed on
the runners.

## R CMD check results

0 errors | 0 warnings | 1 note (latest local full check)

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'R. Heller <raban.heller@uni-ulm.de>'
  New submission

  This is the first submission of this package.

The latest local full check did not report the earlier missing
'checkbashisms' WARNING. A separate static check on 14 November 2026 ran
Debian's `checkbashisms.pl` with `--posix --force` over `configure`,
`configure.win`, `cleanup` and `tools/configure-sdk.sh`; it exited with
status zero and no diagnostic output. This static check does not qualify
proprietary SDK execution, hardware access or other operating systems.

## Downstream dependencies

There are currently no downstream dependencies on CRAN.
