"""
   This is a *javac* annotation processor that is designed to be *called by the
   Ceylon compiler*, to produce `.car` module archives that can be *used by the
   GWT compiler*.
   
   It processes annotations available in the module
   [[ceylon.interop.gwt.annotations|module ceylon.interop.gwt.annotations]].
   
   These annotations are used by the processor to generate, and embed into
   the binary module archive, the Java source code, XML descriptors, 
   and Javascript native code required by the GWT compiler.
   
   This allows writing GWT projects *all in Ceylon*
   
   To use it for a given module, you should:
   
   - add the following line in the `[compiler.jvm]` section of your project
   Ceylon configuration file:
   
   ```
       apt=ceylon.interop.gwt.processor/1.0.0
   ```
   
   - add the [[ceylon.interop.gwt.runtime|module ceylon.interop.gwt.runtime]] module import in your module descriptor:
   
   ```
	   native("jvm") import ceylon.interop.gwt.runtime "1.0.0";
   ```
   
   - annotate your module with the following annotation from the
   [[ceylon.interop.gwt.annotations|module ceylon.interop.gwt.annotations]] package:

   ```
       gwtModule
   ```
   
   The additional resources added in the module archive (Java source files, 
   XML file, etc...) are generated in a local folder named `gwt-resources`.
   
   By default, it is located the sub-folder of the project named `generated`.
   
   However, it can also be placed in any other project sub-folder with the following
   property:
   
       javac=-A=ceylon_interop_gwt_generated_folder_name=<name of the sub-folder>

   in your config file.
   
   """
by("David Festal")
license ("http://www.apache.org/licenses/LICENSE-2.0.html")

suppressWarnings("doclink", "ceylonNamespace")
native("jvm")
module ceylon.interop.gwt.processor "1.0.0" {
	shared import com.redhat.ceylon.compiler.java "1.3.2-SNAPSHOT";
	import ceylon.interop.java "1.3.2-SNAPSHOT";
	import ceylon.interop.gwt.annotations "1.0.0";
}
