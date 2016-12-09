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
        value type = letExpr.expr?.type?.string else "java.lang.Object";
        print("
               new ceylon.interop.gwt.emulation.LetExpressionContainer<`` type ``>() {
                   @Override
                   public `` type `` call() {
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