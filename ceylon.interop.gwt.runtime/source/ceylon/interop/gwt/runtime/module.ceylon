import ceylon.interop.gwt.annotations {
	gwtModule
}

suppressWarnings("ceylonNamespace")
gwtModule
native("jvm")
module ceylon.interop.gwt.runtime "1.0.0" {
	import java.base "7";
	shared import ceylon.interop.gwt.annotations "1.0.0";
	import maven:"com.google.gwt:gwt-user" "2.8.0";
}
