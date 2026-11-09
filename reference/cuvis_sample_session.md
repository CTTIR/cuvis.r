# Load the Default Sample Session

Convenience function that locates and loads the first `.cu3s` file found
in the sample data directories.

## Usage

``` r
cuvis_sample_session()
```

## Value

A cuvis_session object, or `NULL` with a warning if sample data is not
found.

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data())) {
  cuvis_init()
  session <- cuvis_sample_session()
  session
}
```
