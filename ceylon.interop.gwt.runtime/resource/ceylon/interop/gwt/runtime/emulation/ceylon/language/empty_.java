package ceylon.language;

import com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor;

public final class empty_ implements java.io.Serializable,
        com.redhat.ceylon.compiler.java.runtime.model.ReifiedType, Empty {

    private static Empty instance = new empty_();

  public static Empty get_() {
      return instance;
  }
  
  // Field descriptor #182 Lcom/redhat/ceylon/compiler/java/runtime/model/TypeDescriptor;
    @com.redhat.ceylon.compiler.java.metadata.Ignore
    public static final com.redhat.ceylon.compiler.java.runtime.model.TypeDescriptor $TypeDescriptor$ = null;

    @Override
    public TypeDescriptor $getType$() {
        return $TypeDescriptor$;
    }
}