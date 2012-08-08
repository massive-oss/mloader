/**
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

import massive.munit.Assert;

class XmlObjectParserTest
{
	var decoder:XmlObjectParser;

	public function new(){}

	@Before
	public function setup():Void 
	{
		decoder = new XmlObjectParser();
	}

	@Test
	public function shouldParseHashValuesIntoHashObject()
	{
		var HASH_ID_ONE = "one";
		var HASH_ID_TWO = "two";

		var xml = Xml.parse('<Hash><Bool id="' + HASH_ID_ONE + '">true</Bool><String id="' + HASH_ID_TWO + '">yo</String></Hash>');


		var hash = cast(decoder.parse(xml), Hash<Dynamic>);

		Assert.isNotNull(hash);
		Assert.isTrue(hash.get(HASH_ID_ONE));
		Assert.areEqual("yo", hash.get(HASH_ID_TWO));
	}

	@Test
	public function parses_null()
	{
		test("<Null/>", null);
	}

	@Test
	public function parses_bool()
	{
		test("<Bool>true</Bool>", true);
	}

	@Test
	public function parses_int()
	{
		test("<Int>2</Int>", 2);
	}

	@Test
	public function parses_float()
	{
		test("<Float>1.2</Float>", 1.2);
	}

	@Test
	public function parses_string()
	{
		test("<String>hello world</String>", "hello world");
	}
	
	@Test
	public function parses_xml()
	{
		var xml = parse("<Xml><a>2</a></Xml>");
		Assert.isType(xml, Xml);
	}

	@Test
	public function parses_array()
	{
		var array = parse("<Array><String>foo</String></Array>");
		Assert.isType(array, Array);
		Assert.areEqual("foo", array[0]);
	}

	@Test
	public function parses_object()
	{
		var object1 = parse("<Object><a><String>foo</String></a></Object>");
		Assert.areEqual("foo", object1.a);

		var object2 = parse("<Object><a>foo</a></Object>");
		Assert.areEqual("foo", object2.a);
	}
	
	@Test
	public function parses_hash()
	{
		var hash:Hash<Dynamic> = parse("<Hash><String id='foo'>bar</String><Object><id>bing</id><test>baz</test></Object></Hash>");
		Assert.areEqual("bar", hash.get("foo"));
		Assert.areEqual("baz", hash.get("bing").test);
	}

	@Test
	public function parses_int_hash()
	{
		var hash = parse("<IntHash><String id='2'>4</String><String id='a'>2</String></IntHash>");
		Assert.areEqual(4, hash.get(2));
		// default key is -1
		Assert.areEqual(2, hash.get(-1));
	}

	@Test
	public function parses_attributes()
	{
		var o = parse("<Object integer='12' hex='0xFF' float='1.3' boolTrue='true' boolFalse='false' array='[1,2]' object='{a:2}'/>");
		Assert.areEqual(12, o.integer);
		Assert.areEqual(255, o.hex);
		Assert.areEqual(1.3, o.float);
		Assert.areEqual(true, o.boolTrue);
		Assert.areEqual(false, o.boolFalse);
		Assert.areEqual(2, o.array[1]);
		Assert.areEqual(2, o.object.a);
	}

	@Test
	public function maps_class()
	{
		decoder.classMap.set("widget", MappedClass);
		var instance = parse("<widget/>");
		Assert.isType(instance, MappedClass);
	}

	@Test
	public function maps_node()
	{
		decoder.nodeMap.set("widget", "String");
		var instance = parse("<widget>foo</widget>");
		Assert.isType(instance, String);
		Assert.areEqual("foo", instance);
	}

	@Test
	public function maps_element_class()
	{
		decoder.classMap.set("widget", MappedClass);
		var instance = parse("<Object><widget/></Object>");
		Assert.isType(instance.widget, MappedClass);
	}

	@Test
	public function maps_element_node()
	{
		decoder.nodeMap.set("widget", "Int");
		var instance = parse("<Object><widget>5</widget></Object>");
		Assert.areEqual(5, instance.widget);
	}

	@Test
	public function incomplete_pattern_falls_back_to_string()
	{
		var instance = parse("<Object a='[1,2,3'/>");
		Assert.areEqual("[1,2,3", instance.a);
	}

	function test(string:String, result:Dynamic)
	{
		Assert.areEqual(result, parse(string));
	}

	function parse(string:String):Dynamic
	{
		var xml = Xml.parse(string);
		return decoder.parse(xml);
	}
}

class MappedClass
{
	public function new(){}
}
