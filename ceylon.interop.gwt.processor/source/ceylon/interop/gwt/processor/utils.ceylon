import java.lang {
    JavaClass=Class,
    ObjectArray
}
import com.redhat.ceylon.langtools.tools.javac.tree {
    JCTree
}
import com.redhat.ceylon.javax.lang.model.element {
    NestingKind
}

FieldType getAnnotation<FieldType>(
    Annotation annotation,
    JavaClass<out Annotation> annotationClass,
    String fieldName,
    FieldType(Object) convert,
    void reportError(String msg) => print(msg))
        given FieldType of String | String[] {
    value method = { for (m in annotationClass.methods) 
        if (m.name == fieldName) m
    }.first;
    if (! exists method) {
        reportError("Annotation `` annotationClass.simpleName `` has no `` fieldName `` value!");
        return convert("");
    }
    Object annotationValue = method.invoke(annotation);
    return convert(annotationValue);
}

String[] toStringList(Object val) {
    assert(is ObjectArray<Anything> val);
    return [ 
    for (element in val)
    if (exists element)
    element.string
    ];
}

Boolean isTopLevel(JCTree.JCClassDecl clazz) => 
        if (exists kind = clazz.sym?.nestingKind) 
then kind == NestingKind.topLevel
else false;

