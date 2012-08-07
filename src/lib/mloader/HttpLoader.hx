package mloader;

import mcore.exception.ArgumentException;
import mloader.Loader;
import msignal.Signal;
import mcore.exception.Exception;
import haxe.Http;

using mcore.util.Strings;

/**
The HttpLoader class is responsible for loading content over Http.
*/
class HttpLoader<T> extends LoaderBase<T>
{
	/**
	The http instance used to load the content.
	*/
	var http:Http;

	/**
	The headers to pass through with the http request.
	*/
	public var headers(default, null):Hash<String>;

	/**
	Http status code of response.
	*/
	public var statusCode(default, null):Int;

	/**
	@param url  the url to load the resource from
	@param http optional Http instance to use for the load request
	*/
	function new(?url:String, ?http:Http)
	{
		super(url);
		
		if (http == null) http = new Http("");

		this.http = http;
		http.onData = httpData;
		http.onError = httpError;
		http.onStatus = httpStatus;

		headers = new Hash();
	}
	
	#if neko

	/**
	Workaround to enable loading relative urls in neko
	*/
	function loadFromFileSystem(url:String)
	{
		if (!sys.FileSystem.exists(url))
		{
			loaderFail(IO("Local file does not exist: " + url));
		}
		else
		{
			var contents = sys.io.File.getContent(url);
			httpData(contents);
		}
	}
	#end
	
	/**
	Configures and makes the http request. The send method can also pass 
	through data with the request. It also traps any security errors and 
	dispatches a failed signal.
	
	@param url The URI to load.
	@param data Data to pass through with the request.
	*/
	public function send(data:Dynamic)
	{
		// if currently loading, cancel
		if (loading) cancel();

		// if no url, throw exception
		if (url == null) throw "No url defined for Loader";

		// update state
		loading = true;

		// dispatch started
		loaded.dispatchType(Started);

		// default content type
		var contentType = "application/octet-stream";
		
		if (Std.is(data, Xml))
		{
			// convert to string and send as application/xml
			data = Std.string(data);
			contentType = "application/xml";
		}
		else if (!Std.is(data, String))
		{
			// stringify and send as application/json
			data = haxe.Json.stringify(data);
			contentType = "application/json";
		}
		
		// only set content type if not already set
		if (!headers.exists("Content-Type"))
		{
			headers.set("Content-Type", contentType);
		}

		http.url = url;
		http.setPostData(data);
		
		httpConfigure();
		addHeaders();

		try
		{
			http.request(true);
		}
		catch (e:Dynamic)
		{
			// js can throw synchronous security error
			loaderFail(Security(Std.string(e)));
		}
	}

	//-------------------------------------------------------------------------- private
	
	override function loaderLoad()
	{
		http.url = url;
		httpConfigure();
		addHeaders();

		#if nme
		if (url.indexOf("http:") == 0)
		{
			haxe.Timer.delay(callback(http.request, false), 10);
		}
		else
		{
			var result = nme.installer.Assets.getText("root/" + url);
			haxe.Timer.delay(callback(httpData, result), 10);
		}
		#elseif neko
		if (url.indexOf("http:") == 0)
		{
			http.request(false);
		}
		else
		{	
			loadFromFileSystem(url);
		}
		#else
		try
		{
			http.request(false);
		}
		catch (e:Dynamic)
		{
			// js can throw synchronous security error
			loaderFail(Security(Std.string(e)));
		}
		#end
	}
	
	override function loaderCancel():Void
	{
		#if !(cpp || neko || php)
		http.cancel();
		#end
	}

	function httpConfigure()
	{
		// abstract
	}
	
	function addHeaders()
	{
		for (name in headers.keys())
		{
			http.setHeader(name, headers.get(name));
		}
	}
	
	function httpData(data:String)
	{
		content = cast data;
		loaderComplete();
	}
	
	function httpStatus(status:Int)
	{
		statusCode = status;
	}
	
	function httpError(error:String)
	{
		loaderFail(IO(error));
	}
}
