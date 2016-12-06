import ceylon.html {
	CeylonDiv=Div,
	CeylonH1=H1
}
import ceylon.interop.gwt.annotations {
	delegate
}

import com.google.gwt.core.client {
	EntryPoint
}
import com.google.gwt.user.client.ui {
    DockLayoutPanel { ... },
    HasHorizontalAlignment {... },
    RootLayoutPanel {
        root = get
    },
	...
}
import com.google.gwt.dom.client {
    Style
}
import com.google.gwt.event.dom.client {
	KeyUpEvent,
	KeyUpHandler
}

/*

shared native String inJavascript(String myString);

shared native("jvm") String inJavascript(String myString) => delegate(`inJavascript`)(myString);

shared native("js") String inJavascript(String myString) => CeylonDiv { 
	CeylonH1 { "Hi, it's Ceylon printing '`` myString ``' inside GWT code" }
}.string;


shared native class JavascriptClass(String myString) {
    shared native Integer method();
}

shared native("js") class JavascriptClass(String myString) {
    shared native("js") Integer method() => 1;
}

shared native("jvm") class JavascriptClass(String myString) {
    shared native("jvm") Integer method() => delegate(`method`)();
}

*/
 
native("jvm") String inJavascript(String myString) => 
		"<div id='html'>
		 	Hi `` myString `` !<br/><br/>Here is some Ceylon code running in GWT !
		 </div>";

native("jvm") class MyEntryPoint() satisfies EntryPoint {
	shared actual void onModuleLoad() {
        value title = Label("GWT client-side application written in Ceylon");
        title.addStyleDependentName("title");
        value titleHeightEm = 6.0;

        value field = TextBox();
        field.visibleLength=30;
        field.maxLength=60;

        value label = Label("Please enter your name : ");

        value html = HTML(inJavascript(field.\ivalue));

        value flow = FlowPanel();
        flow.stylePrimaryName = "labelAndField";
        flow.add(label);
        flow.add(field);
        value flowHeightEm = 4.0;

        value mainPanel = LayoutPanel();
        mainPanel.add(title);
        mainPanel.add(flow);
        mainPanel.add(html);
        
        variable value place = 0.0;
        mainPanel.setWidgetTopHeight(title, place, Style.Unit.px, titleHeightEm, Style.Unit.em);
        mainPanel.setWidgetTopHeight(flow, (place += titleHeightEm), Style.Unit.em, flowHeightEm, Style.Unit.em);
        mainPanel.setWidgetTopHeight(html, (place += flowHeightEm), Style.Unit.em, 100.0, Style.Unit.pct);
		root().add(mainPanel);

		field.addKeyUpHandler((evt) {
			html.html = inJavascript(field.\ivalue);
		});

		field.addChangeHandler((evt) {
			html.html = inJavascript(field.\ivalue);
		});
	}
}
