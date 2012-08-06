package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.XmlLoader;
import mloader.Loader;
import haxe.HttpMock;

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

		http.respondTo("invalid.xml").with(Data(data));
		loader.url = "invalid.xml";
		loader.load();

		Assert.isTrue(Type.enumEq(events[0].type, Failed(Format(error))));
	}

	@Test
	public function should_complete_with_parser_document_on_load_valid_document():Void
	{
		var data = "<valid />";
		var xml = Xml.parse(data);
		
		http.respondTo("valid.xml").with(Data(data));
		loader.url = "valid.xml";
		loader.load();
		
		Assert.isTrue(Type.enumEq(events[0].type, Completed));
		Assert.isTrue(Std.is(loader.content, Xml));
		Assert.areEqual(xml.toString(), loader.content.toString());
	}
}
