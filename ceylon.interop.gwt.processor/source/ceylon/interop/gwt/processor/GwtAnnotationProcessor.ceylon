import ceylon.collection {
    HashMap
}
import ceylon.interop.gwt.annotations {
    GwtModuleAnnotation,
    GwtSourceAnnotation,
    GwtPublicAnnotation,
    GwtSuperSourceAnnotation
}
import ceylon.interop.java {
    javaString,
    javaAnnotationClass,
    JavaSet,
    JavaIterable
}

import com.redhat.ceylon.compiler.java.tools {
    CeylonLocation,
    CeyloncFileManager,
    LanguageCompiler
}
import com.redhat.ceylon.javax.annotation.processing {
    supportedSourceVersion,
    AbstractProcessor,
    ProcessingEnvironment,
    RoundEnvironment,
    Filer
}
import com.redhat.ceylon.javax.lang.model {
    SourceVersion
}
import com.redhat.ceylon.javax.lang.model.element {
    TypeElement,
    Modifier,
    AnnotationMirror,
    PackageElement
}
import com.redhat.ceylon.javax.tools {
    Diagnostic,
    StandardLocation,
    JavaFileManager
}
import com.redhat.ceylon.langtools.source.tree {
    CompilationUnitTree,
    Tree
}
import com.redhat.ceylon.langtools.source.util {
    Trees
}
import com.redhat.ceylon.langtools.tools.javac.code {
    Symbol
}
import com.redhat.ceylon.langtools.tools.javac.file {
    RegularFileObject
}
import com.redhat.ceylon.langtools.tools.javac.processing {
    JavacProcessingEnvironment
}
import com.redhat.ceylon.langtools.tools.javac.tree {
    JCTree
}

import java.io {
    File
}
import java.lang {
    JavaClass=Class
}
import java.util {
    Set
}

supportedSourceVersion { \ivalue = SourceVersion.release7; }
shared class GwtAnnotationProcessor extends AbstractProcessor {
	
	shared static JavaClass<out Annotation> moduleAnnotationClass = javaAnnotationClass<GwtModuleAnnotation>();
	shared static JavaClass<out Annotation> sourceAnnotationClass = javaAnnotationClass<GwtSourceAnnotation>();
	shared static JavaClass<out Annotation> superSourceAnnotationClass = javaAnnotationClass<GwtSuperSourceAnnotation>();
	shared static JavaClass<out Annotation> publicAnnotationClass = javaAnnotationClass<GwtPublicAnnotation>();
	shared static JavaClass<out Annotation> nativeAnnotationClass = javaAnnotationClass<NativeAnnotation>();
	
	shared static String generatedFolderNameOption = "ceylon.interop.gwt.generated_folder_name";
	
	shared new() extends AbstractProcessor() {
		
	}

	late Trees trees;
	late Filer filer;
	late variable CeyloncFileManager fileManager;
	
	void reportError(String message, CompilationUnitTree? cu = null, Tree? node = null, AnnotationMirror? annotationMirror = null) {
		if (exists node,
			exists path = trees.getPath(cu, node),
			exists element = trees.getElement(path)) {
			processingEnv.messager.printMessage(Diagnostic.Kind.error, message, element, annotationMirror);
		} else if (is JCTree.JCCompilationUnit jcu = cu,
			jcu.defs.nonEmpty(),
			exists path = trees.getPath(cu, jcu.defs.get(0)),
			exists element = trees.getElement(path)) {
			processingEnv.messager.printMessage(Diagnostic.Kind.error, message, element, annotationMirror);
		} else {
			processingEnv.messager.printMessage(Diagnostic.Kind.error, message);
		}
	}
	
	supportedOptions => JavaSet(set{ javaString(generatedFolderNameOption) });
	
	supportedAnnotationTypes => JavaSet(set{
		javaString("``moduleAnnotationClass.\ipackage.name``.*"),
		javaString(nativeAnnotationClass.name.replace("$annotation$", ".*"))
	});
	
	shared actual void init(ProcessingEnvironment processingEnv) {
		super.init(processingEnv);
		trees = Trees.instance(processingEnv);
		filer = processingEnv.filer;
		assert(is JavacProcessingEnvironment jpe = this.processingEnv,
			exists context = jpe.context,
			is CeyloncFileManager fm = context.get(`JavaFileManager`));
		fileManager = fm;
		assert(exists classOutput = {*fileManager.getLocation(StandardLocation.classOutput)}.first);
		
		value generatedFilesFolder = File(classOutput.parentFile,
			processingEnv.options.get(javaString(generatedFolderNameOption))?.string else "generated");
		value generatedGwtResourcesFolder = File(generatedFilesFolder, "gwt-resources");
		generatedGwtResourcesFolder.mkdirs();
		fileManager.setLocation(CeylonLocation.resourcePath, JavaIterable { generatedGwtResourcesFolder, *fileManager.getLocation(CeylonLocation.resourcePath) });
	}
	
	
	shared actual Boolean process(Set<out TypeElement> annotations, RoundEnvironment roundEnv) {

		assert(is JavacProcessingEnvironment jpe = this.processingEnv,
			exists context = jpe.context,
			is LanguageCompiler languageCompiler = LanguageCompiler.instance(context),
			exists ceylonContext = context.get(LanguageCompiler.ceylonContextKey));
		
		value gwtModel = HashMap<String, GwtModule>();
		
		// TODO: For each module, search for a module descriptor file and build the gwtModel from the found descriptors.
		
		for (element in roundEnv.getElementsAnnotatedWith(moduleAnnotationClass)) {
			if (is PackageElement pkgElem = element.enclosingElement) {
				value moduleName = pkgElem.qualifiedName.string;
				value m = { * ceylonContext.modules.listOfModules }.find((m) => m.nameAsString == moduleName);
				if (! exists m) {
					reportError("Module '`` moduleName ``' is not found in the Ceylon model", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
					return true;
				}
				
				value moduleAnnotation = element.getAnnotation(moduleAnnotationClass);
				gwtModel.put(moduleName, GwtModule.fromModel(m, moduleAnnotation));
			}
		}

		for (element in roundEnv.getElementsAnnotatedWith(sourceAnnotationClass)) {
			if (is PackageElement pkgElem = element.enclosingElement) {
				value pkgName = pkgElem.qualifiedName.string;
				value p = { * ceylonContext.modules.listOfModules }.flatMap((m) => { *m.packages }).find((p) => p.nameAsString == pkgName);
				if (! exists p) {
					reportError("The package '`` pkgName ``' is not found in any Ceylon module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
					return true;
				}
				value parentModule = gwtModel[p.\imodule.nameAsString];
				if (! exists parentModule) {
					reportError("The GWT source package '`` pkgName ``' is in a non-GWT module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
					return true;
				}

				value sourceAnnotation = element.getAnnotation(sourceAnnotationClass);
				parentModule.addSource(GwtSource.fromModel(p, sourceAnnotation));
			}
		}

		for (element in roundEnv.getElementsAnnotatedWith(superSourceAnnotationClass)) {
			if (is PackageElement pkgElem = element.enclosingElement) {
				value pkgName = pkgElem.qualifiedName.string;
				value p = { * ceylonContext.modules.listOfModules }.flatMap((m) => { *m.packages }).find((p) => p.nameAsString == pkgName);
				if (! exists p) {
					reportError("The package '`` pkgName ``' is not found in any Ceylon module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
					return true;
				}
				value parentModule = gwtModel[p.\imodule.nameAsString];
				if (! exists parentModule) {
					reportError("The GWT source package '`` pkgName ``' is in a non-GWT module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
					return true;
				}
				
				parentModule.addSuperSource(GwtSuperSource.fromModel(p));
			}
		}
		
		for (element in roundEnv.getElementsAnnotatedWith(publicAnnotationClass)) {
			if (is PackageElement pkgElem = element.enclosingElement) {
				value pkgName = pkgElem.qualifiedName.string;
				value p = { * ceylonContext.modules.listOfModules }.flatMap((m) => { *m.packages }).find((p) => p.nameAsString == pkgName);
				if (! exists p) {
					reportError("The package '`` pkgName ``' is not found in any Ceylon module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
					return true;
				}
				value parentModule = gwtModel[p.\imodule.nameAsString];
				if (! exists parentModule) {
					reportError("The GWT public package '`` pkgName ``' is in a non-GWT module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
					return true;
				}
				parentModule.addPublic(GwtPublic.fromModel(p));
			}
		}
		
		value gwtSourcePackages = [ 
			for (m in gwtModel.items)
				for (p in m.sources.items)
					p.packageQualifiedName
		];

		value gwtSuperSourcePackages = [ 
    		for (m in gwtModel.items)
        		for (p in m.superSources.items)
            		p.packageQualifiedName
		];
		
		value map = HashMap<JCTree.JCClassDecl, JCTree.JCCompilationUnit>();
		for (element in roundEnv.getElementsAnnotatedWith(nativeAnnotationClass)) {
			Symbol.ClassSymbol elementClass;
			if (is Symbol.ClassSymbol element) {
				elementClass = element;
			} else if (is Symbol.MethodSymbol element) {
				elementClass = element.outermostClass();
			} else {
				continue;
			}
			if (is PackageElement pkgElem = elementClass.enclosingElement,
				pkgElem.qualifiedName.string in gwtSourcePackages ||
						gwtSuperSourcePackages.any((p) => p in pkgElem.qualifiedName.string),
				exists path = trees.getPath(elementClass),
				is JCTree.JCCompilationUnit cu = path.compilationUnit,
				is JCTree.JCClassDecl classToWrite = path.leaf,
				
				isTopLevel(classToWrite)) {
				map.put(classToWrite, cu);
			}
		}
		
		function declarationReferenceToClassName(String declRef) {
			value splitted = declRef.split(':'.equals).sequence().reversed;
			assert(exists decl = splitted[0],
				!decl.empty,
				decl.occursAt(0, 'C'), // should be a class
				exists pkg = splitted[1],
				! pkg.empty,
				exists mod = splitted[2],
				! mod.empty);
			String javaClassName;
			if (pkg.occursAt(0, '.')) {
				// absolute package
				javaClassName = pkg + "." + decl.removeInitial("C");
			} else {
				// relativePackage
				javaClassName = mod + "." + pkg + "." + decl.removeInitial("C");
			}
			return javaClassName;
		}
		
		for (gwtModule in gwtModel.items) {
			value moduleXMLFile = filer.createResource(
				CeylonLocation.resourcePath, 
				javaString(gwtModule.packageQualifiedName), 
				javaString(gwtModule.name+ ".gwt.xml") , null);
			
			value lines = concatenate({
				"<module>"
			},{
				"  <inherits name=\"ceylon.interop.gwt.runtime.Runtime\"/>"
			},{
				for (inherits in gwtModule.inherits)
				"  <inherits name=\"`` inherits ``\"/>"
			},{
				for (entry in gwtModule.externalEntryPoints)
				"  <entry-point class=\"`` entry ``\" />"
			},{ 
				for (source in gwtModule.sources.items) 
				for (declRef in source.entryPoints)
				"  <entry-point class=\"`` declarationReferenceToClassName(declRef) ``\" />" 
			},{
				for (sourceQualifiedName in gwtModule.sources*.key)
				"  <source path=\"`` sourceQualifiedName.removeInitial(gwtModule.packageQualifiedName + ".") ``\" />"
			},{
				for (sourceQualifiedName in gwtModule.superSources*.key)
				"  <super-source path=\"`` sourceQualifiedName.removeInitial(gwtModule.packageQualifiedName + ".") ``\" />"
			},{
				for (publicQualifiedName in gwtModule.publics*.key)
				"  <public path=\"`` publicQualifiedName.removeInitial(gwtModule.packageQualifiedName + ".")``\" />"
			},{
				for (sheet in gwtModule.stylesheets)
				"  <stylesheet src=\"`` sheet ``\" />"
			},{
				for (script in gwtModule.scripts)
				"  <script src=\"`` script ``\" />"
			},{
				"</module>"
			});
			
			try (writer = moduleXMLFile.openWriter()) {
				for (line in lines) {
					writer.write("``line``\n");
				}
			}
			languageCompiler.addResourceFileObject(RegularFileObject(fileManager, File(moduleXMLFile.toUri())));
		}

		for (cu -> classesToWrite in map.inverse()) {
			value publicClasses = classesToWrite.select((classDecl) => 
				Modifier.public in classDecl.modifiers.flags);
			
			if (publicClasses.size > 1) {
				print("Java source file should contain exactly one public class");
				reportError("Java source file should contain exactly one public class", cu, publicClasses.first);
				return true;
			}

			JCTree.JCClassDecl mainClass;
			if (nonempty publicClasses) {
				mainClass = publicClasses.first;
			} else {
				mainClass = classesToWrite.first;
			}
			
			value pkgName = cu.packageName.string;
			value relativeName = "``mainClass.name``.java";
			value source = filer.createResource(CeylonLocation.resourcePath, javaString(pkgName), javaString(relativeName) , null);
			try (writer = source.openWriter()) {
				GwtJavaRenderer(writer, classesToWrite, gwtSuperSourcePackages).renderAsJavaSource(cu);
			}

			languageCompiler.addResourceFileObject(RegularFileObject(fileManager, File(source.toUri())));
		}
		return true;
	}
}
