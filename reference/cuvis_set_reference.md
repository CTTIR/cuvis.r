# Set a Calibration Reference

Assigns a reference measurement (dark, white, etc.) to a processing
context.

## Usage

``` r
cuvis_set_reference(
  ctx,
  measurement,
  type = c("dark", "white", "white_dark", "sprad", "distance")
)
```

## Arguments

- ctx:

  A cuvis_processing_context object.

- measurement:

  A cuvis_measurement object (the reference frame).

- type:

  Character. One of `"dark"`, `"white"`, `"white_dark"`, `"sprad"`, or
  `"distance"`.

## Value

Invisible `ctx` (modified in place via external pointer).
