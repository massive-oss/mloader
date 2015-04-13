package mloader;

#if (ios || android)
import openfl.net.URLRequest;
import openfl.net.URLVariables;

import mloader.NativeUrlLoader;

import msignal.Signal;
#end

class NativeUrlLoader
{
	#if (ios || android)
	public var taskId(default, null):String;
	public var onDatas(default, null):String->Void;
	public var onError(default, null):Int->String->Void;

	static var initialized = false;
	static var map:Map<String, NativeUrlLoader>;

	public static var defaultUserAgent:String = "mloader";

	static function initialize()
	{
		if (!initialized)
		{
			map = new Map();
			#if ios
			Native.setCompletionListener(taskCompleted);
			Native.setErrorListener(taskFailed);
			#end
			initialized = true;
		}
	}

	static function registerTask(task:NativeUrlLoader)
	{
		map.set(task.taskId, task);
	}

	static function closeTask(task:NativeUrlLoader)
	{
		map.remove(task.taskId);
	}

	static function taskCompleted(taskIdentifier:String, datas:String)
	{
		var task = map.get(taskIdentifier);
		if (task != null) 
		{
			task.onDatas(datas);
			task.close();
		}
	}

	static function taskFailed(taskIdentifier:String, code:Int, datas:String)
	{
		var task = map.get(taskIdentifier);
		if (task != null) 
		{
			task.onError(code, datas);
			task.close();
		}
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
		#if ios
		loadIos(request);
		#end

		#if android
		loadAndroid(request);
		#end
	}

	#if android
	function loadAndroid(request:URLRequest)
	{
		var loader = new NativeUrlLoaderAndroid();

		//Headers
		for (header in request.requestHeaders)
		{
			loader.setHeader(header.name, header.value);
		}
		loader.setContentType(request.contentType);

		var userAgent = request.userAgent;
		if (userAgent == "" || userAgent == null)
			userAgent = defaultUserAgent;

		loader.setHeader("User-Agent", userAgent);

		//Variables
		if (request.data != null && Std.is(request.data, URLVariables) 
			&& Reflect.fields(request.data).length > 0)
		{
			var value:String;
			for(key in Reflect.fields(request.data))
			{
				trace("key ::: " + key);
				value = Reflect.field(request.data, key);
				loader.setVariable(key, value);
			}
		}
		else if (request.data != null && Std.is(request.data, String) && 
			request.data != "")
		{
			loader.setBody(request.data);
		}

		loader.onDatas = onDatas;
		loader.onError = onError;
		loader.execute(request);
	}
	#end


	#if ios
	function loadIos(request:URLRequest)
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
	#end

	public function close()
	{
		closeTask(this);
	}
	#end
}

#if ios
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
}
#end
