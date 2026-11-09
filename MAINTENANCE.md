# Public readiness audit — 2026-10-30

Base: `89bb9c2a0b7480414e375db4a89097143e32c846`, in an isolated
worktree. The original checkout and other working sessions are
preserved. This package wraps the Cubert SDK for session enumeration,
calibrated cube extraction and export. A working stub installation is
useful for dependency resolution, but cannot establish SDK runtime,
camera or scientific calibration correctness.

## Baseline

R 4.6.1 on macOS ARM64, SDK absent: `R CMD check --as-cran` completed
with 0 errors, 0 warnings and 2 notes in 38.8 seconds. Tests report 126
passing assertions and 23 skipped SDK/sample-data tests. Notes identify
a bundled linked worktree `.git` file and the non-portable `/bin/bash`
configure shebang. The current upstream hosted checks are successful;
they do not verify the maintenance branch or provide evidence for the
skipped SDK tier.

The vendor’s public 3.6.1 Linux package was downloaded for header
inspection only, not installed or executed. Its SHA-256 matches the
vendor checksum:
`64de880e06b90a97b92fd0eca9c9d3a0dc320deab72f92307c6a89a9b3a39f60`. All
five native source files pass a syntax check against that header.
Warnings are retained (vendor comments/qualifier and standard R
registration casts). The [vendor
release](https://github.com/cubert-hyperspectral/cuvis.sdk/releases/tag/v3.6.1)
supplies Linux/Windows binaries, not a macOS runtime.

## Findings and implementation strategy

1.  **High, native lifecycle:** `rcuvis_get_handle()` permits access
    after SDK shutdown. R initialization also permits restarting a
    shutdown SDK or changing settings while initialized. The vendor
    header explicitly allows initialization only once; the existing SDK
    test contradicts its own warning and restarts it. Enforce
    initialization/retirement boundaries and canonical settings
    identity; test failure paths in isolated processes and keep real SDK
    qualification open.
2.  **High, buffer integrity:** cube conversion ignores buffer byte
    count, element size and null data, and calculates source offsets
    using signed `int` products. Check dimensions/format/length before
    allocation and use wide offsets. Verify all four formats and
    malformed buffers against a clearly synthetic native fixture; this
    is wrapper validation, not vendor runtime validation.
3.  **High, export completion:** the SDK documents asynchronous cube
    writing, but the wrapper did not flush or promptly release
    exporters. Explicitly flush before success and close on both success
    and error. The zero-initialized queue capacity also contradicts the
    SDK buffer contract; reserve one slot for the single measurement and
    disable dropping explicitly. A real-SDK deadlock was not reproduced
    on this unsupported host; exercise the actual R-to-C export path
    with synthetic responses and propagate flush failures.
4.  **High, export preservation:** session export unconditionally
    enables native overwrite. Export paths are silently truncated to
    `CUVIS_MAXBUF - 1`; logical options accept missing or nonscalar
    values. Require explicit overwrite intent, reject unsafe scalar/path
    inputs, document the migration and test that invalid requests do not
    reach SDK calls or alter existing files.
5.  **Medium, SDK discovery:** Unix configure can select a header
    without a usable library, ignores the conventional `/usr/include`
    installation, and substitutes paths through sed without escaping
    them. Windows discovery/link configuration needs equivalent
    missing-library checks. Make explicit SDK selection fail clearly;
    preserve deliberate stub installation when no SDK is requested.
6.  **Medium, sample identity:** named sample lookup treats literal
    filenames as regular expressions, so `test_mesu.cu3s` can select a
    different filename. Validate a scalar basename and match it
    literally without changing source data.
7.  **Packaging/docs:** exclude worktree metadata, use portable shell
    syntax, distinguish linked SDK from usable runtime, update vendor
    installation links and document exact first-use and restart
    behavior. Verify citation metadata before presenting a DOI as a
    published release.

Acceptance: clean stub build/install/check; meaningful R and native
boundary regressions; vendor-header compilation; validated configure
scenarios; coherent manuals/examples and a runnable first-use path.
Preserve calibration semantics and enumeration values. Camera/real
`.cu3s` processing, Windows/Linux runtime, hosted CI and publication
remain separate, explicitly unverified release gates.

## Verification

Final source package `cuvis.r_0.1.1.9000.tar.gz`: SHA-256
`9fdadf39848b83f66d6281783696798374decd19e6196ccc2ee4968c83cc37ba`. On R
4.6.1/macOS ARM64, the full `R CMD check --as-cran` completed with **0
errors, 0 warnings, 1 note** (new submission/development version).

- R suite: 88 cases, 182 passing assertions, no
  failures/errors/warnings; 22 skips require a real SDK/sample recording
  or Windows runtime.
- Native fixture: 143 checks pass against the vendor 3.6.1 header,
  including all four cube formats, malformed buffers,
  integer/string/logical inputs, post-shutdown handles, explicit
  overwrite, positive queue capacity, flush, immediate close and a flush
  failure through the actual R export function.
- Configure: five tests pass. POSIX shell checks, actionlint and diff
  checks pass. The house linter retains 13 pre-existing report-only
  style findings.
- Clean library: the exact archive installs with automatic stub
  detection; availability/version queries and SDK-unavailable
  initialization behave as documented, without creating the requested
  settings directory on failure.
- Package inspection: 128 members, 72 source/manual/test/tool files
  match the checkout byte-for-byte; DESCRIPTION fields match after
  normal R build normalization. No worktree `.git` file or
  vendor/compiled binaries are bundled.
- Documentation: pkgdown builds; 38 HTML pages and 1,221 local
  references have no missing targets. Eight browser assertions pass with
  no JavaScript errors; desktop and mobile screenshots were captured and
  the mobile page inspected.

The first post-edit checks exposed an absent checkbashisms tool, a
redirected vendor URL and an unparseable NEWS heading. These were
corrected and checks repeated. The initial native harness lacked the
SDK’s macro-declared metadata allocation symbols; that harness failure
was fixed before native results were accepted. Pandoc emits
deprecated-option notices during site generation; the site completes.
Vendor header comment warnings are retained in native logs.

Detailed logs and `verification.json` are in the workspace audit
evidence folder for cuvis.r. The original checkout remains clean at the
recorded base. No vendor binary was executed, no private source
recording accessed, and no release, hosted workflow or deployment was
performed for these changes.

## Release roadmap and remaining gates

- Essential wrapper repairs: lifecycle, native buffer integrity, literal
  sample identity, export preservation and SDK discovery are
  implemented. Synthetic fixtures must keep rejecting invalid inputs
  without native memory access.
- Dependable use: install the final source package in a clean library,
  verify stub first use, run the complete R check, and verify
  manuals/site navigation. The README records the intentional overwrite
  change and process restart rule.
- Supported-host qualification: on Linux and Windows, install SDK 3.6.1
  plus the applicable calibration and a complete exportable `.cu3s`
  fixture. Run the SDK test tier, compare raw/reflectance results with
  the vendor tools, reopen ENVI, TIFF and session exports, and verify
  paths/runtime dependencies. SDK errors now fail the export test rather
  than being silently converted into skips. No real-runtime or
  scientific-validity claim follows from the synthetic tier.
- Publication: run hosted checks on the reviewed branch, choose the
  release version and confirm the package/release target, then publish
  only with authorization. Zenodo record 21889930 and its DOI both
  returned HTTP 404 on 2026-10-30; draft metadata remains, without a
  claimed published DOI.
- Deferred: replace 13 existing
  [`stopifnot()`](https://rdrr.io/r/base/stopifnot.html) style findings
  with a consistent public condition-class scheme in a separate
  compatibility-reviewed change. The house lint workflow remains
  report-only as before. No speculative camera acquisition,
  visualization or parallel processing features were added.

Windows DLL dependencies must be discoverable on PATH before R starts.
The package’s path-discovery helper is tested in isolation; this is not
proof of a successful Windows DLL load. After SDK shutdown, restart R
rather than unloading and reloading the package. Concurrent exports to
one directory are unsupported.

## Runnable first use

Requirements: R \>= 4.1, a C compiler and the R dependencies declared in
DESCRIPTION. From this checkout, a supported SDK host sets CUVIS_SDK
before installation and CUVIS_SETTINGS before initialization. Windows
also needs the SDK runtime bin directory on PATH before R starts. macOS
can validate only the stub on the currently published SDK platforms.

``` sh
Rscript -e 'install.packages(c("cli", "rlang"))'
CUVIS_STUB=1 R CMD INSTALL .
Rscript -e 'library(cuvis.r); stopifnot(!cuvis_available())'
python3 tools/test-configure.py
python3 tools/test-native.py /path/to/vendor/cuvis.h
```

For actual recordings, install without CUVIS_STUB after configuring the
vendor SDK. Follow the README calibration example with the correct
factory calibration and references, use an empty export directory, and
shut down only after the whole batch. The immediate next release action
is supported-host qualification and comparison with vendor output;
publication is not authorized by this audit.
