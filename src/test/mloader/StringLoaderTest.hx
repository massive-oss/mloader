package mloader;

import haxe.HttpMock;
import mloader.Loader;
import mloader.StringLoader;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class StringLoaderTest
{
	var http:HttpMock;
	var loader:StringLoader;
	var events:Array<Dynamic>;

	@Before public function setup():Void
	{
		http = new HttpMock("");
		events = [];
		loader = new StringLoader(null, http);
		loader.loaded.add(function (e) { events.unshift(e); });
	}
	
	@After public function tearDown():Void
	{
		loader.loaded.removeAll();
		loader = null;
		events = null;
	}

	@Test
	#if neko @Ignore("Async cancel not supported in neko")#end
	public function should_cancel_loading_loader():Void
	{
		loader.url = "m/loader/test.txt";
		loader.load();
		loader.cancel();
		Assert.isTrue(Type.enumEq(events[0].type, cancelled));
	}

	@Test
	public function should_throw_exception_on_load_if_url_is_null():Void
	{
		try
		{
			loader.load();
			Assert.fail("Expected exception");
		}
		catch (e:Dynamic)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function should_complete_with_content_on_load_valid_url():Void
	{
		http.respondTo("m/loader/test.txt").with(Data("content"));
		loader.url = "m/loader/test.txt";
		loader.load();

		Assert.areEqual("content", loader.content);
		Assert.isTrue(Type.enumEq(events[0].type, completed));
	}

	@Test
	public function should_fail_with_io_on_load_invalid_url():Void
	{
		loader.url = "invalid";
		loader.load();
		Assert.isTrue(Type.enumEq(events[0].type, failed(io("Http Error #404"))));
	}

	@Test
	public function should_fail_with_security_on_load_insecure_url():Void
	{
		http.respondTo("insecure").with(Exception("Security error"));
		loader.url = "insecure";
		loader.load();
		Assert.isTrue(Type.enumEq(events[0].type, failed(security("Security error"))));
	}

	@Test
	public function changing_url_during_loading_should_cancel_loading():Void
	{
		http.respondTo("m/loader/test.txt").with(Data("content")).afterDelay(10);
		loader.url = "m/loader/test.txt";
		loader.load();
		loader.url = "m/loader/test2.txt";
		Assert.isTrue(Type.enumEq(events[0].type, cancelled));
	}

	@Test
	public function setting_url_to_same_during_loading_should_not_cancel():Void
	{
		http.respondTo("m/loader/test.txt").with(Data("content")).afterDelay(10);
		loader.url = "m/loader/test.txt";
		loader.load();
		loader.url = "m/loader/test.txt";
		Assert.isFalse(events.length > 0 && Type.enumEq(events[0].type, cancelled));
	}
}
