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
