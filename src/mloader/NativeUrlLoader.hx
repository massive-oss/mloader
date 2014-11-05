package mloader;

import openfl.net.URLRequest;
import openfl.net.URLVariables;

import mloader.NativeUrlLoader;

import msignal.Signal;

class NativeUrlLoader
{
	public var onDatas:String->Void;

	public function new()
	{
		
	}

	public function load(request:URLRequest)
	{
		var handler = Native.create(request.url);
		Native.configure(handler, request.method + "", request.data);

		//Headers
		for (header in request.requestHeaders)
		{
			Native.setHeaderField(handler, header.name, header.value);
		}

		Native.setHeaderField(handler, "Content-Type", request.contentType);
		Native.setHeaderField(handler, "User-Agent", request.userAgent);
		
		//Variables
		if (request.data != null && Std.is(request.data, URLVariables) 
			&& Reflect.fields(request.data).length > 0)
		{
			for(key in Reflect.fields(request.data))
			{
				Native.setUrlVariable(handler, key, 
					Reflect.field(request.data, key));
			}
		}
		else if (request.data != null && Std.is(request.data, String) && 
			request.data != "")
		{
			Native.setHttpBody(handler, request.data);
		}
	

		Native.setListener(handler, listener);
		Native.load(handler);
	}

	function listener(data:String):Void
	{
		onDatas(data);
	}

	public function close()
	{

	}
}

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("mloader")
@CPP_PRIMITIVE_PREFIX("mloader")
class Native
{
	@IOS public static function create(url:String):Dynamic
	{
		throw "iOS only";
	}

	@IOS public static function test(handler:Dynamic, url:String):Dynamic
	{
		throw "iOS only";
	}

	@IOS public static function configure(handle:Dynamic, method:String, data:String):Void;
	@IOS public static function load(handler:Dynamic):Void;
	@IOS public static function setHeaderField(handle:Dynamic,name:String, value:String):Void;
	@IOS public static function setHttpBody(handle:Dynamic, value:String):Void;
	@IOS public static function setListener(handler:Dynamic, listener:String->Void):Void;
	@IOS public static function setUrl(handler:Dynamic, url:String):Void;
	@IOS public static function setUrlVariable(handle:Dynamic,name:String, value:String):Void;
}
