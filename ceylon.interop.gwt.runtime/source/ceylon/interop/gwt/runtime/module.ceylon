import ceylon.interop.gwt.annotations {
	gwtModule
}

suppressWarnings("ceylonNamespace")
gwtModule
module ceylon.interop.gwt.runtime "1.0.0" {
	native("jvm") import java.base "7";
	shared import ceylon.interop.gwt.annotations "1.0.0";
}
