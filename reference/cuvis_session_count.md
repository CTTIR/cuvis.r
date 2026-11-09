# Count Session Items by SDK Enumeration Type

Asks the SDK how many items of a given type a session file holds.

## Usage

``` r
cuvis_session_count(session, item_type = "no_gaps")
```

## Arguments

- session:

  A `cuvis_session` object from
  [`cuvis_session()`](https://cttir.github.io/cuvis.r/reference/cuvis_session.md).

- item_type:

  Character. One of `"no_gaps"` (default), `"all_frames"` or
  `"references"`.

## Value

A single integer: the exact SDK count for the requested enumeration.

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  cuvis_session_count(session)
  cuvis_session_count(session, "references")
}
```
