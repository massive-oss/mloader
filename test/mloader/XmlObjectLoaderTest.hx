/*
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import mloader.Loader;
import mloader.XmlObjectLoader;
import mloader.XmlObjectParser;
import mloader.XmlLoader;

import mloader.HttpMock;

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
