# Shut Down the CUVIS SDK

Releases all SDK resources. Call when done using cuvis.r functions. The
vendor permits initialization only once per process. After shutdown,
existing handles cannot be used and R must be restarted before another
[`cuvis_init()`](https://cttir.github.io/cuvis.r/dev/reference/cuvis_init.md)
call. Keep one initialized SDK for a batch of measurements.

## Usage

``` r
cuvis_shutdown()
```

## Value

Invisible `NULL`.
