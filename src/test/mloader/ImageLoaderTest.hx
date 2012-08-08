package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.Loader;
import mloader.ImageLoader;

#if (flash || js)

class ImageLoaderTest
{
	var loader:ImageLoader;
	var events:Array<Dynamic>;
	
	@Before
	public function setup():Void
	{
		events = [];
		loader = new ImageLoader(null);
		loader.loaded.add(function (e) { events.unshift(e); });
	}
	
	@After
	public function tearDown():Void
	{
		loader.loaded.removeAll();
		loader = null;
		events = null;
	}

	@AsyncTest
	public function should_load_image(async:AsyncFactory):Void
	{
		var handler = async.createHandler(this, assertCompleted, 2000);
		loader.loaded.add(handler).forType(Completed);
		loader.url = "test.jpg";
		loader.load();
	}

	function assertCompleted(event:Dynamic):Void
	{
		Assert.isTrue(Type.enumEq(event.type, Completed));
	}

	@AsyncTest
	public function should_cancel_load(async:AsyncFactory):Void
	{
		var handler = async.createHandler(this, assertDidNotComplete, 2000);
		haxe.Timer.delay(handler, 200);

		loader.url = "test.jpg";
		loader.load();
		loader.cancel();
	}

	function assertDidNotComplete()
	{
		Assert.isFalse(Type.enumEq(events[0].type, Completed));
	}
}

#else

class ImageLoaderTest
{
	@Test
	public function should_throw_exception()
	{
		try
		{
			var instance = new ImageLoader();
			Assert.fail("expected exception");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
			return;
		}
	}
}

#end