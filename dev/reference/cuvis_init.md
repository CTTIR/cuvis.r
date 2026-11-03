# Initialize the CUVIS SDK

Must be called before any other cuvis.r function. Loads the Cubert CUVIS
SDK and configures the user settings directory.

## Usage

``` r
cuvis_init(settings_dir = NULL)
```

## Arguments

- settings_dir:

  Character. Path to the CUVIS settings directory — the one holding
  `factory/` and `user/`. If `NULL` (default), the directory is
  discovered in this order: the `CUVIS_SETTINGS` environment variable,
  then the standard install locations for the platform, and only as a
  last resort a temporary directory.

## Value

Invisible `NULL`.

## Details

The settings directory is not optional in practice. The SDK loads its
factory calibration from it, and pointing it at an empty directory makes
every subsequent `cuvis_proc_cont_apply()` fail with "Could not process
measurement" — which looks like a corrupt recording rather than a
configuration problem. Hence the search over real install locations
before falling back to a temporary directory, and the warning when it
does.

## Examples

``` r
if (FALSE) { # \dontrun{
cuvis_init()
# ... use SDK ...
cuvis_shutdown()
} # }
```
