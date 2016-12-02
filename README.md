# Ceylon GWT integration

This integration is a proof of concept, that already works well with a
(very) limited (non-defined) subset of Ceylon constructs.

More supported Ceylon constructs / libraries will be added in the future.  
    
The integration is based on a *javac* annotation processor that is designed
to be *called by the Ceylon compiler*, to produce `.car` module archives
that can be *used by the GWT compiler*.

It processes annotations available in the
[`ceylon.interop.gwt.annotations` module](./ceylon.interop.gwt.annotations/source/ceylon/interop/gwt/annotations/module.ceylon).

These annotations are used by the processor to generate, and embed into
the binary module archive, the Java source code, XML descriptors, 
and Javascript native code required by the GWT compiler.

This allows writing GWT projects *all in Ceylon*

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

Besides the projects that are part of the Ceylon - GWT integration, this repository also provides a [sample project](./gwt-ceylon-project-sample).

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

