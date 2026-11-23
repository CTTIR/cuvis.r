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

# Copies of package functions that see `handler` instead of the native `.Call`.
#
# The copies live in one environment whose parent is the package namespace, so
# they call each other (and the mocked `.Call`) while every other helper still
# resolves to the real package code. S3 methods are called by their full name.
native_fixture <- function(handler, functions) {
  env <- new.env(parent = asNamespace("cuvis.r"))
  env$.Call <- mock_native(handler)
  for (name in functions) {
    fun <- get(name, asNamespace("cuvis.r"))
    environment(fun) <- env
    env[[name]] <- fun
  }
  env
}
