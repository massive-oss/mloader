package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import mloader.Loader;
import mloader.XmlObjectLoader;
import mloader.XmlObjectParser;
import mloader.XmlLoader;

import haxe.HttpMock;

class XmlObjectLoaderTest
{
	var parser:XmlObjectParser;
	var loader:XmlObjectLoader<MappedClass>;

	@Before
	public function setup():Void
	{
		parser = new XmlObjectParser();
		parser.classMap.set("mappedClass", MappedClass);
		loader = new XmlObjectLoader<MappedClass>(null, parser);
	}

	@After
	public function tearDown():Void
	{
		parser = null;
		loader = null;
	}

	@Test
	public function should_create_default_parser()
	{
		var temp = new XmlObjectLoader<MappedClass>();
		Assert.isNotNull(untyped temp.parser);
	}

	@Test
	public function should_map_node_name_to_class()
	{
		loader.mapClass("foo", String);
		Assert.areEqual(String, parser.classMap.get("foo"));
	}

	@Test
	public function should_map_node_to_decoder()
	{
		loader.mapNode("foo", "node");
		Assert.areEqual("node", parser.nodeMap.get("foo"));
	}
}

private class MappedClass
{
	public var value:String;
	public function new() {}
}
