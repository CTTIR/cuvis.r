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

Invisible `ctx`. The reference is stored in the SDK processing context
behind the external pointer, so it takes effect whether or not the
returned object is kept; check it with
[`cuvis_has_reference()`](https://cttir.github.io/cuvis.r/reference/cuvis_has_reference.md).

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  ctx <- cuvis_processing_context(session)
  refs <- cuvis_session_count(session, "references")
  if (refs > 0) {
    dark <- cuvis_get_measurement(session, 1, item_type = "references")
    cuvis_set_reference(ctx, dark, type = "dark")
  }
}
```
