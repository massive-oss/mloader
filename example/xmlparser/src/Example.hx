package ;

import mcore.format.xml.Decoder;

class Example
{
	public static function main()
	{
		new Example();
	}

	public function new()
	{
		parseSimpleXml();
		parseBasicTypes();
		objectsWithAttributes();
		mapCustomNodeName();
		mapCustomClass();
	}

	function parseSimpleXml()
	{
		var decoder = new Decoder();
		var xml = Xml.parse("<String>hello world</String>");
		var str:String = decoder.parse(xml);
		trace(str);
	}

	function parseBasicTypes()
	{
		var decoder = new Decoder();

		var bool:Bool = parse(decoder, "<Bool>true</Bool>");
		trace(bool);

		var int:Int = parse(decoder, "<Int>1</Int>");
		trace(int);

		var float:Float = parse(decoder, "<Float>1.5</Float>");
		trace(float);

		var array:Array<Int> = parse(decoder, "<Array><Int>2</Int><Int>5</Int></Array>");
		trace(array);

		var hash:Hash<String> = parse(decoder, "<Hash><String id='foo'>bar</String><Object><id>bing</id><test>baz</test></Object></Hash>");
		trace(hash);

		var intHash:IntHash<String> = parse(decoder, "<IntHash><String id='0'>bar</String><Object><id>1</id><test>baz</test></Object></IntHash>");
		trace(intHash);
	}

	function objectsWithAttributes()
	{
		var decoder = new Decoder();
		var xml = "<Object integer='12' hex='0xFF' float='1.3' boolTrue='true' boolFalse='false' array='[1,2]' object='{a:2}'/>";
		var result = parse(decoder,xml);
		trace(result);
	}

	function mapCustomNodeName()
	{
		var decoder = new Decoder();
		decoder.nodeMap.set("widget", "Int");

		var xml = "<Object><widget>5</widget></Object>";
		var result = parse(decoder,xml);
		var widget:Int = result.widget;

		trace(widget);
	}

	function mapCustomClass()
	{
		var decoder = new Decoder();
		decoder.classMap.set("item", Item);
		decoder.nodeMap.set("name", "String");

		var xml = "<item id='1'><name>Foo</name></item>";
		var result = parse(decoder, xml);
		trace(result);
	}
	
	function parse(decoder:Decoder, value:String):Dynamic
	{
		var xml = Xml.parse(value);
		return decoder.parse(xml);
	}
}

class Item
{
	public var id:Int;
	public var name:String;

	public function new(){}

	public function toString()
	{
		return "Item " + id + " (" + name + ")";
	}
}
