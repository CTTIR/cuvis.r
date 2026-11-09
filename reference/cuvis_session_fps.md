# Read the Nominal Frame Rate of a Session

Returns the frame rate the SDK reports for a session file.

## Usage

``` r
cuvis_session_fps(session)
```

## Arguments

- session:

  A `cuvis_session` object from
  [`cuvis_session()`](https://cttir.github.io/cuvis.r/reference/cuvis_session.md).

## Value

A single positive number (frames per second) as reported by the SDK, or
`NA` when unavailable. It is never derived from timestamps.

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  cuvis_session_fps(session)
}
```
