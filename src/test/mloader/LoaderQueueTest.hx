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
		queue.add(new LoaderMock("", false));
		queue.add(new LoaderMock("", false));
		queue.load();

		Assert.areEqual(2, queue.size);
		Assert.areEqual(1, queue.numLoading);
	}

	@Test
	public function should_add_loader_to_queue_but_not_start_loading()
	{
		queue.add(new LoaderMock());
		queue.add(new LoaderMock());

		Assert.areEqual(2, queue.size);
		Assert.isFalse(queue.loading);
		Assert.areEqual(0, queue.numLoaded);
	}

	@Test
	public function should_limit_num_loading_to_max_loading()
	{
		queue.maxLoading = 3;
		queue.add(new LoaderMock("", false));
		queue.add(new LoaderMock("", false));
		queue.add(new LoaderMock("", false));
		queue.add(new LoaderMock("", false));

		queue.load();
		Assert.areEqual(3, queue.numLoading);
	}

	@Test
	public function should_remove_loader_from_queue()
	{
		var loader = new LoaderMock();

		queue.add(loader);
		Assert.areEqual(1, queue.size);

		queue.remove(loader);
		Assert.areEqual(0, queue.size);
	}

	@Test
	public function should_remove_and_cancel_active_loader()
	{
		var loader = new LoaderMock("", false);

		queue.add(loader);
		queue.load();
		Assert.isTrue(loader.loading);
		queue.remove(loader);

		Assert.isTrue(loader.didCancel);
		Assert.areEqual(0, queue.size);
	}

	@Test
	public function should_cancell_all_loaders()
	{
		var loader1 = new LoaderMock("", false);
		var loader2 = new LoaderMock("", false);
		var loader3 = new LoaderMock("", false);

		queue.maxLoading = 2;
		queue.add(loader1);
		queue.add(loader2);
		queue.add(loader3);
		queue.load();

		queue.cancel();

		Assert.isTrue(loader1.didCancel);
		Assert.isTrue(loader2.didCancel);
		Assert.isFalse(loader3.didCancel); // only cancels active loaders
		
		Assert.areEqual(0, queue.size);
		Assert.areEqual(0, queue.numLoading);
		Assert.areEqual(0, queue.numLoaded);
	}

	@Test
	public function should_remove_externally_cancelled_loader()
	{
		var loader = new LoaderMock("", false);
		queue.add(loader);
		queue.load();

		Assert.isTrue(loader.loading);
		Assert.areEqual(queue.numLoading, 1);
		loader.cancel();
		Assert.areEqual(queue.numLoading, 0);
	}

	@Test
	public function should_dispatch_completed_when_queue_is_empty()
	{
		var completed = false;
		queue.loaded.addOnce(function(e){
			completed = true;
		}).forType(Completed);

		queue.maxLoading = 2;
		queue.add(new LoaderMock());
		queue.add(new LoaderMock());
		queue.load();

		Assert.isTrue(completed);
	}

	@Test
	public function should_dispatch_completed_when_loading_an_empty_queue()
	{
		var completed = false;
		queue.loaded.addOnce(function(e){
			completed = true;
		}).forType(Completed);

		queue.load();
		Assert.isTrue(completed);
	}

	@Test
	public function should_auto_load_when_flag_is_set()
	{
		queue.maxLoading = 1;
		queue.autoLoad = true;
		queue.add(new LoaderMock("", false));
		queue.add(new LoaderMock("", false));

		Assert.isTrue(queue.loading);
		Assert.areEqual(1, queue.numLoading);
	}

	@Test
	public function should_update_progress()
	{
		var completed = false;
		var progressed = [];

		queue.loaded.add(function(p) { progressed.push(queue.progress); }).forType(Progressed);
		queue.loaded.addOnce(function(q) {
			Assert.areEqual(4, progressed.length);
			Assert.areEqual(0.25, progressed[0]);
			Assert.areEqual(0.5, progressed[1]);
			Assert.areEqual(0.75, progressed[2]);
			Assert.areEqual(1, progressed[3]);
			completed = true;
		}).forType(Completed);

		queue.ignoreFailures = false;
		queue.maxLoading = 1;

		queue.add(new LoaderMock());
		queue.add(new LoaderMock());
		queue.add(new LoaderMock());
		queue.add(new LoaderMock());
		queue.load();

		Assert.isTrue(completed);
	}

	@Test
	public function should_fail_on_first_error()
	{
		var failed = false;

		var loader1 = new LoaderMock("", false);
		var loader2 = new LoaderMock("", false);
		var loader3 = new LoaderMock("", false);

		queue.loaded.addOnce(function(e){
			Assert.areEqual(1, queue.numFailed);
			Assert.areEqual(1, queue.size);
			Assert.areEqual(1, queue.numLoaded);

			Assert.isFalse(loader1.didFail);
			Assert.isTrue(loader1.didComplete);

			Assert.isTrue(loader2.didFail);

			Assert.isFalse(loader3.didLoad);
			Assert.isFalse(loader3.didFail);

			failed = true;
		}).forType(Failed(null));

		queue.ignoreFailures = false;
		queue.maxLoading = 1;

		queue.add(loader1);
		queue.add(loader2);
		queue.add(loader3);
		queue.load();

		loader1.complete();
		loader2.fail();

		Assert.isTrue(failed);
	}

	@Test
	public function should_process_queue_in_fifo_order_when_no_priority_is_set()
	{
		var loader1 = new LoaderMock();
		var loader2 = new LoaderMock();
		var loader3 = new LoaderMock();

		var order = [];
		loader1.loaded.addOnce(function(v) { order.push(1); }).forType(Completed);
		loader2.loaded.addOnce(function(v) { order.push(2); }).forType(Completed);
		loader3.loaded.addOnce(function(v) { order.push(3); }).forType(Completed);

		var completed = false;
		queue.loaded.addOnce(function(e){
			Assert.areEqual(3, order.length);
			Assert.areEqual(1, order[0]);
			Assert.areEqual(2, order[1]);
			Assert.areEqual(3, order[2]);

			completed = true;
		}).forType(Completed);

		queue.maxLoading = 1;
		queue.add(loader1);
		queue.add(loader2);
		queue.add(loader3);
		queue.load();

		Assert.isTrue(completed);
	}

	@Test
	public function should_process_queue_in_priority_order():Void
	{
		var loader1 = new LoaderMock();
		var loader2 = new LoaderMock();
		var loader3 = new LoaderMock();

		var order = [];
		loader1.loaded.addOnce(function(v) { order.push(1); }).forType(Completed);
		loader2.loaded.addOnce(function(v) { order.push(2); }).forType(Completed);
		loader3.loaded.addOnce(function(v) { order.push(3); }).forType(Completed);

		var completed = false;
		queue.loaded.addOnce(function(e){
			Assert.areEqual(3, order.length);
			Assert.areEqual(3, order[0]);
			Assert.areEqual(2, order[1]);
			Assert.areEqual(1, order[2]);

			completed = true;
		}).forType(Completed);

		queue.maxLoading = 1;
		queue.addWithPriority(loader1, 1);
		queue.addWithPriority(loader2, 2);
		queue.addWithPriority(loader3, 3);
		queue.load();

		Assert.isTrue(completed);
	}

	@Test
	public function should_continue_when_loader_fails_by_default()
	{
		var loader1 = new LoaderMock("", false);
		var loader2 = new LoaderMock("", false);
		var loader3 = new LoaderMock("", false);

		var completed = false;
		queue.loaded.addOnce(function(q) {
			Assert.areEqual(3, queue.numLoaded);
			completed = true;
		}).forType(Completed);

		queue.maxLoading = 3;
		queue.add(loader1);
		queue.add(loader2);
		queue.add(loader3);
		queue.load();

		loader1.complete();
		loader2.fail();
		loader3.complete();

		Assert.isTrue(completed);
	}
}
