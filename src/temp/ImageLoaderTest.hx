package mloader;


import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.ImageLoader;
import mloader.Loader;


#if js

/**
* Auto generated MassiveUnit Test Class  for mloader.ImageLoader 
*/
class ImageLoaderTest extends ImageLoaderTestBase<js.Dom.Image>
{
	public function new() 
	{
		super();
	}
	
	@Before
	override public function setup():Void
	{
		super.setup();
	}

	///////

	override function createLoaderBase():LoaderBase<js.Dom.Image>
	{
		return new ImageLoader();
	}

	
}

#elseif (flash || cpp)

import flash.events.ProgressEvent;

class ImageLoaderTest extends ImageLoaderTestBase<flash.display.BitmapData>
{
	public function new() 
	{
		super();
	}
	
	@Before
	override public function setup():Void
	{
		super.setup();
	}

	@Test
	public function should_dispatch_progress()
	{
		var event = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 100);

		untyped imageLoader.loadProgress(event);

		Assert.areEqual(1, progressedCount);
		Assert.areEqual(0.5, progressedValue);
			
	}
	
	@Test
	public function should_dispatch_zero_progress()
	{
		var event = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 0);

		untyped imageLoader.loadProgress(event);

		Assert.areEqual(1, progressedCount);
		Assert.areEqual(0.0, progressedValue);
			
	}

	///////

	override function createLoaderBase():LoaderBase<flash.display.BitmapData>
	{
		return new ImageLoader();
	}
}

#else

import mcore.exception.MissingImplementationException;

class ImageLoaderTest
{
	public function new()
	{

	}

	@Test
	public function should_throw_missing_implenentation_exception()
	{
		try
		{
			var instance = new ImageLoader();
			Assert.fail("expected MissingImplementationException");
		}
		catch(e:MissingImplementationException)
		{
			Assert.isTrue(true);
		}
	}
}
#end