package mloader;

#if ios
import openfl.net.URLRequest;
import openfl.net.URLVariables;

import mloader.NativeUrlLoader;

import msignal.Signal;
#end
class NativeUrlLoader
{
	#if ios
	public var onDatas(default, null):String->Void;
	public var onError(default, null):Int->String->Void;

	public function new()
	{
		
	}

	public function setListeners(onDatas:String->Void, onError:Int->String->Void)
	{
		this.onDatas = onDatas;
		this.onError = onError;
	}

	public function load(request:URLRequest)
	{
		var taskId = Native.create(request.url);
		Native.configure(taskId, request.method + "", request.data);

		//Headers
		for (header in request.requestHeaders)
		{
			Native.setHeaderField(taskId, header.name, header.value);
		}
		
		Native.setHeaderField(taskId, "Content-Type", request.contentType);
		Native.setHeaderField(taskId, "User-Agent", request.userAgent);
		
		//Variables
		if (request.data != null && Std.is(request.data, URLVariables) 
			&& Reflect.fields(request.data).length > 0)
		{
			for(key in Reflect.fields(request.data))
			{
				Native.setUrlVariable(taskId, key, Reflect.field(request.data, key));
			}
		}
		else if (request.data != null && Std.is(request.data, String) && 
			request.data != "")
		{
			Native.setHttpBody(taskId, request.data);
		}
	

		Native.setListener(taskId, listener);
		Native.setErrorListener(taskId, errorListener);
		Native.load(taskId);
	}

	function listener(data:String)
	{
		if (data == null)
		{
			errorListener(-1, data);
		}
		else if (onDatas != null && data != "" )
		{
			onDatas(data);
		}
	}

	function errorListener(code:Int, data:String)
	{
		if (onError != null)
			onError(code, data);
	}

	public function close()
	{
		Native.close(taskId);
	}
}

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("mloader")
@CPP_PRIMITIVE_PREFIX("mloader")
class Native
{
	@IOS public static function configure(taskId:String, method:String, data:String):Void;
	@IOS public static function create(url:String):String{ throw "iOS only";}
	@IOS public static function load(handler:Dynamic):Void;
	@IOS public static function setErrorListener(taskId:String, listener:Int->String->Void):Void;
	@IOS public static function setHeaderField(taskId:String, name:String, value:String):Void;
	@IOS public static function setHttpBody(taskId:String, value:String):Void;
	@IOS public static function setListener(taskId:String, listener:String->Void):Void;
	@IOS public static function setUrl(taskId:String, url:String):Void;
	@IOS public static function setUrlVariable(taskId:String,name:String, value:String):Void;
	@IOS public static function close(taskId:String);
	#end
}
