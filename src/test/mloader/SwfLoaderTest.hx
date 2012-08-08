package mloader;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mloader.SwfLoader;
import mloader.Loader;

#if flash

class SwfLoaderTest
{
	var loader:SwfLoader;

	@Test
	public function setup()
	{
		loader = new SwfLoader();
	}

	@AsyncTest
	public function should_load_swf(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function(e) {
			Assert.areEqual(1, e.target.content.alpha);
		}, 300);
		loader.loaded.addOnce(handler).forType(Completed);
		loader.url = "test.swf";
		loader.load();
	}
}

#else

class SwfLoaderTest
{
	@Test
	public function should_throw_exception()
	{
		try
		{
			var instance = new SwfLoader();
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
