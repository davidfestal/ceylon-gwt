"""
   This module defines annotations that are processed by the 
   [[module ceylon.interop.gwt.processor|module ceylon.interop.gwt.processor]] annotation processor
   during the Ceylon compilation, in order to produce `.car` module archives that
   can be *used by the GWT compiler*.
   
   These annotations are used by the processor to generate, and embed into
   the binary module archive, the Java source code, XML descriptors, 
   and Javascript native code required by the GWT compiler.
   
   This allows writing GWT projects *all in Ceylon*
   
   To use these annotations, you should:
   
   - add the following line in the `[compiler.jvm]` section of your project
   Ceylon configuration file:
   
   ```
       apt=ceylon.interop.gwt.processor/1.0.0
   ```
   
   - add the [[ceylon.interop.gwt.runtime|module ceylon.interop.gwt.runtime]] module import in your module descriptor:
   
   ```
	   native("jvm") import ceylon.interop.gwt.runtime "1.0.0";
   ```
   
   """
by("David Festal")
license ("http://www.apache.org/licenses/LICENSE-2.0.html")
see(`function gwtModule`, 
	`function gwtSource`, 
	`function gwtSuperSource`, 
	`function gwtPublic`)
suppressWarnings("doclink", "ceylonNamespace")
module ceylon.interop.gwt.annotations "1.0.0" {}
