import com.google.gwt.core.client {
    Callback,
    GWT,
    ScriptInjector
}
import java.lang {
    Void
}
import com.google.gwt.user.client.ui {
    HTML,
    RootLayoutPanel {
        root=get
    }
}

shared native("jvm") void injectRequireJsModules(void runWhenModulesLoaded()) {
    ScriptInjector.fromUrl(bootstrapCeylonJsScript).setCallback(object satisfies Callback<Void, Exception> {
        
        shared actual void onFailure(Exception? reason) {
            root().add(HTML(
                "<h1>Problem loading the Ceylon scripts</h1>
                 <br/>
                 <b>Reason:</b> `` reason?.message else "unknown" ``"));
            GWT.log("failed in onModuleLoad", reason);
        }
        
        // The code of the entry point is run when the Ceylon JS bootstrap script is loaded.
        // Not that it might that the ceylon requireJS module is not yet fully available.
        shared actual void onSuccess(Void reason) {
            runWhenModulesLoaded();
        }
    })
    // the bootstrap script is added in the top-level window, since requireJs is loaded
    // from the host HTML page.
    .setWindow(ScriptInjector.topWindow).inject();
}
