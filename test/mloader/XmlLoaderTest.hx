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
import mloader.XmlLoader;
import mloader.Loader;
import mloader.HttpMock;

class XmlLoaderTest
{
	var http:HttpMock;
	var loader:XmlLoader;
	var events:Array<Dynamic>;

	@Before public function setup():Void
	{
		http = new HttpMock("");
		events = [];
		loader = new XmlLoader(null, http);
		loader.loaded.add(function (e) { events.unshift(e); });
	}
	
	@After public function tearDown():Void
	{
		loader.loaded.removeAll();
		loader = null;
		events = null;
	}

	@Test
	public function should_fail_with_format_error_on_load_invalid_document():Void
	{
		var data = "<invalid";
		var error = try { Xml.parse(data); ""; } catch (e:Dynamic) { Std.string(e); }
		var url = "http://localhost/invalid.xml";

		http.respondTo(url).with(Data(data));
		loader.url = url;
		loader.load();

		var expected = Fail(Format(error));
		LoaderAssert.assertEnumTypeEq(expected, events[0].type);

	}



	@Test
	public function should_complete_with_parsed_document_on_load_valid_document():Void
	{
		var data = "<valid />";
		var xml = Xml.parse(data);
		var url = "http://localhost/valid.xml";

		http.respondTo(url).with(Data(data));
		loader.url = url;
		loader.load();
		
		Assert.isTrue(Type.enumEq(events[0].type, Complete));
		Assert.isTrue(Std.is(loader.content, Xml));
		Assert.areEqual(xml.toString(), loader.content.toString());
	}

	@Test
	public function calls_external_parseData()
	{
		var data = "<valid><data/></valid>";
		var xml = Xml.parse(data);
		var url = "http://localhost/valid.xml";

		http.respondTo(url).with(Data(data));
		loader.url = url;
		loader.parseData = parseData;
		loader.load();


		Assert.isTrue(Type.enumEq(events[0].type, Complete));
		Assert.isTrue(Std.is(loader.content, Xml));
		Assert.areEqual(xml.firstChild().toString(), loader.content.toString());
	}

	function parseData(data:Xml):Xml
	{
		return data.firstChild();
	}

	@Test
	public function should_fail_with_default_data_error_if_parseData_throws_exception()
	{
		var data = "<valid><data/></valid>";
		var xml = Xml.parse(data);
		var url = "http://localhost/valid.xml";
		
		http.respondTo(url).with(Data(data));
		loader.url = url;
		loader.parseData = parseDataFail;
		loader.load();


		Assert.isNull(loader.content);

		var expected = Fail(Data("Some parsing error", data));
		LoaderAssert.assertEnumTypeEq(expected, events[0].type);
	}

	function parseDataFail(data:Xml):Xml
	{
		throw "Some parsing error";
		return null;
	}

	@Test
	public function should_fail_with_loader_error_type_if_parseData_throws_loader_error()
	{
		var data = "<valid><data/></valid>";
		var xml = Xml.parse(data);
		var url = "http://localhost/valid.xml";
		
		http.respondTo(url).with(Data(data));
		loader.url = url;
		loader.parseData = parseDataWithLoaderError;
		loader.load();

		Assert.isNull(loader.content);

		var expected = Fail(Data("Error 1", "Something"));
		LoaderAssert.assertEnumTypeEq(expected, events[0].type);
	}

	function parseDataWithLoaderError(data:Xml):Xml
	{
		throw Data("Error 1", "Something");
		return null;
	}
}
