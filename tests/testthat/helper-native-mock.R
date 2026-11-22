# Build a stand-in for `.Call` that is bound in a function's environment.
#
# The package addresses native routines by name, so only calls whose first
# argument is a single string belong to the code under test. Anything else
# (for example the counters a coverage tool injects, which pass a native
# symbol object) is forwarded to the real `.Call` untouched.
mock_native <- function(handler) {
  force(handler)
  function(.NAME, ...) {
    if (is.character(.NAME) && length(.NAME) == 1L) {
      return(handler(.NAME, ...))
    }
    base::.Call(.NAME, ...)
  }
}
