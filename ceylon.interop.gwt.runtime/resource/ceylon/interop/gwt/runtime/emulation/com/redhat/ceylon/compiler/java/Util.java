package com.redhat.ceylon.compiler.java;

public class Util {
    public static <T> T checkNull(T t) {
        if(t == null)
            throw new AssertionError("null value returned from native call not assignable to Object");
        return t;
    }
}
