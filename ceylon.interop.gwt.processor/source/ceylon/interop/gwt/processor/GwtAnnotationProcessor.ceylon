import ceylon.collection {
    HashMap
}
import ceylon.file {
    parsePath,
    Visitor,
    CeylonFile=File,
    Directory
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

import com.redhat.ceylon.cmr.api {
    ArtifactContext
}
import com.redhat.ceylon.common.tool {
    ToolException,
    ToolError
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
    JavaFileManager,
    JavaFileObject
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
import com.redhat.ceylon.langtools.tools.javac.main {
    JavacOption=Option
}
import com.redhat.ceylon.langtools.tools.javac.processing {
    JavacProcessingEnvironment,
    JavacMessager
}
import com.redhat.ceylon.langtools.tools.javac.tree {
    JCTree
}
import com.redhat.ceylon.langtools.tools.javac.util {
    Log,
    Context,
    JavacOptions=Options
}
import com.redhat.ceylon.tools.copy {
    CeylonCopyTool
}

import java.io {
    File
}
import java.lang {
    JavaClass=Class
}
import java.util {
    Set,
    Arrays
}

supportedSourceVersion { \ivalue = SourceVersion.release7; }
shared class GwtAnnotationProcessor extends AbstractProcessor {
    
    shared static
    JavaClass<out Annotation> moduleAnnotationClass = javaAnnotationClass<GwtModuleAnnotation>();
    shared static
    JavaClass<out Annotation> sourceAnnotationClass = javaAnnotationClass<GwtSourceAnnotation>();
    shared static
    JavaClass<out Annotation> superSourceAnnotationClass = javaAnnotationClass<GwtSuperSourceAnnotation>();
    shared static
    JavaClass<out Annotation> publicAnnotationClass = javaAnnotationClass<GwtPublicAnnotation>();
    shared static
    JavaClass<out Annotation> nativeAnnotationClass = javaAnnotationClass<NativeAnnotation>();
    
    shared static
    String generatedFolderNameOption = "ceylon.interop.gwt.generated_folder_name";
    shared static
    String generatedScriptsSubPackage = "generatedScripts";
    
    "Be carefull: this should be synchrnoized with the value in ceylon.interop.gwt.runtime::bootstrapCeylonJsScript"
    shared static
    String bootstrapCeylonJsScript = "bootsrapCeylonJs.js";
    
    shared new () extends AbstractProcessor() {
    }
    
    late Trees trees;
    late Filer filer;
    late variable CeyloncFileManager fileManager;
    late variable Context context;
    late File generatedGwtResourcesFolder;
    
    supportedOptions => JavaSet(set { javaString(generatedFolderNameOption) });
    
    supportedAnnotationTypes => JavaSet(set {
            javaString("``moduleAnnotationClass.\ipackage.name``.*"),
            javaString(nativeAnnotationClass.name.replace("$annotation$", ".*"))
        });
    
    void reportError(String message, CompilationUnitTree? cu = null, Tree? node = null, AnnotationMirror? annotationMirror = null) {
        assert (is JavacMessager messager = processingEnv.messager);
        
        if (messager.errorCount() == 0) {
            messager.printMessage(Diagnostic.Kind.error, "Ceylon-GWT source code generation failed");
        }
        
        if (is JCTree node,
            is JCTree.JCCompilationUnit cu) {
            value log = Log.instance(context);
            
            variable JavaFileObject? oldSource = null;
            variable JavaFileObject? newSource = null;
            newSource = cu.sourceFile;
            if (newSource exists) {
                // save the old version and reinstate it later
                oldSource = log.useSource(newSource);
            }
            try {
                value prev = log.multipleErrors;
                log.multipleErrors = true;
                try {
                    log.error(node.pos(), "proc.messager", message);
                } finally {
                    log.multipleErrors = prev;
                }
            } finally {
                // reinstate the saved version, only if it was saved earlier
                if (newSource exists) {
                    log.useSource(oldSource);
                }
            }
        } else if (is JCTree.JCCompilationUnit jcu = cu,
            jcu.defs.nonEmpty(),
            exists path = trees.getPath(cu, jcu.defs.get(0)),
            exists element = trees.getElement(path)) {
            messager.printMessage(Diagnostic.Kind.error, message, element, annotationMirror);
        } else {
            messager.printMessage(Diagnostic.Kind.error, message);
        }
    }
    
    shared actual void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);
        trees = Trees.instance(processingEnv);
        filer = processingEnv.filer;
        assert (is JavacProcessingEnvironment jpe = this.processingEnv,
            exists context = jpe.context,
            is CeyloncFileManager fm = context.get(`JavaFileManager`));
        fileManager = fm;
        assert (exists classOutput = { *fileManager.getLocation(StandardLocation.classOutput) }.first);
        
        value generatedFilesFolder = File(classOutput.parentFile,
            processingEnv.options.get(javaString(generatedFolderNameOption))?.string else "generated");
        
        generatedGwtResourcesFolder = File(generatedFilesFolder, "gwt-resources");
        generatedGwtResourcesFolder.mkdirs();
        fileManager.setLocation(CeylonLocation.resourcePath, JavaIterable { generatedGwtResourcesFolder, *fileManager.getLocation(CeylonLocation.resourcePath) });
    }
    
    function getPackageFolder(File rootFolder, {String+} parts) {
        variable File moduleFolder = rootFolder;
        parts.each((part) =>
                moduleFolder = File(moduleFolder, part));
        return moduleFolder;
    }
    
    function getPackageFolderFromPackageName(File rootFolder, String packageQualifiedName) =>
        getPackageFolder(rootFolder, packageQualifiedName.split('.'.equals));
    
    shared actual Boolean process(Set<out TypeElement> annotations, RoundEnvironment roundEnv) {
        if (annotations.empty) {
            return false;
        }
        
        if (roundEnv.rootElements.empty) {
            return false;
        }
        
        assert (is JavacProcessingEnvironment jpe = this.processingEnv,
            exists context = jpe.context,
            is LanguageCompiler languageCompiler = LanguageCompiler.instance(context),
            exists ceylonContext = context.get(LanguageCompiler.ceylonContextKey));
        
        this.context = context;
        
        value gwtModel = HashMap<String,GwtModule>();
        
        assert (exists phasedUnits = LanguageCompiler.getPhasedUnitsInstance(context));
        for (m in phasedUnits.moduleSourceMapper.compiledModules) {
            value packageQualifiedName = m.nameAsString;
            value moduleFolder = getPackageFolderFromPackageName(generatedGwtResourcesFolder, packageQualifiedName);
            if (!moduleFolder.\iexists()) {
                continue;
            }
            value descriptors = moduleFolder.listFiles((file) =>
                    file.name.endsWith(".gwt.xml"));
            if (descriptors.size > 1) {
                reportError("Module '``packageQualifiedName``' contains 2 possible descriptors. You should run a clean build.");
                return true;
            }
            
            if (exists descriptor = descriptors.array.get(0),
                exists gwtModule = parseGwtModule(m, descriptor)) {
                if (!descriptor.delete()) {
                    reportError("GWT Module descriptor '``descriptor.absolutePath``' could not be deleted.");
                    return true;
                }
                gwtModel.put(packageQualifiedName, gwtModule);
            }
        }
        
        for (element in roundEnv.getElementsAnnotatedWith(moduleAnnotationClass)) {
            if (is PackageElement pkgElem = element.enclosingElement) {
                value moduleName = pkgElem.qualifiedName.string;
                value m = { *ceylonContext.modules.listOfModules }.find((m) => m.nameAsString == moduleName);
                if (!exists m) {
                    reportError("Module '``moduleName``' is not found in the Ceylon model", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
                    return true;
                }
                value moduleAnnotation = element.getAnnotation(moduleAnnotationClass);
                gwtModel.put(moduleName, GwtModule.fromModel(m, moduleAnnotation));
            }
        }
        
        for (element in roundEnv.getElementsAnnotatedWith(sourceAnnotationClass)) {
            if (is PackageElement pkgElem = element.enclosingElement) {
                value pkgName = pkgElem.qualifiedName.string;
                value p = { *ceylonContext.modules.listOfModules }.flatMap((m) => { *m.packages }).find((p) => p.nameAsString == pkgName);
                if (!exists p) {
                    reportError("The package '``pkgName``' is not found in any Ceylon module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
                    return true;
                }
                value parentModule = gwtModel[p.\imodule.nameAsString];
                if (!exists parentModule) {
                    reportError("The GWT source package '``pkgName``' is in a non-GWT module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
                    return true;
                }
                
                value sourceAnnotation = element.getAnnotation(sourceAnnotationClass);
                parentModule.addSource(GwtSource.fromModel(p, sourceAnnotation));
            }
        }
        
        for (element in roundEnv.getElementsAnnotatedWith(superSourceAnnotationClass)) {
            if (is PackageElement pkgElem = element.enclosingElement) {
                value pkgName = pkgElem.qualifiedName.string;
                value p = { *ceylonContext.modules.listOfModules }.flatMap((m) => { *m.packages }).find((p) => p.nameAsString == pkgName);
                if (!exists p) {
                    reportError("The package '``pkgName``' is not found in any Ceylon module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
                    return true;
                }
                value parentModule = gwtModel[p.\imodule.nameAsString];
                if (!exists parentModule) {
                    reportError("The GWT source package '``pkgName``' is in a non-GWT module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
                    return true;
                }
                
                parentModule.addSuperSource(GwtSuperSource.fromModel(p));
            }
        }
        
        for (element in roundEnv.getElementsAnnotatedWith(publicAnnotationClass)) {
            if (is PackageElement pkgElem = element.enclosingElement) {
                value pkgName = pkgElem.qualifiedName.string;
                value p = { *ceylonContext.modules.listOfModules }.flatMap((m) => { *m.packages }).find((p) => p.nameAsString == pkgName);
                if (!exists p) {
                    reportError("The package '``pkgName``' is not found in any Ceylon module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
                    return true;
                }
                value parentModule = gwtModel[p.\imodule.nameAsString];
                if (!exists parentModule) {
                    reportError("The GWT public package '``pkgName``' is in a non-GWT module", trees.getPath(element)?.compilationUnit, trees.getPath(element)?.leaf);
                    return true;
                }
                parentModule.addPublic(GwtPublic.fromModel(p));
            }
        }
        
        value modulesToCompileToJs = gwtModel.items
            .filter(GwtModule.compileToJs)
            .map(GwtModule.packageQualifiedName)
            .sequence();
        
        if (nonempty modulesToCompileToJs) {
            value options = JavacOptions.instance(context);
            value offline = /* JBoolean.parseBoolean(options.get(JavacOption.ceylonoffline) else "false") */ true;
            value outputRepo = options.get(JavacOption.d);
            suppressWarnings("unusedDeclaration")
            value cwd = if (exists cwdOpt = options.get(JavacOption.ceyloncwd))
            then File(cwdOpt)
            else File(outputRepo).parentFile;
            value systemRepo = options.get(JavacOption.ceylonsystemrepo);
            
            for (moduleToCompileToJs in modulesToCompileToJs) {
                value generatedScriptsSubPackageName = "``moduleToCompileToJs``.``generatedScriptsSubPackage``";
                value gwtModule = gwtModel[moduleToCompileToJs];
                if (!exists gwtModule) {
                    continue;
                }
                value m = { *ceylonContext.modules.listOfModules }
                    .find((m) => m.nameAsString == moduleToCompileToJs);
                if (!exists m) {
                    continue;
                }
                
                String moduleVersion = m.version;
                
                gwtModule.addPublic(GwtPublic(generatedScriptsSubPackageName));
                
                value generatedScriptsFolder = getPackageFolderFromPackageName(generatedGwtResourcesFolder, generatedScriptsSubPackageName);
                value modulesBaseFolder = File(generatedScriptsFolder, "modules");
                value copyOutput = modulesBaseFolder.absolutePath;
                
                value copyTool = CeylonCopyTool();
                copyTool.setJs(true);
                copyTool.setModules(Arrays.asList(
                        javaString(moduleToCompileToJs)
                    ));
                copyTool.setOut(copyOutput);
                copyTool.setIncludeLanguage(true);
                copyTool.setWithDependencies(true);
                copyTool.setOffline(offline);
                copyTool.setSystemRepository(systemRepo);
                copyTool.repositoryAsStrings = Arrays.asList(javaString(outputRepo), *{
                        for (rep in options.getMulti(JavacOption.ceylonrepo))
                            rep
                    });
                try {
                    copyTool.run();
                } catch (ToolException|ToolError e) {
                    reportError("An exception occured when copying the required Javascript modules: ``e``");
                }
                
                value modulesPath = parsePath(copyOutput);
                {String*} directoriesToSkip;
                value moduleResourcesFolder = getPackageFolder(modulesBaseFolder,
                    moduleToCompileToJs.split('.'.equals)
                        .chain { moduleVersion, ArtifactContext.resources }
                        .chain(moduleToCompileToJs.split('.'.equals)));
                directoriesToSkip = {
                    for (public in gwtModule.publics.keys)
                        getPackageFolderFromPackageName(moduleResourcesFolder,
                            public.removeInitial(moduleToCompileToJs + ".")).absolutePath
                };
                
                modulesPath.visit(object extends Visitor() {
                        shared actual Boolean beforeDirectory(Directory dir) {
                            if (dir.path.string in directoriesToSkip) {
                                return false;
                            }
                            return super.beforeDirectory(dir);
                        }
                        
                        shared actual void file(CeylonFile file) {
                            languageCompiler.addResourceFileObject(RegularFileObject(fileManager, File(file.path.absolutePath.string)));
                        }
                    });
                
                value bootstrapJsFile = filer.createResource(
                    CeylonLocation.resourcePath,
                    javaString(generatedScriptsSubPackageName),
                    javaString(bootstrapCeylonJsScript), null);
                
                try (writer = bootstrapJsFile.openWriter()) {
                    writer.write(
                        "var $ceylonModulesForGwt$``moduleToCompileToJs``;
                         require.config({
                            baseUrl : 'modules'
                         });
                         require(
                            [ '`` "/".join(
                                        moduleToCompileToJs.split('.'.equals)
                                        .chain { 
                                            moduleVersion,
                                            "``moduleToCompileToJs``-``moduleVersion``" })``' ],
                            function(theModule) {
                                $ceylonModulesForGwt$``moduleToCompileToJs`` = theModule;
                            }
                         );"
                    );
                }
                languageCompiler.addResourceFileObject(RegularFileObject(fileManager, File(bootstrapJsFile.toUri())));
            }
        }
        
        // call the copy tool to /modules also
        // à terme, on ne copie pas ceylon.language puisque il sera inclus dans runtime.
        
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
        
        value map = HashMap<JCTree.JCClassDecl,JCTree.JCCompilationUnit>();
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
                if (exists name = classToWrite.name?.string,
                    name == "$module_") {
                    // don't write it as Java source
                } else {
                    map.put(classToWrite, cu);
                }
            }
        }
        
        for (cu->classesToWrite in map.inverse()) {
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
            value source = filer.createResource(CeylonLocation.resourcePath, javaString(pkgName), javaString(relativeName), null);
            try (writer = source.openWriter()) {
                GwtJavaRenderer(writer, cu, classesToWrite, reportError).renderAsJavaSource();
            }
            
            languageCompiler.addResourceFileObject(RegularFileObject(fileManager, File(source.toUri())));
        }
        
        function declarationReferenceToClassName(String declRef) {
            value splitted = declRef.split(':'.equals).sequence().reversed;
            assert (exists decl = splitted[0],
                !decl.empty,
                decl.occursAt(0, 'C'), // should be a class
                exists pkg = splitted[1],
                !pkg.empty,
                exists mod = splitted[2],
                !mod.empty);
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
                javaString(gwtModule.name + ".gwt.xml"), null);
            
            value lines = concatenate({
                    "<module>"
                }, {
                    "  <inherits name='ceylon.interop.gwt.runtime.Runtime'/>"
                }, {
                    for (inherits in gwtModule.inherits)
                        "  <inherits name='``inherits``'/>"
                }, {
                    for (entry in gwtModule.externalEntryPoints)
                        "  <entry-point class='``entry``' />"
                }, {
                    for (source in gwtModule.sources.items)
                        for (declRef in source.entryPoints)
                            "  <entry-point class='``declarationReferenceToClassName(declRef)``' />"
                }, {
                    for (sourceQualifiedName in gwtModule.sources*.key)
                        "  <source path='``sourceQualifiedName.removeInitial(gwtModule.packageQualifiedName + ".")``' />"
                }, {
                    for (sourceQualifiedName in gwtModule.superSources*.key)
                        "  <super-source path='``sourceQualifiedName.removeInitial(gwtModule.packageQualifiedName + ".")``' />"
                }, {
                    for (publicQualifiedName in gwtModule.publics*.key)
                        "  <public path='``publicQualifiedName.removeInitial(gwtModule.packageQualifiedName + ".")``' />"
                }, {
                    for (sheet in gwtModule.stylesheets)
                        "  <stylesheet src='``sheet``' />"
                }, {
                    for (script in gwtModule.scripts)
                        "  <script src='``script``' />"
                }, {
                    "</module>"
                });

                                            
            try (writer = moduleXMLFile.openWriter()) {
                for (line in lines) {
                    writer.write("``line``\n");
                }
            }
            languageCompiler.addResourceFileObject(RegularFileObject(fileManager, File(moduleXMLFile.toUri())));
        }
        return true;
    }
}
