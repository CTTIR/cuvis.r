# Get a Measurement from a Session

Extracts a single measurement from a session file by index.

## Usage

``` r
cuvis_get_measurement(session, index = 1L, item_type = "no_gaps")
```

## Arguments

- session:

  A cuvis_session object.

- index:

  Integer. 1-based measurement index.

- item_type:

  Character. Type of items to enumerate: `"no_gaps"` (default),
  `"all_frames"`, or `"references"`.

## Value

A `cuvis_measurement` S3 object, or `NULL` if no measurement exists at
that index.

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  mesu <- cuvis_get_measurement(session, 1)
  mesu
}
```
