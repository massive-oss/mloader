package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.ImageLoader;

/**
* Auto generated MassiveUnit Test Class  for mloader.ImageLoader 
*/
class ImageLoaderTestBase<T> extends LoaderBaseTestBase<T>
{
	var imageLoader:LoaderBase<T>; 
	
	public function new() 
	{
		super();
	}

	@Before
	override public function setup():Void
	{
		super.setup();
		imageLoader = cast loader;
	}

	override function createValidURI():String
	{
		#if neko
			return "resource/test/m/loader/test.jpg";
		#else
			return "m/loader/test.jpg";
		#end
	}

	override function createValidStringData():String
	{
		return null;
	}
}