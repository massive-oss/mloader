package mloader;

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("mloader")
@CPP_PRIMITIVE_PREFIX("mloader")

class NativeHttpLoader
{
	@IOS public static function create(url:String):Dynamic
	{
		throw "iOS only";
	}

	@IOS public static function test(handler:Dynamic, url:String):Dynamic
	{
		throw "iOS only";
	}

	@IOS public static function setListener(handler:Dynamic, 
		listener:String->Void):Void{}
	@IOS public static function load(handler:Dynamic):Void{}
	@IOS public static function setUrlVariable(handle:Dynamic,
		name:String, value:String):Void{}
}
