package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.XMLLoader;
import mloader.Loader;
import haxe.HttpMock;
/**
* Auto generated MassiveUnit Test Class  for mloader.XMLLoader 
*/
class XMLLoaderTest extends HTTPLoaderTestBase<Xml>
{
	var instance:XMLLoader; 
	
	public function new() 
	{
		super();
	}

	@AsyncTest
	public function fail_if_invalid_xml(async:AsyncFactory):Void
	{
		http.respondsTo("http://invalidXML", {delay:0, type:Data("<invalid ")});

		var handler = async.createHandler(this, assertFailedWithFormatError, 300);
		httpLoader.failed.add(handler);
		httpLoader.url = "http://invalidXML";
		httpLoader.load();
	}


	
	///////////
	/**
	Override this to create instance of concreate HTTPLoader sub type
	*/
	override function createHTTPLoader():HTTPLoader<Xml>
	{
		return new XMLLoader(http);
	}

	override function createValidURI():String
	{
		#if neko
			return "resource/test/m/loader/test.xml";
		#else
			return "m/loader/test.xml";
		#end
	}

	override function createValidStringData():String
	{
		return "<data></data>";
	}

	override function getDefaultContentType():String
	{
		return "application/xml";
	}
}
