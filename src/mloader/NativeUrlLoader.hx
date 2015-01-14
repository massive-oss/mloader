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
	public var taskId(default, null):String;
	public var onDatas(default, null):String->Void;
	public var onError(default, null):Int->String->Void;

	static var initialized = false;
	static var map:Map<String, NativeUrlLoader>;

	static function initialize()
	{
		if (!initialized)
		{
			trace("initialized");
			map = new Map();
			Native.setCompletionListener(taskCompleted);
			Native.setErrorListener(taskFailed);
			initialized = true;
		}
	}

	static function registerTask(task:NativeUrlLoader)
	{
		trace("registerTask ::: " + task.taskId);
		map.set(task.taskId, task);
	}

	static function taskCompleted(taskIdentifier:String, datas:String)
	{
		trace("taskCompleted ::: " + taskIdentifier);
		var task = map.get(taskIdentifier);
		if (task != null) task.onDatas(datas);
	}

	static function taskFailed(taskIdentifier:String, code:Int, datas:String)
	{
		trace("taskFailed ::: " + taskIdentifier);
		var task = map.get(taskIdentifier);
		if (task != null) task.onError(code, datas);
	}

	public function new()
	{
		initialize();
	}

	public function setListeners(onDatas:String->Void, onError:Int->String->Void)
	{
		this.onDatas = onDatas;
		this.onError = onError;
	}

	public function load(request:URLRequest)
	{
		taskId = Native.create(request.url);
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
		Native.load(taskId);
		registerTask(this);
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
		//Native.close(taskId);
	}
}

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("mloader")
@CPP_PRIMITIVE_PREFIX("mloader")
class Native
{
	@IOS public static function setCompletionListener(listener:String->String->Void):Void;
	@IOS public static function setErrorListener(listener:String->Int->String->Void):Void;
	
	@IOS public static function configure(taskId:String, method:String, data:String):Void;
	@IOS public static function create(url:String):String{ throw "iOS only";}
	@IOS public static function load(handler:Dynamic):Void;
	@IOS public static function setHeaderField(taskId:String, name:String, value:String):Void;
	@IOS public static function setHttpBody(taskId:String, value:String):Void;
	@IOS public static function setUrl(taskId:String, url:String):Void;
	@IOS public static function setUrlVariable(taskId:String,name:String, value:String):Void;
	@IOS public static function close(taskId:String);
	#end
}
