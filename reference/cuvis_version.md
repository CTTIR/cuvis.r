# Get CUVIS SDK Version

Note: The SDK must be initialized with
[`cuvis_init()`](https://cttir.github.io/cuvis.r/reference/cuvis_init.md)
before calling this function.

## Usage

``` r
cuvis_version()
```

## Value

Character string with the SDK version.

## Examples

``` r
# Requires the proprietary Cubert CUVIS SDK.
if (cuvis_available()) {
  cuvis_init()
  cuvis_version()
}
```
