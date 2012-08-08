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

	@AsyncTest
	public function load_same_url_twice_only_loads_first_but_both_complete(async:AsyncFactory):Void
	{
		var loaded1 = false;
		var loaded2 = false;

		var loader1 = new StringLoader("m/loader/test.txt");
		var loader2 = new StringLoader("m/loader/test.txt");

		loader1.loaded.addOnce(function(e){
			loaded1 = true;
		}).forType(Completed);

		loader2.loaded.addOnce(function(e){
			loaded2 = true;
		}).forType(Completed);

		var handler = async.createHandler(this, function(){
			Assert.isTrue(loaded1);
			Assert.isTrue(loaded2);
		}, 5000);
		haxe.Timer.delay(handler, 500);

		cache.load(loader1);
		cache.load(loader2);
	}

	@AsyncTest
	public function loading_same_url_twice_then_cancelling_first_still_completes_second(async:AsyncFactory):Void
	{
		var loader1 = new StringLoader("m/loader/test.txt");
		var loader2 = new StringLoader("m/loader/test.txt");
		
		cache.load(loader1);
		cache.load(loader2);
		loader1.cancel();

		var handler = async.createHandler(this, function(e){
			Assert.isTrue(true);
		}, 2000);
		loader2.loaded.addOnce(handler).forType(Completed);
	}
}
