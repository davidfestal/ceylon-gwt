package com.redhat.ceylon.compiler.java.runtime.model;

public abstract class TypeDescriptor 
        implements java.io.Serializable {

    private static final long serialVersionUID = -7025975752915564091L;

    public static TypeDescriptor klass(Class<?> klass, TypeDescriptor... typeArguments) {
        return null;
    }
}
