import ceylon.language.meta.declaration {
    Module,
    Package,
    ClassDeclaration,
    ClassOrInterfaceDeclaration,
    FunctionOrValueDeclaration
}

shared annotation GwtModuleAnnotation gwtModule(
	String name = "", 
	String[] inherits = [ "com.google.gwt.user.User" ], 
	String[] scripts = [], 
	String[] stylesheets = [],
	String[] externalEntryPoints = []) => GwtModuleAnnotation(name, inherits, scripts, stylesheets, externalEntryPoints);

shared annotation GwtSourceAnnotation gwtSource(ClassDeclaration[] entryPoints = []) => GwtSourceAnnotation(entryPoints);
shared annotation GwtSuperSourceAnnotation gwtSuperSource() => GwtSuperSourceAnnotation();
shared annotation GwtPublicAnnotation gwtPublic() => GwtPublicAnnotation();
shared annotation GwtDelegateAnnotation gwtDelegate() => GwtDelegateAnnotation();
shared annotation GwtNativeAnnotation gwtNative(String jsCode) => GwtNativeAnnotation(jsCode);

shared final annotation class GwtModuleAnnotation(shared String name, shared String[] inherits, shared String[] scripts, shared String[] stylesheets, shared String[] externalEntryPoints)
		satisfies OptionalAnnotation<GwtModuleAnnotation, Module> {}

shared final annotation class GwtSourceAnnotation(shared ClassDeclaration[] entryPoints)
		satisfies OptionalAnnotation<GwtSourceAnnotation, Package> {}

shared final annotation class GwtSuperSourceAnnotation()
		satisfies OptionalAnnotation<GwtSuperSourceAnnotation, Package> {}

shared final annotation class GwtPublicAnnotation()
		satisfies OptionalAnnotation<GwtPublicAnnotation, Package> {}

shared final annotation class GwtDelegateAnnotation()
        satisfies OptionalAnnotation<GwtDelegateAnnotation, FunctionOrValueDeclaration> {}

shared final annotation class GwtNativeAnnotation(shared String jsCode)
        satisfies OptionalAnnotation<GwtNativeAnnotation,
FunctionOrValueDeclaration | ClassOrInterfaceDeclaration> {}

suppressWarnings("expressionTypeNothing")
shared T gwtJsCode<T=Anything>() => (nothing of T);