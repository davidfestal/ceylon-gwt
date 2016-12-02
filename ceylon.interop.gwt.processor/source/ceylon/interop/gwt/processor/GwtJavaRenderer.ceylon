import com.redhat.ceylon.langtools.tools.javac.tree {
    TreeInfo,
    Pretty,
    JCTree
}
import java.io {
    Writer
}
import com.redhat.ceylon.langtools.tools.javac.util {
    JavacList=List
}
import ceylon.interop.java {
    JavaIterable
}

class GwtJavaRenderer(
        Writer writer,
        [JCTree.JCClassDecl+] classesToWrite,
        String[] gwtSuperSourcePackages) extends Pretty(writer, true) {
    shared void renderAsJavaSource(JCTree.JCCompilationUnit unit) => printUnit(unit, null);
    
    shared actual void printUnit(JCTree.JCCompilationUnit tree, JCTree.JCClassDecl? cdef) {
        value oldPid = tree.pid else null;
        value pid = oldPid?.string else "";
        value superSourcePackage = gwtSuperSourcePackages.find((p) => pid.startsWith(p + "."));
        if(exists superSourcePackage) {
            value newPackage = pid.removeInitial(superSourcePackage + ".");
            try {
                if (exists oldPid) {
                    print("package ");
                    print(newPackage);
                    print(";");
                    println();
                }
                tree.pid = null;
                super.printUnit(tree, cdef);
            } finally {
                tree.pid = oldPid;
            }
        } else {
            super.printUnit(tree, cdef);
        }
    }
    
    shared actual void visitClassDef(JCTree.JCClassDecl clazz) {
        if (clazz in classesToWrite || !isTopLevel(clazz)) {
            function keepImplementsClause(JCTree.JCExpression expr) =>
                    if (exists itfName = expr.type?.tsym?.qualifiedName?.string,
                itfName == "com.redhat.ceylon.compiler.java.runtime.model.ReifiedType")
            then false else true;
            value oldImplementsClause = clazz.implementsClause;
            try {
                clazz.implementing = JavacList.from<JCTree.JCExpression>(JavaIterable {
                    for (expr in clazz.implementsClause) 
                    if (keepImplementsClause(expr))
                    expr
                });
                
                super.visitClassDef(clazz);
            } finally {
                clazz.implementing = oldImplementsClause;
            }
        }
    }
    shared actual void visitAnnotation(JCTree.JCAnnotation annot) {
        if (exists sym = annot.annotationType?.type?.tsym,
            exists qn = sym.qualifiedName.string) {
            if (qn.startsWith("com.redhat.ceylon.") || qn.startsWith("ceylon.language.")) {
                return;
            }
        }
        super.visitAnnotation(annot);
    }
    shared actual void visitMethodDef(JCTree.JCMethodDecl meth) {
        if (exists name = meth.name?.string,
            name == "$getType$") {
            return;
        }
        super.visitMethodDef(meth);
    }
    
    shared actual void visitVarDef(JCTree.JCVariableDecl var) {
        if (exists name = var.name?.string) {
            if (name == "$TypeDescriptor$") {
                return;
            }
        }
        super.visitVarDef(var);
    }
    
    shared actual void visitSelect(JCTree.JCFieldAccess tree) {
        if (is JCTree.JCIdent selected = tree.selected,
            selected.name.empty) {
            print(tree.name);
        } else {
            printExpr(tree.selected, TreeInfo.postfixPrec);
            print(".`` tree.name ``");
        }
    }
    
}