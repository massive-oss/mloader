/**
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

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