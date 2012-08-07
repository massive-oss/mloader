package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.SwfLoader;

#if flash

import flash.events.ProgressEvent;

class SWFLoaderTest
{
	@Test
	public function should_dispatch_progress()
	{
		var event = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 100);

		untyped loaderBase.loadProgress(event);

		Assert.areEqual(1, progressedCount);
		Assert.areEqual(0.5, progressedValue);
	}
	
	@Test
	public function should_dispatch_zero_progress()
	{
		var event = new ProgressEvent(ProgressEvent.PROGRESS, false, false, 50, 0);

		untyped loaderBase.loadProgress(event);

		Assert.areEqual(1, progressedCount);
		Assert.areEqual(0.0, progressedValue);
	}

	override function createLoaderBase():LoaderBase<flash.display.Loader>
	{
		return new SWFLoader();
	}

	override function createValidURI():String
	{
		#if neko
			return "resource/test/m/loader/test.swf";
		#else
			return "m/loader/test.swf";
		#end
	}

	override function createValidStringData():String
	{
		return null;
	}
}

#else

import mcore.exception.UnsupportedPlatformException;

class SWFLoaderTest
{
	public function new() {}

	@Test
	public function should_throw_UnsupportedPlatformException()
	{
		try
		{
			var instance = new SWFLoader();
		}
		catch(e:UnsupportedPlatformException)
		{
			return;
		}
		Assert.fail("expected UnsupportedPlatformException");
	}
}
#end
