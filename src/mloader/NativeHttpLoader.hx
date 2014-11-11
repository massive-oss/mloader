package mloader;

import mloader.Http;
#if ios
import mloader.NativeUrlLoader;
#end

class NativeHttpLoader extends mloader.HttpLoader<Dynamic>
{
	#if ios
	var nativeLoader:NativeUrlLoader;

	public function new(?url:String, ?http:Http)
	{
		super(url, http);

		nativeLoader = new NativeUrlLoader();
		nativeLoader.setListeners(httpData, nativeHttpError);
	}

	override public function send(data:Dynamic)
	{
		// if currently loading, cancel
		if (loading) cancel();

		// if no url, throw exception
		if (url == null) throw "No url defined for Loader";

		// update state
		loading = true;

		// dispatch started
		loaded.dispatchType(Start);

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
		else if (Std.is(data, String) && validateJSONdata(data))
		{
			//data is already a valid JSON string
			contentType = "application/json";
		}

		urlRequest.contentType = contentType;
		httpConfigure();
		addHeaders();

		urlRequest.url = url;
		urlRequest.method = flash.net.URLRequestMethod.POST;
		urlRequest.data = data;

		nativeLoader.load(urlRequest);
	}

	override function loaderLoad()
	{
		httpConfigure();
		addHeaders();
		
		urlRequest.url = url;
		if (url.indexOf("http:") == 0 || url.indexOf("https:") == 0)
		{
			nativeLoader.load(urlRequest);
		}
	}

	function nativeHttpError(code:Int, data:String)
	{
		trace("nativeHttpError ::: " + code + " /// " + data);
		httpStatus(code);
		httpError(data);
	}
	
	#end
}
