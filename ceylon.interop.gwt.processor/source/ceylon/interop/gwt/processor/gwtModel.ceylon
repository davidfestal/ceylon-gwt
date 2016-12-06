import com.redhat.ceylon.model.typechecker.model {
    Referenceable,
    TypecheckerPackage=Package,
    TypecheckerModule=Module
}
import ceylon.collection {
    linked,
    HashMap
}

abstract class GwtContainer {
	shared String packageQualifiedName;
		
	shared new fromModel(Referenceable ceylonContainer) {
		packageQualifiedName = ceylonContainer.nameAsString;
	}

	shared new (String packageQualifiedName) {
		this.packageQualifiedName = packageQualifiedName;
	}
    
    hash => packageQualifiedName.hash;
    
    equals(Object that) => 
            if (is GwtModule that) 
    then packageQualifiedName==that.packageQualifiedName else false;			
}


class GwtModule
        extends GwtContainer {
	shared String name;
	shared String[] inherits;
	shared String[] scripts;
	shared String[] stylesheets;
	shared String[] externalEntryPoints;
	
	shared new fromModel(TypecheckerModule m, Annotation moduleAnnotation, void reportError(String msg) => print(msg))
			extends GwtContainer.fromModel(m) {
		value nameAnnotation = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "name", Object.string);
		inherits = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "inherits", toStringList, reportError);
		scripts = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "scripts", toStringList, reportError);
		stylesheets = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "stylesheets", toStringList, reportError);
		externalEntryPoints = getAnnotation(moduleAnnotation, GwtAnnotationProcessor.moduleAnnotationClass, "externalEntryPoints", toStringList, reportError);
		name = if (! nameAnnotation.empty)
		then nameAnnotation 
		else if (exists lastPackagePart = [*m.name].last?.string)
		then lastPackagePart.initial(1).uppercased + lastPackagePart.rest
		else "";
	}
	
	shared new(String packageQualifiedName, String name, String[] inherits, String[] scripts, String[] stylesheets, String[] externalEntryPoints)
			extends GwtContainer(packageQualifiedName) {
		this.name = name;
		this.inherits = inherits;
		this.scripts = scripts;
		this.stylesheets = stylesheets;
		this.externalEntryPoints = externalEntryPoints;
	}

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

class GwtSource
        extends GwtContainer {
	shared String[] entryPoints;
	
	shared new fromModel(TypecheckerPackage p, Annotation sourceAnnotation, void reportError(String msg) => print(msg))
			extends GwtContainer.fromModel(p) {
		entryPoints = getAnnotation(sourceAnnotation, GwtAnnotationProcessor.sourceAnnotationClass, "entryPoints", toStringList, reportError);
	}
	
	shared new (String packageQualifiedName, String[] entryPoints)
			extends GwtContainer(packageQualifiedName) {
		this.entryPoints = entryPoints;
	}
}

class GwtSuperSource
        extends GwtContainer {
	shared new fromModel(TypecheckerPackage p)
			extends GwtContainer.fromModel(p) {
	}
	shared new (String packageQualifiedName)
			extends GwtContainer(packageQualifiedName) {
	}
}

class GwtPublic 
		extends GwtContainer {
	shared new fromModel(TypecheckerPackage p)
			extends GwtContainer.fromModel(p) {
	}
	shared new (String packageQualifiedName)
			extends GwtContainer(packageQualifiedName) {
	}
}

