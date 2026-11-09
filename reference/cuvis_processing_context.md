# Create a Processing Context for Calibration

Creates a processing context from a session file or measurement. This
context holds calibration references and processing parameters for
reprocessing measurements.

## Usage

``` r
cuvis_processing_context(base, load_references = TRUE)
```

## Arguments

- base:

  A cuvis_session or cuvis_measurement object.

- load_references:

  Logical. If `TRUE` (default), automatically loads references embedded
  in the session file.

## Value

A `cuvis_processing_context` S3 object.

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  ctx <- cuvis_processing_context(session)
  ctx
}
```
