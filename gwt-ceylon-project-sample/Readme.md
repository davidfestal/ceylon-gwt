# Sample Ceylon-GWT application.

The GWT entry point is in the client sub-package.

Demonstrated features are:
- Automatic generation of the GWT module descriptor, with an automatically-included stylesheet.
- Support of optional strings or basic types (Integer, Float, etc...) through emulated classes.
- Support of a number of Ceylon-specific constructs such as:
    - `if-then-else` expressions,
    - `let` expressions,
    - function references,
    - functional values,
    - inline object expressions,
    - `else` keyword.
- Support for delegating a top-level GWT function to a `native("js")` Ceylon method
in which the full power of the Ceylon language can be leveraged on the Javascript
platform.
- Support for implementing the body of a GWT function directly in Javascript
with the JSNI rules.

For the moment, Ceylon iterables and collections are not supported in GWT code,
but they can of course be used in a `native("js")` top-level function called from
your GWT code by delegation.
