import ceylon.interop.gwt.annotations {
	gwtModule
}

gwtModule {
	name="GwtCeylonProject";
	stylesheets = [ "gwt-ceylon-project.css" ];
}
module gwt_ceylon_project_sample "1.0.0" {
	native("jvm") import java.base "7";
	native("jvm") import ceylon.interop.gwt.runtime "1.0.0";
	native("jvm") shared import maven:"com.google.gwt:gwt-user" "2.8.0";
	import ceylon.html "1.3.2-SNAPSHOT";
}
