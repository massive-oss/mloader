### mloader.XmlObjectParser

XmlObjectParser is a utility class for automating the deserialization of raw xml 
into data objects based on individual node names.

It can serialise inbuilt Haxe data types including:

* Null
* Bool
* Int and Float
* String
* Xml
* Array
* Hash and IntHash
* Object

Basic Example:
	
	parser = new XmlObjectParser();
	parser.parse("<Int>3</Int>");
	parser.parse("<String>hello world</String>");
	parser.parse("<Object integer='12' hex='0xFF' float='1.3' boolTrue='true' array='[1,2]' object='{a:2}'/>");
	parser.parse("<Hash><String id='foo'>bar</String><Object><id>bing</id><test>baz</test></Object></Hash>");

Individual elements can be mapped to existing data types through the nodeMap:

	decoder.nodeMap.set("foo", "Int");
	decoder.parse("<foo>5</foo>");

Individual elements can be mapped to custom class types through the classMap:

	decoder.classMap.set("foo", my.Foo);
	decoder.parse("<foo id="123"></foo>");
