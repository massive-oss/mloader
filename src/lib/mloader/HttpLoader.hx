package mloader;

import mcore.exception.ArgumentException;
import mloader.Loader;
import msignal.Signal;
import mcore.exception.Exception;
import haxe.Http;

using mcore.util.Strings;

/**
The HTTPLoader class is responsible for loading content over HTTP.
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
	HTTP status code of response.
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
			loaded.dispatchType(Failed(IO("Local file does not exist: " + url)));
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
		if (url == null)
			throw new ArgumentException("No url defined for Loader");

		#if debug
			checkListeners();
		#end
		
		if (!headers.exists("Content-Type"))
		{
			var contentType = getMIMEType(data);
			headers.set("Content-Type", contentType);
		}

		http.url = url;
		http.setPostData(Std.string(data));
		
		httpConfigure();
		addHeaders();

		try
		{
			http.request(true);
		}
		catch (e:Dynamic)
		{
			// js can throw synchronous security error
			loaded.dispatchType(Failed(Security(Std.string(e))));
		}
	}

	/**
	Returns the MIME type for the current data.
	
	Currently only auto-detects Xml and Json. Defaults to 'application/octet-stream'.
	
	Note: This can be overwritten by adding a 'Content-Type' to the headers hash
	*/
	function getMIMEType(data:Dynamic):String
	{	
		if (Std.is(data, Xml))
		{
			return "application/xml";
		}
		
		data = Std.string(data);

		if (data.length > 0 &&
			(data.charAt(0) == "{" && data.charAt(data.length - 1) == "}") ||
			(data.charAt(0) == "[" && data.charAt(data.length - 1) == "]"))
		{
			return "application/json";
		}
		else
		{
			return "application/octet-stream";
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
			loaded.dispatchType(Failed(Security(Std.string(e))));
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
		loaded.dispatchType(Failed(IO(error)));
	}
}
