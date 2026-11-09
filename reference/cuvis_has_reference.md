# Check if a Reference is Set

Check if a Reference is Set

## Usage

``` r
cuvis_has_reference(
  ctx,
  type = c("dark", "white", "white_dark", "sprad", "distance")
)
```

## Arguments

- ctx:

  A cuvis_processing_context object.

- type:

  Character. Reference type to check: `"dark"`, `"white"`,
  `"white_dark"`, `"sprad"` or `"distance"`.

## Value

A single logical value: `TRUE` if the context holds a reference of that
type.

## Examples

``` r
# Runs only where the proprietary Cubert CUVIS SDK and its sample data
# are installed; elsewhere cuvis_available() is FALSE and nothing happens.
if (cuvis_available() && !is.null(cuvis_sample_data("test_mesu.cu3s"))) {
  cuvis_init()
  session <- cuvis_session(cuvis_sample_data("test_mesu.cu3s"))
  ctx <- cuvis_processing_context(session)
  cuvis_has_reference(ctx, "dark")
  cuvis_has_reference(ctx, "white")
}
```
