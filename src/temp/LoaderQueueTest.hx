package mloader;

import haxe.PosInfos;
import massive.munit.async.AsyncFactory;
import massive.munit.Assert;
import mcore.util.Timer;
import mloader.Loader;

class LoaderQueueTest
{
	var queue:LoadQueue;
	var log:Dynamic;

	public function new()
	{}

	@Before
	public function setup()
	{
		queue = new LoadQueue();
	}

	@After
	public function cleanup()
	{
		queue.cancel();
	}

	@Test
	public function shouldIncludeAcitveAndPendingLoadersInQueueSize()
	{
		queue.maxLoading = 1;
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));
		queue.load();

		Assert.areEqual(2, queue.size);
		Assert.areEqual(1, queue.numLoading);
	}

	@Test
	public function shouldAddLoaderToQueueButNotStartLoading()
	{
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));

		Assert.areEqual(2, queue.size);
		Assert.isFalse(queue.loading);
		Assert.areEqual(0, queue.numLoaded);
	}

	@Test
	public function shouldLimitActiveLoaderToMaxConcurrent()
	{
		queue.maxLoading = 3;
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));

		queue.load();

		Assert.areEqual(3, queue.numLoading);
	}

	@Test
	public function shouldRemoveLoaderFromQueue()
	{
		var loader = new LoaderMock(FAIL);

		queue.add(loader);
		Assert.isTrue(queue.contains(loader));

		queue.remove(loader);
		Assert.isFalse(queue.contains(loader));
	}

	@Test
	public function shouldRemoveAndCancelActiveLoader()
	{
		var cancelled = false;
		var loader = new LoaderMock(FAIL);
		loader.cancelled.addOnce(function() { cancelled = true; });

		queue.add(loader);
		queue.load();
		queue.remove(loader);

		Assert.isTrue(cancelled);
		Assert.isFalse(queue.contains(loader));
	}

	@Test
	public function shouldCancellAllLoaders()
	{
		var cancelled = 0;
		var loaderOne = new LoaderMock(PASS);
		loaderOne.cancelled.addOnce(function() { cancelled++; });

		var loaderTwo = new LoaderMock(PASS);
		loaderTwo.cancelled.addOnce(function() { cancelled++; });

		var loaderThree = new LoaderMock(PASS);
		loaderThree.cancelled.addOnce(function() { cancelled++; });

		queue.maxLoading = 2;
		queue.add(loaderOne);
		queue.add(loaderTwo);
		queue.add(loaderThree);
		queue.load();

		queue.cancel();

		Assert.areEqual(cancelled, 2); // only cancels active loaders
		Assert.areEqual(0, queue.size);
		Assert.areEqual(0, queue.numLoading);
		Assert.areEqual(0, queue.numLoaded);
	}

	@AsyncTest
	public function shouldRemoveExternallyCancelledLoader(async:AsyncFactory)
	{
		var completedCount = 0;
		var failed = false;
		var handler = async.createHandler(this, function(q) {
			Assert.areEqual(0, completedCount);
		}, 1000);

		queue.progressed.add(function(p) { completedCount++; });
		queue.failed.addOnce(function(error) { failed = true; });
		queue.completed.addOnce(handler);
		queue.add(new LoaderMock(CANCEL));
		queue.load();
	}

	@AsyncTest
	public function shouldDispatchCompletedWhenQueueIsEmpty(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function(q) {}, 1000);

		queue.completed.addOnce(handler);
		queue.maxLoading = 2;
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));
		queue.load();
	}

	@Test
	public function shoulDispatchCompletedWhenLoadingAnEmptyQueue()
	{
		var completedCalled = false;
		queue.completed.addOnce(function(queue) { completedCalled = true; });
		queue.load();
		Assert.isTrue(completedCalled);
	}

	@Test
	public function shouldAutoLoadWhenFlagIsSet()
	{
		queue.maxLoading = 1;
		queue.autoLoad = true;
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));

		Assert.isTrue(queue.loading);
		Assert.areEqual(1, queue.numLoading);
	}

	@AsyncTest
	public function shouldUpdateProgress(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function() {}, 5000);

		var progressed = [];
		queue.progressed.add(function(p) { progressed.push(queue.progress); });
		queue.completed.addOnce(function(q) {
			Assert.areEqual(4, progressed.length);
			Assert.areEqual(0.25, progressed[0]);
			Assert.areEqual(0.5, progressed[1]);
			Assert.areEqual(0.75, progressed[2]);
			Assert.areEqual(1, progressed[3]);
			handler();
		});

		queue.ignoreFailures = false;
		queue.maxLoading = 1;

		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));
		queue.add(new LoaderMock(PASS));
		queue.load();
	}

	@AsyncTest
	public function shouldFailOnFirstError(async:AsyncFactory)
	{
		var completedCount = 0;
		var failingLoader = new LoaderMock(FAIL);

		var handler = async.createHandler(this, function() {}, 5000);

		queue.failed.addOnce(function(error:LoaderError) {
			Assert.areEqual(1, queue.failedLoaders.length);
			Assert.areEqual(failingLoader, queue.failedLoaders[0]);
			Assert.areEqual(0, queue.size);
			Assert.areEqual(1, queue.numLoaded);
			Assert.areEqual(1, completedCount);
			handler();
		});
		queue.progressed.add(function(p) { completedCount++; });

		queue.ignoreFailures = false;
		queue.maxLoading = 1;

		queue.add(new LoaderMock(PASS));
		queue.add(failingLoader);
		queue.add(new LoaderMock(PASS));
		queue.load();
	}

	@AsyncTest
	public function shouldProcessQueueInFIFOOrderWhenNoPrioritiesSet(async:AsyncFactory)
	{
		var order = [];
		var loaderOne = new LoaderMock(PASS, 1);
		loaderOne.completed.addOnce(function(v) { order.push(1); });

		var loaderTwo = new LoaderMock(PASS, 2);
		loaderTwo.completed.addOnce(function(v) { order.push(2); });

		var loaderThree = new LoaderMock(PASS, 3);
		loaderThree.completed.addOnce(function(v) { order.push(3); });

		var handler = async.createHandler(this, function(q) {
			Assert.areEqual(3, order.length);
			Assert.areEqual(1, order[0]);
			Assert.areEqual(2, order[1]);
			Assert.areEqual(3, order[2]);
		}, 5000);

		queue.completed.addOnce(handler);
		queue.maxLoading = 1;
		queue.add(loaderOne);
		queue.add(loaderTwo);
		queue.add(loaderThree);
		queue.load();
	}

	@AsyncTest
	public function shouldProcessQueueInPriorityOrder(async:AsyncFactory)
	{
		var order = [];
		var loaderOne = new LoaderMock(PASS, 1);
		loaderOne.completed.addOnce(function(v) { order.push(1); });

		var loaderTwo = new LoaderMock(PASS, 2);
		loaderTwo.completed.addOnce(function(v) { order.push(2); });

		var loaderThree = new LoaderMock(PASS, 3);
		loaderThree.completed.addOnce(function(v) { order.push(3); });

		var handler = async.createHandler(this, function(q) {
			Assert.areEqual(3, order.length);
			Assert.areEqual(3, order[0]);
			Assert.areEqual(2, order[1]);
			Assert.areEqual(1, order[2]);
		}, 5000);

		queue.completed.addOnce(handler);
		queue.maxLoading = 1;
		queue.addWithPriority(loaderOne, 1);
		queue.addWithPriority(loaderTwo, 2);
		queue.addWithPriority(loaderThree, 3);
		queue.load();
	}

	@AsyncTest
	public function shouldContinueWhenFailuresByDefault(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function() {}, 5000);

		queue.completed.addOnce(function(q) {
			Assert.areEqual(3, queue.numLoaded);
			handler();
		});
		queue.maxLoading = 3;
		queue.add(new LoaderMock(FAIL, 1));
		queue.add(new LoaderMock(FAIL, 2));
		queue.add(new LoaderMock(PASS, 3));
		queue.load();
	}

	@AsyncTest
	public function shouldStoreArrayOfFailedLoaders(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function() {}, 5000);

		queue.completed.addOnce(function(q) {
			Assert.areEqual(2, queue.failedLoaders.length);
			var loaders = Lambda.filter(queue.failedLoaders, function(loader) {
				return untyped loader.id != 1;
			});
			Assert.areEqual(0, loaders.length);
			handler();
		});

		queue.add(new LoaderMock(FAIL, 1));
		queue.add(new LoaderMock(FAIL, 1));
		queue.load();
	}
}

//-------------------------------------

private class LoaderMock extends LoaderBase<Dynamic>
{
	public var outcome:LoaderOutcome;
	public var id:Int;

	public function new(outcome:LoaderOutcome, ?id:Int = -1)
	{
		super("");
		this.outcome = outcome;
		this.id = id;
	}

	override public function load()
	{
		super.load();
		Timer.runOnce(done, 1);
	}

	function done()
	{
		switch(outcome)
		{
			case PASS: completed.dispatch("");
			case FAIL: failed.dispatch(FormatError(""));
			case CANCEL: cancel();
		}
	}

	override public function cancel()
	{
		cancelled.dispatch();
	}

	public function toString()
	{
		return id;
	}
}

private enum LoaderOutcome
{
	PASS;
	FAIL;
	CANCEL;
}
