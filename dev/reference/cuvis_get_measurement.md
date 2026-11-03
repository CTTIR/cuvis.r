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
