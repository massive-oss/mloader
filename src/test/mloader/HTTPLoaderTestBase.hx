package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.HTTPLoader;
import mloader.Loader;
import haxe.Http;
import haxe.HttpMock;
import mcore.exception.MissingImplementationException;

/**
* Auto generated MassiveUnit Test Class  for mloader.HTTPLoader 
*/
class HTTPLoaderTestBase<T> extends LoaderBaseTestBase<T>
{
	var httpLoader:HTTPLoader<T>; 

	var http:HttpMock;

	public function new() 
	{
		super();
	}
	
	@Before
	override public function setup():Void
	{
		http = new HttpMock("");
		
		http.respondsTo(createValidURI(), {delay:1, type:Data(createValidStringData())});
		http.respondsTo("invalid", {delay:0, type:Exception("invalid")});

		super.setup();

		httpLoader = cast loader;
	}

	@AsyncTest
	public function send_to_valid_uri_completes(async:AsyncFactory)
	{
		var handler = async.createHandler(this, assertCompleted, 300);
		httpLoader.loaded.addOnce(handler).forType(LoaderEvent.completed);
		httpLoader.url = createValidURI();
		httpLoader.send("some post data");
	}

	@Test
	public function send_with_default_contentType():Void
	{
		var data = "data";

		Assert.isFalse(httpLoader.headers.exists("Content-Type"));

		httpLoader.url = createValidURI();
		httpLoader.send(data);

		Assert.isTrue(httpLoader.headers.exists("Content-Type"));
		Assert.areEqual(getDefaultContentType(), httpLoader.headers.get("Content-Type"));
	}

	@Test
	public function send_with_xml_contentType():Void
	{
		var data = Xml.parse("<data></data>");

		Assert.isFalse(httpLoader.headers.exists("Content-Type"));

		httpLoader.url = createValidURI();
		httpLoader.send(data);

		Assert.isTrue(httpLoader.headers.exists("Content-Type"));
		Assert.areEqual("application/xml", httpLoader.headers.get("Content-Type"));
	}

	@Test
	public function send_with_custom_contentType():Void
	{
		var data = "foo";
		var type = "text/plain";

		httpLoader.url = createValidURI();
		httpLoader.headers.set("Content-Type", type);
		httpLoader.send(data);

		Assert.areEqual(type, httpLoader.headers.get("Content-Type"));
	}

	
	@AsyncTest
	public function load_invalid_url_fails_with_io_error(async:AsyncFactory)
	{
		http.respondsTo("ioError", {delay:1, type:Error("Http Error #404")});

		var handler = async.createHandler(this, assertFailedWithIOError, 300);
		httpLoader.loaded.addOnce(handler).forType(LoaderEvent.failed(null));

		httpLoader.url = "ioError";
		httpLoader.load();
	}


	@AsyncTest
	public function send_to_insecure_url_fails_with_security_error(async:AsyncFactory)
	{
		http.respondsTo("send/securityError", {delay:0, type:Exception("insecure!")});
		var handler = async.createHandler(this, assertFailedWithSecurityError, 300);
		httpLoader.loaded.addOnce(handler).forType(LoaderEvent.failed(null));
		httpLoader.url = "send/securityError";
		httpLoader.send("some post data");
	}

	@AsyncTest
	public function load_insecure_url_fails_with_security_error(async:AsyncFactory)
	{
		http.respondsTo("load/securityError", {delay:0, type:Exception("insecure!")});

		#if neko
			var handler = async.createHandler(this, assertFailedWithIOError, 300);
			
		#else
			var handler = async.createHandler(this, assertFailedWithSecurityError, 300);
		#end

		httpLoader.url = "load/securityError";
		httpLoader.loaded.addOnce(handler).forType(LoaderEvent.failed(null));
		httpLoader.load();
	}

	@Test
	public function set_custom_headers_reaches_http()
	{
		http.respondsTo("customHeaders", {delay:1, type:Data("headers")});

		httpLoader.url = "customHeaders";
		httpLoader.headers.set("Foo", "Bar");
		httpLoader.load();

		Assert.areEqual("Bar", http.publicHeaders.get("Foo"));
	}

	@Test
	public function throws_exception_if_url_is_null()
	{
		try
		{
			httpLoader.url = null;
			httpLoader.send("");
			Assert.fail("expected mcore.exception.ArgumentException");
		}
		catch(e: mcore.exception.ArgumentException)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function should_update_statusCode()
	{
		http.onStatus(100);
		Assert.areEqual(100, httpLoader.statusCode);
	}

	/////// common asserts

	function assertFailedWithIOError(error:LoaderError)
	{
		Assert.isTrue(switch (error)
		{
			case io(info): true;
			default: false;
		});
	}

	function assertFailedWithSecurityError(error:LoaderError)
	{
		Assert.isTrue(switch (error)
		{
			case security(info): true;
			default: false;
		});
	}

	function assertFailedWithFormatError(error:LoaderError)
	{
		Assert.isTrue(switch (error)
		{
			case format(info): true;
			default: false;
		});
	}


	////////////

	/**
	Override this to create instance of concreate HTTPLoader sub type
	*/
	function createHTTPLoader():HTTPLoader<T>
	{
		throw new MissingImplementationException();
		return null;
	}

	override function createLoaderBase():LoaderBase<T>
	{
		return createHTTPLoader();
	}


	function getDefaultContentType():String
	{
		return "application/octet-stream";
	}
}
