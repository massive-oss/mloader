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

import mloader.Loader;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class LoaderCacheTest
{
	var cache:LoaderCache;

	@Before
	public function setup()
	{
		cache = new LoaderCache();
	}

	@After
	public function tearDown()
	{
		cache = null;
	}

	@Test
	public function load_same_url_twice_only_loads_first_but_both_complete():Void
	{
		var loader1 = new LoaderMock("test.txt");
		var loader2 = new LoaderMock("test.txt");

		cache.load(loader1);
		cache.load(loader2);

		Assert.isTrue(loader1.didLoad);
		Assert.isFalse(loader2.didLoad);

		Assert.isTrue(loader1.didComplete);
		Assert.isTrue(loader2.didComplete);
	}

	@Test
	public function loading_same_url_twice_then_cancelling_first_still_completes_second():Void
	{
		var loader1 = new LoaderMock("test.txt", false);
		var loader2 = new LoaderMock("test.txt");
		
		cache.load(loader1);
		cache.load(loader2);
		loader1.cancel();

		Assert.isTrue(loader1.didCancel);
		Assert.isTrue(loader2.didLoad);
		Assert.isTrue(loader2.didComplete);
	}
}
