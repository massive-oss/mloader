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
import mloader.JsonLoader;
import mloader.Loader;
import mloader.HttpMock;

class JsonLoaderTest
{
	static var response = 
"{
	\"employees\":
	[
		{ \"firstName\":\"John\" , \"lastName\":\"Doe\" }, 
		{ \"firstName\":\"Anna\" , \"lastName\":\"Smith\" }
	]
}";
	var http:HttpMock;
	var loader:JsonLoader<Employees>;
	var events:Array<Dynamic>;
	
	@Before
	public function setup():Void
	{
		http = new HttpMock("");
		events = [];
		loader = new JsonLoader(null, http);
		loader.loaded.add(function (e) { events.unshift(e); });
	}
	
	@After
	public function tearDown():Void
	{
		loader.loaded.removeAll();
		loader = null;
		events = null;
	}

	@Test
	public function parses_json_response_into_object()
	{
		var url = "http://localhost/data.txt";
		
		http.respondTo(url).with(Data(response));
		loader.url = url;
		loader.load();

		Assert.isNotNull(loader.content.employees);
		Assert.areEqual(2, loader.content.employees.length);
		Assert.areEqual("John", loader.content.employees[0].firstName);
		Assert.areEqual("Smith", loader.content.employees[1].lastName);
	}

	@Test
	public function fails_if_invalid_json_string()
	{
		var url = "http://localhost/data.txt";
		
		http.respondTo(url).with(Data("asfdasfsa{]asfsdc/sdfdsgds"));
		loader.url = url;
		loader.load();

		Assert.isNull(loader.content);

		var expected = Fail(Format(null));
		LoaderAssert.assertEnumTypeEq(expected, events[0].type);
	}

	@Test
	public function calls_external_parseData()
	{
		var url = "http://localhost/data.txt";
		
		http.respondTo(url).with(Data(response));
		loader.url = url;
		loader.parseData = parseData;
		loader.load();

		Assert.isNotNull(loader.content.employees);
		Assert.areEqual(1, loader.content.employees.length);
		Assert.areEqual("John", loader.content.employees[0].firstName);
	}

	function parseData(data:Dynamic):Employees
	{
		data.employees.pop();
		return data;
	}

	@Test
	public function should_fail_with_default_data_error_if_parseData_throws_exception()
	{
		var url = "http://localhost/data.txt";
		
		http.respondTo(url).with(Data(response));
		loader.url = url;
		loader.parseData = parseDataFail;
		loader.load();

		Assert.isNull(loader.content);

		var expected = Fail(Data("Some parsing error", response));
		LoaderAssert.assertEnumTypeEq(expected, events[0].type);
	}

	function parseDataFail(data:Dynamic):Employees
	{
		throw "Some parsing error";
		return null;
	}

	@Test
	public function should_fail_with_loader_error_type_if_parseData_throws_loader_error()
	{
		var url = "http://localhost/data.txt";
		
		http.respondTo(url).with(Data(response));
		loader.url = url;
		loader.parseData = parseDataWithLoaderError;
		loader.load();

		Assert.isNull(loader.content);

		var expected = Fail(Data("Error 1", "Something"));
		LoaderAssert.assertEnumTypeEq(expected, events[0].type);
	}

	function parseDataWithLoaderError(data:Dynamic):Employees
	{
		throw Data("Error 1", "Something");
		return null;
	}
}


private typedef Employee = 
{
	firstName:String,
	lastName:String
}

private typedef Employees =
{
	employees:Array<Employee>
}
