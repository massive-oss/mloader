/*
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
		loader.loaded.addOnce(handler).forType(Complete);
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
