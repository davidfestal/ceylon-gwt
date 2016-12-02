import com.redhat.ceylon.model.typechecker.model {
    Referenceable,
    TypecheckerPackage=Package,
    TypecheckerModule=Module
}
import ceylon.collection {
    linked,
    HashMap
}

abstract class GwtContainer(Referenceable ceylonContainer) {
    shared String packageQualifiedName => ceylonContainer.nameAsString;
    
    hash => packageQualifiedName.hash;
    
    equals(Object that) => 
            if (is GwtModule that) 
    then packageQualifiedName==that.packageQualifiedName else false;			
}


class GwtModule(TypecheckerModule m, Annotation moduleAnnotation, void reportError(String msg) => print(msg))
        extends GwtContainer(m) {
    
    value nameAnnotation = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "name", Object.string);
    shared String[] inherits = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "inherits", toStringList, reportError);
    shared String[] scripts = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "scripts", toStringList, reportError);
    shared String[] stylesheets = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "stylesheets", toStringList, reportError);
    shared String[] externalEntryPoints = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "externalEntryPoints", toStringList, reportError);
    
    shared String name = if (! nameAnnotation.empty)
    then nameAnnotation 
    else if (exists lastPackagePart = [*m.name].last?.string)
    then lastPackagePart.initial(1).uppercased + lastPackagePart.rest
    else "";
    
    value sources_ = HashMap<String, GwtSource>(linked);
    value superSources_ = HashMap<String, GwtSuperSource>(linked);
    value publics_ = HashMap<String, GwtPublic>(linked);
    
    shared void addSource(GwtSource source) {
        sources_.put(source.packageQualifiedName, source);
    }
    shared Map<String, GwtSource> sources => sources_;
    
    shared void addSuperSource(GwtSuperSource source) {
        superSources_.put(source.packageQualifiedName, source);
    }
    shared Map<String, GwtSuperSource> superSources => superSources_;
    
    shared void addPublic(GwtPublic public) {
        publics_.put(public.packageQualifiedName, public);
    }
    shared Map<String, GwtPublic> publics => publics_;
}

class GwtSource(TypecheckerPackage p, Annotation sourceAnnotation, void reportError(String msg) => print(msg))
        extends GwtContainer(p) {
    
    shared String[] entryPoints = getAnnotation(sourceAnnotation, GwtAnnotationProcessor.sourceAnnotationClass, "entryPoints", toStringList, reportError);
}

class GwtSuperSource(TypecheckerPackage p)
        extends GwtContainer(p) {
}

class GwtPublic(TypecheckerPackage p) 
        extends GwtContainer(p) {
    
}

