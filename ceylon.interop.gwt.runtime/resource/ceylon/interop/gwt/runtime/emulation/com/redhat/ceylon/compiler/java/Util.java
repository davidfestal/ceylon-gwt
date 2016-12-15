package com.redhat.ceylon.compiler.java;

public class Util {
    public static <T> T checkNull(T t) {
        if(t == null)
            throw new AssertionError("null value returned from native call not assignable to Object");
        return t;
    }
    
    /** 
     * Generates a default message for when a Throwable lacks a non-null 
     * message of its own. This can only happen for non-Ceylon throwable types, 
     * but due to type erasure it's not possible to know at a catch site which 
     * whether you have a Ceylon throwable
     */
    public static String throwableMessage(java.lang.Throwable t) {
        String message = t.getMessage();
        if (message == null) {
            java.lang.Throwable c = t.getCause();
            if (c != null) {
                message = c.getMessage();
            } else {
                message = "";
            }
        }
        return message;
    }
    
    public static void rethrow(final Throwable t) {
    }
}
