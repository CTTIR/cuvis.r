# Initialize the CUVIS SDK

Must be called before any other cuvis.r function. Loads the Cubert CUVIS
SDK and configures the user settings directory.

## Usage

``` r
cuvis_init(settings_dir = NULL)
```

## Arguments

- settings_dir:

  Character. Path to CUVIS user settings directory. If `NULL` (default),
  uses the `CUVIS_SETTINGS` environment variable, or a temporary
  directory.

## Value

Invisible `NULL`.

## Examples

``` r
if (FALSE) { # \dontrun{
cuvis_init()
# ... use SDK ...
cuvis_shutdown()
} # }
```
