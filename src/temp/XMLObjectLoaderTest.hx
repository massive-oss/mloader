package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.XMLObjectLoader;
import mloader.XMLLoader;
import mloader.Loader;
import haxe.HttpMock;
import m.format.xml.Decoder;
/**
* Auto generated MassiveUnit Test Class  for mloader.XMLLoader 
*/
class XMLObjectLoaderTest extends HTTPLoaderTestBase<MappedClass>
{
	var xmlObjectLoader:XMLObjectLoader<MappedClass>; 
	var decoder:Decoder;

	public function new() 
	{
		super();
	}

	@Before
	override public function setup():Void
	{
		decoder = new Decoder();
		decoder.classMap.set("mappedClass", MappedClass);

		super.setup();
		xmlObjectLoader = cast loader;
	}

	@Test
	public function should_create_default_decoder()
	{
		var temp = new XMLObjectLoader<MappedClass>();

		Assert.isNotNull(untyped temp.decoder);
	}

	@AsyncTest
	public function fail_if_invalid_xml(async:AsyncFactory):Void
	{
		http.respondsTo("http://invalidXML", {delay:0, type:Data("<invalid ")});

		var handler = async.createHandler(this, assertFailedWithFormatError, 300);
		xmlObjectLoader.failed.add(handler);
		xmlObjectLoader.url = "http://invalidXML";
		xmlObjectLoader.load();
	}

	@Test
	public function should_map_class_to_decoder()
	{
		xmlObjectLoader.mapClass("foo", String);

		Assert.areEqual(String, decoder.classMap.get("foo"));
	}

	@Test
	public function should_map_node_to_decoder()
	{
		xmlObjectLoader.mapNode("foo", "node");

		Assert.areEqual("node", decoder.nodeMap.get("foo"));
	}

	///////////
	/**
	Override this to create instance of concreate HTTPLoader sub type
	*/
	override function createHTTPLoader():HTTPLoader<MappedClass>
	{
		return new XMLObjectLoader<MappedClass>(decoder, http);
	}

	override function createValidURI():String
	{
		#if neko
			return "resource/test/m/loader/object.xml";
		#else
			return "m/loader/object.xml";
		#end
	}

	override function createValidStringData():String
	{
		return "<mappedClass value=\"foo\" ></mappedClass>";
	}

		override function getDefaultContentType():String
	{
		return "application/xml";
	}


}


class MappedClass
{
	public var value:String;

	public function new()
	{
		
	}
}
