import ceylon.interop.java {
	CeylonIterable
}

import com.redhat.ceylon.langtools.source.tree {
	Tree,
	CompilationUnitTree
}
import com.redhat.ceylon.langtools.tools.javac.tree {
	TreeInfo,
	Pretty,
	JCTree {
		...
	}
}

import java.io {
	Writer
}

class GwtJavaRenderer(
        Writer writer,
        JCCompilationUnit unit,
        [JCClassDecl+] classesToWrite,
        void reportError(String message, CompilationUnitTree? cu, Tree? node)) extends Pretty(writer, true) {
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
            name.startsWith(".ceylon.language.") ||
            name.startsWith(".com.redhat.ceylon.")) {
            return;
        }
        super.visitAnnotation(annot);
    }
    shared actual void visitMethodDef(JCMethodDecl meth) {
        if (exists name = meth.name?.string,
        	name == "$getType$") {
            print(
                "
                 public com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor $getType$() {
                     return null;
                 }
                 ");
            return;
        }
        super.visitMethodDef(meth);
    }
    
    shared actual void visitVarDef(JCVariableDecl var) {
        super.visitVarDef(var);
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
        switch(returnedExpr = letExpr.expr)
        case(is JCIdent) {
            value returnedVariableName = returnedExpr.name.string;
            for(s in letExpr.stats) {
                if (is JCVariableDecl s,
                    exists theName = s.name?.string,
                    theName == returnedVariableName) {
                    return s.type;
                }
            } else {
                reportError("Underlying `let` expression cannot be translated to valid Java source: returned variable (`` returnedVariableName ``) not found in the `let` statements", unit, returnedExpr);
                return null;
            }
        }
        case(is LetExpr) {
            return getLetExprType(returnedExpr);
        }
        case(is JCNewClass) { 
            if(is JCIdent clazz = returnedExpr.clazz,
                exists returnedClassName = clazz.name?.string) {
                for(s in letExpr.stats) {
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