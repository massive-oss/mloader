package mloader;

import openfl.net.URLRequest;

class NativeUrlLoaderAndroid extends NativeMLoader
{
	public var onDatas:String->Void;
	public var onError:Int->String->Void;

	public var nativeInstance(default, null):Dynamic;

	public function new()
	{
		nativeInstance = NativeMLoader.create();
		setListener(nativeInstance, this);
	}

	public function execute(request:URLRequest)
	{
		setUrl(nativeInstance, request.url);
		setMethod(nativeInstance, request.method);
		load(nativeInstance);
	}

	public function setContentType(value:String)
	{
		setHttpContentType(nativeInstance, value);
	}

	public function setHeader(key:String, value:String)
	{
		setHttpHeader(nativeInstance, key, value);
	}

	public function setVariable(key:String, value:String)
	{
		setHttpVariable(nativeInstance, key, value);
	}

	public function setBody(value:String)
	{
		setHttpBody(nativeInstance, value);
	}

	public function onDatasFromJava(datas:String)
	{
		haxe.Timer.delay(function()
		{
			onDatas(datas);
		}, 2);
	}
}


@:build(ShortCuts.mirrors())
@JNI_DEFAULT_CLASS_NAME("NativeMLoader")
@JNI_DEFAULT_PACKAGE("massive.mloader")
class NativeMLoader
{
	@JNI public static function create():NativeUrlLoaderAndroid;
	@JNI public function setHttpContentType(instance:NativeMLoader,value:String);
	@JNI public function setListener(instance:NativeMLoader,listener:Dynamic);
	@JNI public function load(instance:NativeMLoader);
	@JNI public function close(instance:NativeMLoader);
	@JNI public function setMethod(instance:NativeMLoader, value:String);
	@JNI public function setUrl(instance:NativeMLoader, value:String);
	@JNI public function setTaskId(instance:NativeMLoader, value:String);
	@JNI public function setHttpBody(instance:NativeMLoader, value:String);
	@JNI public function setHttpHeader(instance:NativeMLoader, key:String, value:String);
	@JNI public function setHttpVariable(instance:NativeMLoader, key:String, value:String);
}
