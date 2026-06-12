# Get Path to Sample Data

Returns the path to Cubert sample data. Searches in order:

1.  `.cuvis/` directory in the working directory or any parent (up to 5
    levels)

2.  `CUVIS_DATA` environment variable

3.  SDK default install location

## Usage

``` r
cuvis_sample_data(file = NULL)
```

## Arguments

- file:

  Character. Specific file name (e.g., `"test_mesu.cu3s"`). If `NULL`,
  returns the sample data root directory.

## Value

Character path, or `NULL` if not found.
