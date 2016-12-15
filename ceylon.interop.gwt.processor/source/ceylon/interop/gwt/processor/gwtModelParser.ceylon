import ceylon.collection {
    ArrayList
}
import ceylon.language {
    buildMap=map
}

import java.io {
    File
}

import javax.xml.parsers {
    SAXParserFactory
}

import org.xml.sax {
    Attributes,
    SAXException
}
import org.xml.sax.helpers {
    DefaultHandler
}
import com.redhat.ceylon.model.typechecker.model {
    Module
}

/*
 <module>
  <inherits name="ceylon.interop.gwt.runtime.Runtime"/>
  <inherits name="com.google.gwt.user.User"/>
  <entry-point class="gwt_ceylon_project_sample.client.MyEntryPoint" />
  <source path="client" />
  <public path="resources" />
  <stylesheet src="gwt-ceylon-project.css" />
 </module>

 */

GwtModule? parseGwtModule(Module m, File file) {
    value parser = SAXParserFactory.newInstance().newSAXParser();
    object state {
        shared variable Boolean hasFoundModule = false;
    }

    value name = file.name.removeTerminal(".gwt.xml");
    
    object tags {
        shared object names {
            shared String stylesheet = "stylesheet";
            shared String inherits = "inherits";
            shared String entryPoint = "entry-point";
            shared String scripts = "scripts";
            shared String source = "source";
            shared String superSource = "super-source";
            shared String public = "public";
        }
        shared object values {
            shared ArrayList<String> stylesheet = ArrayList<String>();
            shared ArrayList<String> inherits = ArrayList<String>();
            shared ArrayList<String> entryPoint = ArrayList<String>();
            shared ArrayList<String> scripts = ArrayList<String>();
            shared ArrayList<String> source = ArrayList<String>();
            shared ArrayList<String> superSource = ArrayList<String>();
            shared ArrayList<String> public = ArrayList<String>();
        }
        shared Map<String, ArrayList<String>> map =  buildMap {
            names.stylesheet -> values.stylesheet,
            names.inherits -> values.inherits,
            names.entryPoint -> values.entryPoint,
            names.scripts -> values.scripts,
            names.source -> values.source,
            names.superSource -> values.superSource,
            names.public -> values.public
        };
    }

    value packageQualifiedName => m.nameAsString;
    
    try {
        parser.parse(file, object extends DefaultHandler() {
            shared actual void startElement(String uri, String localName, String qName, Attributes attributes) {
                print("startElement `` qName ``");
                if (qName == "module") {
                    if (state.hasFoundModule) {
                        throw SAXException("there should be only one 'module' tag");
                    }
                    state.hasFoundModule = true;
                    return;
                }
                 
                if (! state.hasFoundModule) {
                    throw SAXException("the root element must be a 'module' tag, but was: `` qName ``");
                }
                
                function returnAttribute(String name, Attributes attrs) {
                    if (attrs.length == 1) {
                        return attrs.getValue(0);
                    } else {
                        throw SAXException("the `` name `` element has wrong attributes");
                    }
                }
                
                value listToAddIn = tags.map[qName];
                if (!exists listToAddIn){
                    throw SAXException("unknown element: `` qName ``");
                }
                
                listToAddIn.add(returnAttribute(qName, attributes));
            }
        });
    } catch(SAXException se) {
        se.printStackTrace();
        return null; 
    }

    value sources = tags.values.source.map((source) {
        value sourcePackageQualifiedName = "`` packageQualifiedName ``.`` source ``";
        value entryPointsFromThisSource = 
                let(prefix = sourcePackageQualifiedName + ".")
                tags.values.entryPoint.filter((ep) => 
                    prefix in ep).sequence();
        tags.values.entryPoint.removeAll(entryPointsFromThisSource);
        return GwtSource(sourcePackageQualifiedName, entryPointsFromThisSource);
    });

    value superSources = tags.values.superSource.map((superSource) {
        value superSourcePackageQualifiedName = "`` packageQualifiedName ``.`` superSource ``";
        return GwtSuperSource(superSourcePackageQualifiedName);
    });
    
    value publics = tags.values.public.map((public) {
        value publicPackageQualifiedName = "`` packageQualifiedName ``.`` public ``";
        return GwtPublic(publicPackageQualifiedName);
    });
    
    value gwtModule = GwtModule(m, name, 
        tags.values.inherits.sequence(), 
        tags.values.scripts.sequence(), 
        tags.values.stylesheet.sequence(), 
        tags.values.entryPoint.sequence());
    
    for (source in sources) {
        gwtModule.addSource(source);
    }

    for (superSource in superSources) {
        gwtModule.addSuperSource(superSource);
    }

    for (public in publics) {
        gwtModule.addPublic(public);
    }
    
    return gwtModule;
}