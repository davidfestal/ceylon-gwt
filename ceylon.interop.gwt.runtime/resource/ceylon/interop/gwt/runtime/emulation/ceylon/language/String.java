package ceylon.language;

import com.redhat.ceylon.compiler.java.runtime.model.ReifiedType;
import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

public final class String
    implements ReifiedType, 
               java.lang.Comparable<String> {
    
    public final static TypeDescriptor $TypeDescriptor$ = 
            TypeDescriptor.klass(String.class);
    
    public final java.lang.String value;
    
    public String(final java.lang.String string) {
        value = string;
    }

    public java.lang.String toString() {
        return value;
    }

    public static java.lang.String toString(java.lang.String value) {
        return value;
    }

    public static ceylon.language.String instance(java.lang.String s) {
        if (s==null) return null;
        return new String(s);
    }

    public static ceylon.language.String instanceJoining(java.lang.String... strings) {
        StringBuffer buf = new StringBuffer();
        for (java.lang.String s: strings)
            buf.append(s);
        return instance(buf.toString());
    }

    @Override
    public boolean equals(java.lang.Object that) {
        if (that instanceof String) {
            String s = (String) that;
            return value.equals(s.value);
        }
        else {
            return false;
        }
    }

    public static boolean equals(java.lang.String value, 
            java.lang.Object that) {
        if (that instanceof String) {
            String s = (String) that;
            return value.equals(s.value);
        }
        else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return value.hashCode();
    }

    public static int hashCode(java.lang.String value) {
        return value.hashCode();
    }

    @Override
    public int compareTo(String other) {
        return value.compareTo(other.value);
    }

    public static long getSize(java.lang.String value) {
        return value.codePointCount(0, value.length());
    }

    @Override
    public TypeDescriptor $getType$() {
        return $TypeDescriptor$;
    }
}
