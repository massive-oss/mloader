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

import mloader.HttpMock;
import mloader.Loader;
import mloader.StringLoader;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class StringLoaderTest
{
	static var VALID_URL = "src/resource/test/test.txt";
	
	var http:HttpMock;
	var loader:StringLoader;
	var events:Array<Dynamic>;

	@Before
	public function setup():Void
	{
		http = new HttpMock("");
		events = [];
		loader = new StringLoader(null, http);
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
	#if neko @Ignore("Async cancel not supported in neko")#end
	public function should_cancel_loading_loader():Void
	{
		http.respondTo(VALID_URL).with(Data("content")).afterDelay(1);
		loader.url = VALID_URL;
		loader.load();
		loader.cancel();
		Assert.isFalse(loader.loading);
		Assert.isTrue(Type.enumEq(events[0].type, Cancelled));
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
		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.load();

		Assert.areEqual("content", loader.content);
		Assert.isTrue(Type.enumEq(events[0].type, Completed));
	}

	@Test
	public function should_complete_with_content_on_send_valid_url()
	{
		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.send("some post data");

		Assert.areEqual("content", loader.content);
		Assert.isTrue(Type.enumEq(events[0].type, Completed));
	}

	@Test
	public function should_fail_with_io_on_load_invalid_url():Void
	{
		loader.url = "invalid";
		loader.load();
		Assert.isTrue(typeEq(events[0].type, Failed(IO(null))));
	}

	/**
	Compares enum equality, ignoring any non enum parameters, so that:
		Failed(IO("One thing happened")) == Failed(IO("Another thing happened"))
	*/
	function typeEq(a:EnumValue, b:EnumValue)
	{
		if (a == b) return true;
		if (Type.getEnum(a) != Type.getEnum(b)) return false;
		if (Type.enumIndex(a) != Type.enumIndex(b)) return false;

		var aParams = Type.enumParameters(a);
		if (aParams.length == 0) return true;
		var bParams = Type.enumParameters(b);

		for (i in 0...aParams.length)
		{
			var aParam = aParams[i];
			var bParam = bParams[i];

			if (aParam == null) continue;
			if (Type.getEnum(aParam) == null) continue;
			if (!typeEq(aParam, bParam)) return false;
		}

		return true;
	}

	@Test
	#if neko @Ignore("Neko has no security sandbox") #end
	public function should_fail_with_security_on_load_insecure_url():Void
	{
		http.respondTo("insecure").with(Exception("Security error"));
		loader.url = "insecure";
		loader.load();
		Assert.isTrue(typeEq(events[0].type, Failed(Security(null))));
	}

	@Test
	#if neko @Ignore("Neko has no security sandbox") #end
	public function should_fail_with_security_on_send_to_insecure_url():Void
	{
		http.respondTo("send/securityError").with(Exception("Security error"));
		loader.url = "send/securityError";
		loader.send("some post data");
		Assert.isTrue(typeEq(events[0].type, Failed(Security(null))));
	}

	@Test
	#if neko @Ignore("Async cancel not supported in neko")#end
	public function changing_url_during_loading_should_cancel_loading():Void
	{
		http.respondTo(VALID_URL).with(Data("content")).afterDelay(10);
		loader.url = VALID_URL;
		loader.load();
		loader.url = "test2.txt";
		Assert.isTrue(Type.enumEq(events[0].type, Cancelled));
	}

	@Test
	public function setting_url_to_same_during_loading_should_not_cancel():Void
	{
		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.load();
		loader.url = VALID_URL;
		Assert.isFalse(events.length > 0 && Type.enumEq(events[0].type, Cancelled));
	}

	@Test
	public function should_send_with_default_content_type():Void
	{
		Assert.isFalse(loader.headers.exists("Content-Type"));

		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.send("data");

		Assert.isTrue(loader.headers.exists("Content-Type"));
		Assert.areEqual("application/octet-stream", loader.headers.get("Content-Type"));
	}

	@Test
	public function should_detect_xml_content_type():Void
	{
		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.send(Xml.parse("<xml/>"));

		Assert.areEqual("application/xml", loader.headers.get("Content-Type"));
	}

	@Test
	public function should_detect_json_content_type():Void
	{
		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.send({hello:"world"});
		
		Assert.areEqual("application/json", loader.headers.get("Content-Type"));
	}

	@Test
	public function should_send_with_custom_content_type():Void
	{
		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.headers.set("Content-Type", "text/plain");
		loader.send("data");
		
		Assert.areEqual("text/plain", loader.headers.get("Content-Type"));
		Assert.areEqual("text/plain", http.publicHeaders.get("Content-Type"));
	}

	@Test
	public function should_allow_sending_custom_headers():Void
	{
		http.respondTo(VALID_URL).with(Data("content"));
		loader.url = VALID_URL;
		loader.headers.set("foo", "bar");
		loader.send("data");
		
		Assert.areEqual("bar", loader.headers.get("foo"));
		Assert.areEqual("bar", http.publicHeaders.get("foo"));
	}

	@Test
	public function should_update_with_http_status_code()
	{
		// needs http:// so that neko uses http instead of file system
		var url = "http://localhost/text.txt";

		http.respondTo(url).with(Status(100));
		loader.url = url;
		loader.load();

		Assert.areEqual(100, loader.statusCode);
	}

	@Test
	public function converts_object_to_json_string_before_sending():Void
	{
		var object = { foo:"bar" };

		http.respondTo("data.json").with(Data(""));
		loader.url = "data.json";
		loader.send(object);

		var json =  haxe.Json.stringify(object);
		Assert.areEqual(json, http.getPostData());
	}
}
