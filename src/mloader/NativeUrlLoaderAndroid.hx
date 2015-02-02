package mloader;

import openfl.net.URLRequest;

class NativeUrlLoaderAndroid extends NativeMloader
{
	public var onDatas:String->Void;
	public var onError:Int->String->Void;

	public var nativeInstance(default, null):Dynamic;

	public function new()
	{
		nativeInstance = NativeMloader.create();
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
class NativeMloader
{
	@JNI @JNI_CONSTRUCTOR static public function create():NativeUrlLoaderAndroid;
	@JNI public function setHttpContentType(instance:NativeMloader,value:String);
	@JNI public function setListener(instance:NativeMloader,listener:Dynamic);
	@JNI public function load(instance:NativeMloader);
	@JNI public function close(instance:NativeMloader);
	@JNI public function setMethod(instance:NativeMloader, value:String);
	@JNI public function setUrl(instance:NativeMloader, value:String);
	@JNI public function setTaskId(instance:NativeMloader, value:String);
	@JNI public function setHttpBody(instance:NativeMloader, value:String);
	@JNI public function setHttpHeader(instance:NativeMloader, key:String, value:String);
	@JNI public function setHttpVariable(instance:NativeMloader, key:String, value:String);
}
