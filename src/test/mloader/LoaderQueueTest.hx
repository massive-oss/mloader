package mloader;

import haxe.PosInfos;
import massive.munit.async.AsyncFactory;
import massive.munit.Assert;
import mcore.util.Timer;
import mloader.Loader;

class LoaderQueueTest
{
	static var FAILED = Failed(IO(""));

	var queue:LoaderQueue;
	var log:Dynamic;

	@Before
	public function setup()
	{
		queue = new LoaderQueue();
	}

	@After
	public function cleanup()
	{
		queue.cancel();
		queue.loaded.removeAll();
		queue = null;
	}

	@Test
	public function should_include_acitve_and_pending_loaders_in_queue_size()
	{
		queue.maxLoading = 1;
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));
		queue.load();

		Assert.areEqual(2, queue.size);
		Assert.areEqual(1, queue.numLoading);
	}

	@Test
	public function should_add_loader_to_queue_but_not_start_loading()
	{
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));

		Assert.areEqual(2, queue.size);
		Assert.isFalse(queue.loading);
		Assert.areEqual(0, queue.numLoaded);
	}

	@Test
	public function should_limit_num_loading_to_max_loading()
	{
		queue.maxLoading = 3;
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));

		queue.load();
		Assert.areEqual(3, queue.numLoading);
	}

	@Test
	public function should_remove_loader_from_queue()
	{
		var loader = new LoaderMock(FAILED);

		queue.add(loader);
		Assert.areEqual(1, queue.size);

		queue.remove(loader);
		Assert.areEqual(0, queue.size);
	}

	@Test
	public function should_remove_and_cancel_active_loader()
	{
		var cancelled = false;
		var loader = new LoaderMock(FAILED);
		loader.loaded.addOnce(function(e) { Console.log(e.type); cancelled = true; }).forType(Cancelled);

		queue.add(loader);
		queue.load();
		Assert.isTrue(loader.loading);
		queue.remove(loader);

		Assert.isTrue(cancelled);
		Assert.areEqual(0, queue.size);
	}

	@Test
	public function should_cancell_all_loaders()
	{
		var cancelled = 0;
		var loaderOne = new LoaderMock(Completed);
		loaderOne.loaded.addOnce(function(e) { cancelled++; }).forType(Cancelled);

		var loaderTwo = new LoaderMock(Completed);
		loaderTwo.loaded.addOnce(function(e) { cancelled++; }).forType(Cancelled);

		var loaderThree = new LoaderMock(Completed);
		loaderThree.loaded.addOnce(function(e) { cancelled++; }).forType(Cancelled);

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

	@Test
	public function should_remove_externally_cancelled_loader()
	{
		var loader = new LoaderMock(Completed);
		queue.add(loader);
		queue.load();

		Assert.isTrue(loader.loading);
		Assert.areEqual(queue.numLoading, 1);
		loader.cancel();
		Assert.areEqual(queue.numLoading, 0);

	}

	@AsyncTest
	public function should_dispatch_completed_when_queue_is_empty(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function(q) {}, 1000);

		queue.loaded.addOnce(handler).forType(Completed);
		queue.maxLoading = 2;
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));
		queue.load();
	}

	@Test
	public function should_dispatch_completed_when_loading_an_empty_queue()
	{
		var completedCalled = false;
		queue.loaded.addOnce(function(queue) { completedCalled = true; }).forType(Completed);
		queue.load();
		Assert.isTrue(completedCalled);
	}

	@Test
	public function should_auto_load_when_flag_is_set()
	{
		queue.maxLoading = 1;
		queue.autoLoad = true;
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));

		Assert.isTrue(queue.loading);
		Assert.areEqual(1, queue.numLoading);
	}

	@AsyncTest
	public function should_update_progress(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function() {}, 5000);

		var progressed = [];
		queue.loaded.add(function(p) { progressed.push(queue.progress); }).forType(Progressed);
		queue.loaded.addOnce(function(q) {
			Assert.areEqual(4, progressed.length);
			Assert.areEqual(0.25, progressed[0]);
			Assert.areEqual(0.5, progressed[1]);
			Assert.areEqual(0.75, progressed[2]);
			Assert.areEqual(1, progressed[3]);
			handler();
		}).forType(Completed);

		queue.ignoreFailures = false;
		queue.maxLoading = 1;

		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(Completed));
		queue.load();
	}

	@AsyncTest
	public function should_fail_on_first_error(async:AsyncFactory)
	{
		var completedCount = 0;
		var handler = async.createHandler(this, function() {}, 5000);

		queue.loaded.addOnce(function(e) {
			Assert.areEqual(1, queue.numFailed);
			Assert.areEqual(1, queue.size);
			Assert.areEqual(1, queue.numLoaded);
			Assert.areEqual(1, completedCount);
			handler();
		}).forType(Failed(null));
		queue.loaded.add(function(e) { completedCount++; }).forType(Progressed);

		queue.ignoreFailures = false;
		queue.maxLoading = 1;

		queue.add(new LoaderMock(Completed));
		queue.add(new LoaderMock(FAILED));
		queue.add(new LoaderMock(Completed));
		queue.load();
	}

	@AsyncTest
	public function should_process_queue_in_fifo_order_when_no_priority_is_set(async:AsyncFactory)
	{
		var order = [];
		var loaderOne = new LoaderMock(Completed, 1);
		loaderOne.loaded.addOnce(function(v) { order.push(1); }).forType(Completed);

		var loaderTwo = new LoaderMock(Completed, 2);
		loaderTwo.loaded.addOnce(function(v) { order.push(2); }).forType(Completed);

		var loaderThree = new LoaderMock(Completed, 3);
		loaderThree.loaded.addOnce(function(v) { order.push(3); }).forType(Completed);

		var handler = async.createHandler(this, function(q) {
			Assert.areEqual(3, order.length);
			Assert.areEqual(1, order[0]);
			Assert.areEqual(2, order[1]);
			Assert.areEqual(3, order[2]);
		}, 5000);

		queue.loaded.addOnce(handler).forType(Completed);
		queue.maxLoading = 1;
		queue.add(loaderOne);
		queue.add(loaderTwo);
		queue.add(loaderThree);
		queue.load();
	}

	@AsyncTest
	public function should_process_queue_in_priority_order(async:AsyncFactory)
	{
		var order = [];
		var loaderOne = new LoaderMock(Completed, 1);
		loaderOne.loaded.addOnce(function(v) { order.push(1); }).forType(Completed);

		var loaderTwo = new LoaderMock(Completed, 2);
		loaderTwo.loaded.addOnce(function(v) { order.push(2); }).forType(Completed);

		var loaderThree = new LoaderMock(Completed, 3);
		loaderThree.loaded.addOnce(function(v) { order.push(3); }).forType(Completed);

		var handler = async.createHandler(this, function(q) {
			Assert.areEqual(3, order.length);
			Assert.areEqual(3, order[0]);
			Assert.areEqual(2, order[1]);
			Assert.areEqual(1, order[2]);
		}, 5000);

		queue.loaded.addOnce(handler).forType(Completed);
		queue.maxLoading = 1;
		queue.addWithPriority(loaderOne, 1);
		queue.addWithPriority(loaderTwo, 2);
		queue.addWithPriority(loaderThree, 3);
		queue.load();
	}

	@AsyncTest
	public function should_continue_when_loader_fails_by_default(async:AsyncFactory)
	{
		var handler = async.createHandler(this, function() {}, 5000);

		queue.loaded.addOnce(function(q) {
			Assert.areEqual(3, queue.numLoaded);
			handler();
		}).forType(Completed);
		queue.maxLoading = 3;
		queue.add(new LoaderMock(FAILED, 1));
		queue.add(new LoaderMock(FAILED, 2));
		queue.add(new LoaderMock(Completed, 3));
		queue.load();
	}
}

private class LoaderMock extends LoaderBase<Dynamic>
{
	public var id(default, null):Int;
	public var outcome(default, null):LoaderEvent;
	
	public function new(outcome:LoaderEvent, ?id:Int=-1)
	{
		super("");
		this.outcome = outcome;
		this.id = id;
	}

	override function loaderLoad()
	{
		Timer.runOnce(done, 10);
	}

	override function loaderCancel()
	{
		// empty
	}

	function done()
	{
		loaded.dispatchType(outcome);
	}
}
