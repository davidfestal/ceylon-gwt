import com.redhat.ceylon.langtools.source.tree {
	Tree
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
        [JCClassDecl+] classesToWrite,
        String[] gwtSuperSourcePackages) extends Pretty(writer, true) {
    shared void renderAsJavaSource(JCCompilationUnit unit) => printUnit(unit, null);
    
    shared actual void printUnit(JCCompilationUnit tree, JCClassDecl? cdef) {
        super.printUnit(tree, cdef);
    }
    
    shared actual void visitClassDef(JCClassDecl clazz) {
        if (clazz in classesToWrite || !isTopLevel(clazz)) {
            super.visitClassDef(clazz);
        }
    }
    shared actual void visitAnnotation(JCAnnotation annot) {
        if (exists sym = annot.annotationType?.type?.tsym,
            exists qn = sym.qualifiedName.string) {
            if (qn.startsWith("com.redhat.ceylon.") || qn.startsWith("ceylon.language.")) {
                return;
            }
        }
        super.visitAnnotation(annot);
    }
    shared actual void visitMethodDef(JCMethodDecl meth) {
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

    shared actual void visitLetExpr(LetExpr letExpr) {
        String | JCTree type ;
        switch(returnedExpr = letExpr.expr)
        case(is JCIdent) {
            value returnedVariableName = returnedExpr.name.string;
            for(s in letExpr.stats) {
                if (is JCVariableDecl s,
	                exists theName = s.name?.string,
            		theName == returnedVariableName) {
                    type = s.type;
                    break;
                }
            } else {
                type = "java.lang.Object";
            }
        }
        case(is JCLiteral) {
            switch (kindLitteral = returnedExpr.typetag.kindLiteral)
            case(Tree.Kind.intLiteral) {
                type="int";
            }
            case(Tree.Kind.longLiteral) {
                type="long";
            }
            case(Tree.Kind.doubleLiteral) {
                type="double";
            }
            case(Tree.Kind.booleanLiteral) {
                type="boolean";
            }
            case(Tree.Kind.charLiteral) {
                type="char";
            }
            case(Tree.Kind.stringLiteral) {
                type="java.lang.String";
            }
            case(Tree.Kind.nullLiteral) {
                type="java.lang.Object";
            }
            else {
                type="java.lang.Object";
            }
        } else {
            type = "java.lang.Object";
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