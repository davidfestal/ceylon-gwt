package ceylon.language;

import com.redhat.ceylon.compiler.java.runtime.model.ReifiedType;
import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

public final class Anything
    implements ReifiedType {
    
    public final static TypeDescriptor $TypeDescriptor$ = 
            TypeDescriptor.klass(Anything.class);
    
    @Override
    public TypeDescriptor $getType$() {
        return $TypeDescriptor$;
    }
}
