package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.JSONLoader;
import mloader.Loader;
import haxe.HttpMock;
/**
* Auto generated MassiveUnit Test Class  for mloader.JSONLoader 
*/
class JSONLoaderTest extends HTTPLoaderTestBase<Dynamic>
{
	var instance:JSONLoader; 
	
	public function new() 
	{
		super();
	}

	@Ignore("not applicable to JSON Loader")
	@Test
	override public function send_with_xml_contentType():Void
	{
		Assert.isTrue(true);
	}
	
	@Test
	public function convert_object_to_JSON_string_before_sending():Void
	{
		var object:Dynamic = 
		{
			foo:"bar"
		};

		http.respondsTo("http://serializeObject", {delay:1, type:Data(createValidStringData())});
		httpLoader.url = "http://serializeObject";
		httpLoader.send(object);

		var jsonData =  haxe.Json.stringify(object);

		Assert.areEqual(jsonData, http.getPostData());
	}

	#if flash @Ignore("Cannot cause parse error on native JSON.stringify in AS3") #end
	@AsyncTest
	public function fail_due_to_object_not_being_JSON_stringifiable(factory:AsyncFactory):Void
	{
		var data = Xml.parse("<data></data>");
		var type = "text/plain";

		var handler = factory.createHandler(this, assertFailedWithFormatError, 1000);

		httpLoader.url = createValidURI();
		httpLoader.headers.set("Content-Type", type);
		httpLoader.failed.add(handler);
		httpLoader.completed.add(handler);
		httpLoader.send(data);
	}

	///////////
	/**
	Override this to create instance of concreate HTTPLoader sub type
	*/
	override function createHTTPLoader():HTTPLoader<Dynamic>
	{
		return new JSONLoader(http);
	}

	override function createValidURI():String
	{
		#if neko
			return "resource/test/m/loader/test.json";
		#else
			return "m/loader/test.json";
		#end
	}

	override function createValidStringData():String
	{
		return "{
	\"employees\":
	[
		{ \"firstName\":\"John\" , \"lastName\":\"Doe\" }, 
		{ \"firstName\":\"Anna\" , \"lastName\":\"Smith\" }
	]
}";
	}

	override function getDefaultContentType():String
	{
		return "application/json";
	}
}
