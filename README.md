# Ceylon GWT integration

The integration is based on a *javac* annotation processor that is designed
to be *called by the Ceylon compiler*, to produce `.car` module archives
that can be *used by the GWT compiler*.

It processes annotations available in the
[`ceylon.interop.gwt.annotations` module](./ceylon.interop.gwt.annotations/source/ceylon/interop/gwt/annotations/module.ceylon).

These annotations are used by the processor to generate, and embed into
the binary module archive, the Java source code, XML descriptors, 
and Javascript native code required by the GWT compiler.

This allows writing GWT projects *all in Ceylon*

## Features

This integration started as a proof of concept, but has already progressed to
support most basic Ceylon language constructs, and provide a substantial
set of features.

However, more supported Ceylon constructs / libraries will be added in the future.
    
Current features are:
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

All these features are demonstrated in the [sample project](#sample-project).

## Unsupported Ceylon features

For the moment, the following features are not supported in GWT code:
- Ceylon iterables and collections defined in the language module,
- Tuples,
- reified generics,
- metamodel,
- functions or classes that involves at least one unsupported element.

In fact Ceylon code that only use basic types (String, Byte, Integer, Float, Boolean),
Java JDK and GWT APIs should be supported.

If something is not supported, this will either:
- output an error during the Ceylon build, poiting to the unsupported element,
- output an error when running the GWT compiler on the generated module CAR achive.

However, keep in mind that all the Ceylon features are supported in a `native("js")`
top-level function called from your GWT code by delegation.

## How to use the integration

To use it for a given module, you should:
- add the following line in the `[compiler.jvm]` section of your project 
Ceylon configuration file:
```
    apt=ceylon.interop.gwt.processor/1.0.0
```
- add the [`ceylon.interop.gwt.runtime` module](./ceylon.interop.gwt.runtime/source/ceylon/interop/gwt/runtime/module.ceylon) import in your module descriptor:
```
    native("jvm") import ceylon.interop.gwt.runtime "1.0.0";
```
- annotate your module with the following annotation from the
[`ceylon.interop.gwt.annotations` package](./ceylon.interop.gwt.annotations/source/ceylon/interop/gwt/annotations/package.ceylon):
```
    gwtModule
```

The additional resources added in the module archive (Java source files, XML file, etc...) are generated in a local
folder named `gwt-resources`.

By default, it is located in a sub-folder of the project named `generated`.

However, it can also be placed in any other project sub-folder with the following
property:
    
```
    javac=-A=ceylon_interop_gwt_generated_folder_name=<name of the sub-folder>
```
in your config file.

## Sample project

Besides the projects that are part of the Ceylon - GWT integration,
this repository also provides a [sample project](./gwt-ceylon-project-sample) that
demonstrates the currently supported features.

## Important notice

The Ceylon GWT integration requires the `1.3.2-SNAPHOT` version of the Ceylon distribution.

The Ceylon modules are not in Herd, so that you will have to build them yourself against the current
master sources of the Ceylon distribution and SDK.

So to test you should:
- have GWT 2.7.0+ installed locally and available in your path 
- build the last Eclipse Ceylon Ide from master sources.
- import all the Eclipse projects found under the `ceylon-gwt` root directory
- clean build all those projects
- In the `gwt-ceylon-project-sample` directory, run the following command:
```
    ant devmode
```
- The GWT DevMode window should open with the URL to test the sample project compiled to JS.

## Contribute

### Open issues !

The first great way to contribute is to __*try it*__, and open an issue each time
some code that [should be supported](#unsupported-ceylon-features) fails to compile
in either the Ceylon compiler or the GWT compiler.

### Contribute to code

Pull requests are welcome !

By setting up the environment as described in the [previous notice](important-notice), you
will be able to:
- make changes to the source code of the annotation processor,
in the `ceylon.interop.gwt.processor` module which is where most useful code changes
will occur,
- rebuild it,
- rebuild the sample project: it will automatically use the modified annotation processor,
and test your changes. 

