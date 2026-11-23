# Get CUVIS SDK Version

Note: The SDK must be initialised with
[`cuvis_init()`](https://cttir.github.io/cuvis.r/reference/cuvis_init.md)
before calling this function.

## Usage

``` r
cuvis_version()
```

## Value

Character string with the SDK version. A stub installation (no SDK
linked,
[`cuvis_available()`](https://cttir.github.io/cuvis.r/reference/cuvis_available.md)
is `FALSE`) returns `"stub-0.0.0"`.

## Examples

``` r
# Requires the proprietary Cubert CUVIS SDK.
if (cuvis_available()) {
  cuvis_init()
  cuvis_version()
}
```
