import ceylon.interop.gwt.annotations {
    GwtDelegateAnnotation,
    GwtNativeAnnotation
}
import ceylon.interop.java {
    CeylonIterable,
    javaAnnotationClass
}

import com.redhat.ceylon.compiler.java.codegen {
    CeylonCompilationUnit
}
import com.redhat.ceylon.langtools.source.tree {
    Tree,
    CompilationUnitTree
}
import com.redhat.ceylon.langtools.tools.javac.code {
    Flags
}
import com.redhat.ceylon.langtools.tools.javac.tree {
    TreeInfo,
    Pretty,
    JCTree {
        ...
    }
}
import com.redhat.ceylon.langtools.tools.javac.util {
    JavacList=List
}

import java.io {
    Writer
}

class GwtJavaRenderer(
        Writer writer,
        JCCompilationUnit unit,
        [JCClassDecl+] classesToWrite,
        void reportError(String message, CompilationUnitTree? cu, Tree? node)) extends Pretty(writer, true) {
    variable value shouldRemoveFinal = false;
    variable value shouldAddNative = false;
    variable String? nativeJsCode = null;
    
    shared void renderAsJavaSource() => printUnit(unit, null);
    
    shared actual void printUnit(JCCompilationUnit tree, JCClassDecl? cdef) {
        super.printUnit(tree, cdef);
    }
    
    shared actual void visitClassDef(JCClassDecl clazz) {
        if (clazz in classesToWrite || !isTopLevel(clazz)) {
            super.visitClassDef(clazz);
        }
    }
    shared actual void visitAnnotation(JCAnnotation annot) {
        if (exists name = annot.annotationType?.string,
            name.startsWith(".ceylon.interop.gwt.annotations.") ||
            name.startsWith(".ceylon.language.") ||
            name.startsWith(".com.redhat.ceylon.")) {
            return;
        }
        super.visitAnnotation(annot);
    }
    shared actual void visitMethodDef(JCMethodDecl meth) {
        value name = meth.name?.string;
        if (exists name,
        	name == "$getType$") {
            print(
                "
                 public com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor $getType$() {
                     return null;
                 }
                 ");
            return;
        }
        value gwtDelegateClassName = "." + javaAnnotationClass<GwtDelegateAnnotation>().name;
        value gwtNativeClassName = "." + javaAnnotationClass<GwtNativeAnnotation>().name;
        
        if (is CeylonCompilationUnit unit,
            exists name,
            exists pkg = unit
                    .phasedUnit?.unit?.\ipackage,
            exists mod = pkg.\imodule) {
            for (annot in meth.modifiers.annotations) {
                if (exists annotStr = annot.annotationType?.string,
                    annotStr == gwtDelegateClassName) {
                    try {
                        value pkgQualifiedName = pkg.nameAsString;
                        value modQualifiedName = mod.nameAsString;
                        value relativeName = pkgQualifiedName.removeInitial(modQualifiedName + ".");
                        value javascriptModule = "window.top.$ceylonModulesForGwt$``modQualifiedName``";
                        value javascriptName = "``javascriptModule``.``name``$`` "$".join(relativeName.split('.'.equals)) ``";
                        shouldAddNative = true;
                        nativeJsCode = "if(typeof ``javascriptModule`` !== \"undefined\"){
                                            return ``javascriptName``(`` ",".join { 
                                                for (param in meth.parameters)
                                                param.name.string
                                            }``);
                                        }
                                        else{
                                            throw \"Error: ceylon module '`` modQualifiedName ``' not loaded\";
                                        }";
                        super.visitMethodDef(meth);
                    } finally {
                        shouldAddNative = false;
                        nativeJsCode = null;
                    }
                    return;
                }
                if (exists annotStr = annot.annotationType?.string,
                    annotStr == gwtNativeClassName,
                    exists args = annot.args,
                    args.length() == 1,
                    is JCAssign arg = args.get(0),
                    is JCLiteral rhs = arg.rhs,
                    exists val = rhs.\ivalue?.string)  {
                    try {
                        value content = val;
                        shouldAddNative = true;
                        nativeJsCode = content;
                        super.visitMethodDef(meth);
                    } finally {
                        shouldAddNative = false;
                        nativeJsCode = null;
                    }
                    return;
                }
                
            }
        }
        super.visitMethodDef(meth);
    }

    shared actual void printBlock(JavacList<out JCTree>? trees) {
        if (exists codeToReplace = nativeJsCode) {
            print("/*-{
                   `` codeToReplace ``
                   }-*/;");
        } else {
            super.printBlock(trees);
        }
    }
    
    shared actual void printFlags(Integer flags) {
        if (shouldRemoveFinal) {
            super.printFlags(flags.and(Flags.final.not));
        } else if (shouldAddNative) {
            super.printFlags(flags.or(Flags.native));
            shouldAddNative = false;
        } else {
            super.printFlags(flags);
        }
    }
    
    shared actual void visitVarDef(JCVariableDecl var) {
        value varName = var.name.string;
        if (varName == "$object$" || varName == "$initException$") {
            shouldRemoveFinal = true;
            try {
                super.visitVarDef(var);
            } finally {
                shouldRemoveFinal = false;
            }
        } else {
            super.visitVarDef(var);
        }
    }
    
    shared actual void visitSelect(JCFieldAccess tree) {
        if (is JCIdent selected = tree.selected,
            selected.name.empty) {
            print(tree.name);
        } else {
            printExpr(tree.selected, TreeInfo.postfixPrec);
            print(".`` tree.name ``");
        }
    }

    String | JCTree | Null getLetExprType(LetExpr letExpr) {
        String | JCTree | Null getType(JCTree expr, JavacList<JCTree.JCStatement> stats) {
            switch(returnedExpr = expr)
            case(is JCFieldAccess) {
                variable value stringValue = returnedExpr.string;
                if (stringValue.startsWith(".ceylon.language.")) {
                    if (stringValue.endsWith(".instance")) {
                        stringValue = stringValue.replaceLast(".instance", "");
                    }
                    value type = stringValue
                            .replaceFirst(".ceylon.language.", "");
                    if (type == "String" ||
                        type == "Boolean"||
                            type == "Integer"||
                            type == "Byte"||
                            type == "Float") {
                        return "ceylon.language.``type``";
                    }
                }
                return returnedExpr;
            }
            case(is JCIdent) {
                value returnedVariableName = returnedExpr.name.string;
                for(s in stats) {
                    if (is JCVariableDecl s,
                        exists theName = s.name?.string,
                        theName == returnedVariableName) {
                        if (is JCFieldAccess fieldAccess = s.type) {
                            return getType(fieldAccess, stats);
                        } else {
                            return s.type;
                        }
                    }
                } else {
                    reportError("Underlying `let` expression cannot be translated to valid Java source: returned variable (`` returnedVariableName ``) not found in the `let` statements", unit, returnedExpr);
                    return null;
                }
            }
            case(is LetExpr) {
                return getLetExprType(returnedExpr);
            }
            case(is JCConditional) {
                value falseType = getType(returnedExpr.falseExpression, stats);
                value trueType = getType(returnedExpr.trueExpression, stats);
                if (exists trueType, exists falseType) {
                    if (trueType == "java.lang.Object") {
                        return falseType; 
                    }
                    if (falseType == "java.lang.Object") {
                        return trueType; 
                    }
                    if (falseType == trueType) {
                        return trueType; 
                    } else {
                        reportError("Underlying `let` expression cannot be translated to valid Java source: types of conditional are not compatible", unit, returnedExpr);
                        return null;
                    }
                } else {
                    return null;
                }
            }
            case(is JCMethodInvocation) {
                if (is JCFieldAccess meth = returnedExpr.meth) {
                    return getType(meth, stats);
                }
                reportError("Underlying `let` expression cannot be translated to valid Java source: return type of method invocation cannot be inferred", unit, returnedExpr);
                return null;
            }
            case(is JCNewClass) { 
                if(is JCIdent clazz = returnedExpr.clazz,
                    exists returnedClassName = clazz.name?.string) {
                    for(s in stats) {
                        if (is JCClassDecl classDef = s,
                            exists theName = classDef.name?.string,
                            theName == returnedClassName) {
                            if (exists extendsClause = classDef.extendsClause) {
                                return extendsClause;
                            } else {
                                value implemented = CeylonIterable(classDef.implementsClause).filter((implementing) {
                                    value str = implementing.string;
                                    return str != ".java.io.Serializable" &&
                                            str != ".com.redhat.ceylon.compiler.java.runtime.model.ReifiedType";
                                }).sequence();
                                if (nonempty implemented) {
                                    if (implemented.size != 1) {
                                        reportError("Underlying `let` expression cannot be translated to valid Java source: returned class (`` returnedClassName ``) implements several interfaces", unit, returnedExpr);
                                        return null;
                                    }
                                    return implemented.first;
                                } else {
                                    reportError("Underlying `let` expression cannot be translated to valid Java source: returned class (`` returnedClassName ``) doesn't extend or implement anything", unit, returnedExpr);
                                    return null;
                                }
                            }
                        }
                    } else {
                        reportError("Underlying `let` expression cannot be translated to valid Java source: returned class (`` returnedClassName ``) not found in the `let` statements", unit, returnedExpr);
                        return null;
                    }
                } else {
                    reportError("Underlying `let` expression cannot be translated to valid Java source", unit, returnedExpr);
                    return null;
                }
            }
            case(is JCLiteral) {
                switch (kindLitteral = returnedExpr.typetag.kindLiteral)
                case(Tree.Kind.intLiteral) {
                    return "int";
                }
                case(Tree.Kind.longLiteral) {
                    return "long";
                }
                case(Tree.Kind.doubleLiteral) {
                    return "double";
                }
                case(Tree.Kind.booleanLiteral) {
                    return "boolean";
                }
                case(Tree.Kind.charLiteral) {
                    return "char";
                }
                case(Tree.Kind.stringLiteral) {
                    return "java.lang.String";
                }
                case(Tree.Kind.nullLiteral) {
                    return "java.lang.Object";
                }
                else {
                    reportError("Underlying `let` expression cannot be translated to valid Java source", unit, returnedExpr);
                    return null;
                }
            }
            else {
                reportError("Underlying `let` expression cannot be translated to valid Java source", unit, returnedExpr);
                return null;
            }
        }
        return getType(letExpr.expr, letExpr.stats);
    }

    shared actual void visitLetExpr(LetExpr letExpr) {
        value type = getLetExprType(letExpr);
        if (! exists type) {
            super.visitLetExpr(letExpr);
            return;
        }
        
        print("
               new ceylon.interop.gwt.emulation.LetExpressionContainer<");
        switch(type)
        case(is String) {
            print(type);
        } else {
            printExpr(type);
        }
        print(">() {
                   @Override
                   public ");
        switch(type)
        case(is String) {
            print(type);
        } else {
            printExpr(type);
        }
        print(" call() {
               ");
        if (exists stats = letExpr.stats) {
            printStats(stats);
        }
        print("        return ");
        printExpr(letExpr.expr); print(";");
        print("
                   }
               }.call()");
    }
}