package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import mloader.JsonLoader;
import mloader.Loader;
import haxe.HttpMock;

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
	var loader:JsonLoader<Dynamic>;
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
}
