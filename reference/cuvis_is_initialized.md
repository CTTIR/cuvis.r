# Is the CUVIS SDK Currently Initialized?

Reports whether
[`cuvis_init()`](https://cttir.github.io/cuvis.r/reference/cuvis_init.md)
has been called successfully in this R process and the SDK has not been
shut down since.

## Usage

``` r
cuvis_is_initialized()
```

## Value

A single logical value.

## Examples

``` r
cuvis_is_initialized()
#> [1] FALSE
```
