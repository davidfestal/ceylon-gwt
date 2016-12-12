package ceylon.language;

import com.redhat.ceylon.compiler.java.runtime.model.ReifiedType;
import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

public final class Anything
    implements ReifiedType {
    
    private static final long serialVersionUID = 3920012367456670329L;

    public final static TypeDescriptor $TypeDescriptor$ = 
            TypeDescriptor.klass(Anything.class);
    
    @Override
    public TypeDescriptor $getType$() {
        return $TypeDescriptor$;
    }
}
