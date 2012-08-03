package mloader;

import mcore.exception.ArgumentException;
import msignal.Signal;
import msignal.Event;
import msignal.EventSignal;
import mloader.Loader;
import mcore.util.Timer;

using Lambda;

typedef LoaderQueueEvent = Event<Loader<Array<AnyLoader>>, LoaderEvent>

/**
A FIFO queue of Loaders with optional priority ordering.

By default loaders are added to the back of the queue and will only begin 
processing once LoaderQueue.load() is called.

You can choose to provide a priority when adding a loader to the queue. Higher 
priorities get processed first. Priority 0 is the default.

If you wish loading to trigger as soon as a Loader is added, set 
LoaderQueue.autoLoad to true.

By default a maximum of eight loaders can be actively loading at one time 
within the queue. You can adjust this by setting the LoaderQueue.maxLoading
value.

By default failures will not be reported directly from the queue and all 
loaders will be processed until LoaderQueue.completed is dispatched.

If you wish for the queue to not proceed after a failure then set 
LoaderQueue.ignoreFailures to false. This will cause the LoaderQueue.failed 
signal to be dispatched when the first failure is detected. No more loaders 
after this failure will be processed and the queue will be cleared.

Example:

var queue = new LoaderQueue();
queue.maxLoading = 2;
queue.ignoreFailures = false;
queue.loaded.add(loaderLoaded);

queue.add(imageLoaderOne);
queue.add(imageLoaderTwo);
queue.add(imageLoaderThree);
queue.add(imageLoaderFour);
queue.addWithPriority(jsonLoader, 2);

queue.load();
*/
class LoaderQueue implements Loader<Array<AnyLoader>>
{
	public var content(default, null):Array<AnyLoader>;

	/**
	The default value for maxLoading.
	*/
	public static inline var DEFAULT_MAX_LOADING:Int = 8;

	/**
	Indicates whether the queue is currently active.
	*/
	public var loading(default, null):Bool;

	/**
	Dispatched when the loading state of the queue changes.
	*/
	public var loaded(default, null):EventSignal<Loader<Array<AnyLoader>>, LoaderEvent>;

	/**
	Defines the maximum amount of concurrent Loaders. Must be greater then 0. 
	Default is 8.
	*/
	public var maxLoading:Int;

	/**
	An option to allow the queue to stop on first error or continue on 
	regardless. Default is true.
	*/
	public var ignoreFailures:Bool;

	/**
	Set to true if you want loading to initiate as soon as there are loaders 
	added to the queue.
	Default is false.
	*/
	public var autoLoad:Bool;

	/**
	The current size of the queue. Includes both active and pending Loaders.
	*/
	public var size(get_size, null):Int;
	function get_size() { return pendingQueue.length + activeLoaders.length; }

	/**
	The number of Loaders sitting in the queue waiting to start their loading.
	*/
	public var numPending(get_numPending, null):Int;
	function get_numPending() { return pendingQueue.length; }

	/**
	The number of loaders currently loading.
	*/
	public var numLoading(get_numLoading, null):Int;
	function get_numLoading() { return activeLoaders.length; }

	/**
	The number of loaders which have finished being processed.

	If ignoreFailures is true this count will also include any loaders which 
	failed to load.
	*/
	public var numLoaded(default, null):Int;

	/**
	The number of Loaders which have failed to load.
	*/
	public var numFailed(default, null):Int;

	/**
	The percentage of loaders completed. Between 0 and 1.
	*/
	public var progress(default, null):Float;

	/**
	This value is not used by the LoaderQueue. Added to adhere to the Loader 
	interface.
	*/
	public var url:String;

	var pendingQueue:Array<PendingLoader>;
	var activeLoaders:Array<AnyLoader>;

	public function new()
	{
		maxLoading = DEFAULT_MAX_LOADING;
		loaded = new EventSignal<Loader<Array<AnyLoader>>, LoaderEvent>(this);

		loading = false;
		ignoreFailures = true;
		autoLoad = false;
		numLoaded = 0;
		numFailed = 0;
		pendingQueue = [];
		activeLoaders = [];
	}

	/**
	Add a loader to the back of the queue.
	*/
	public function add(loader:AnyLoader)
	{
		addWithPriority(loader, 0);
	}

	/**
	Add a loader to the queue with a priority to determine its placement.

	The standard priority is 0. Higher priorities are loaded first.
	*/
	public function addWithPriority(loader:AnyLoader, priority:Int)
	{
		pendingQueue.push({loader:loader, priority:priority});
		pendingQueue.sort(function(a, b) { return b.priority - a.priority; });

		if (autoLoad) load();
	}

	/**
	Remove a specific loader from the queue. If the loader is found in the 
	queue, and is active, then it will be cancelled.
	*/
	public function remove(loader:AnyLoader):Void
	{
		if (containsActiveLoader(loader))
		{
			removeActiveLoader(loader);
			loader.cancel();
			continueLoading();
		}
		else if (containsPendingLoader(loader))
		{
			removePendingLoader(loader);
		}
	}

	/**
	Begin the loading of the queue if it's not already loading.
	*/
	public function load()
	{
		if (!loading && pendingQueue.length > 0)
		{
			loading = true;
			progress = 0;

			loaded.event(started);
			loaded.event(progressed);

			continueLoading();
		}
	}

	function loaderCompleted(loader:AnyLoader)
	{
		loader.loaded.remove(loaderLoaded);
		activeLoaders.remove(loader);
		numLoaded++;

		progress = numLoaded == 0 ? 0 : (numLoaded / (numLoaded + size));
		loaded.event(progressed);

		if (loading)
		{
			if (pendingQueue.length > 0) continueLoading();
			else if (activeLoaders.length == 0) queueCompleted();
		}
		else throw "should not be!";
	}

	function loaderFailed(loader:AnyLoader, error:LoaderError)
	{
		if (ignoreFailures)
		{
			loaderCompleted(loader);
		}
		else
		{
			loader.loaded.remove(loaderLoaded);
			activeLoaders.remove(loader);

			loaded.event(failed(error));
			numLoaded = numFailed = 0;
			loading = false;
		}
	}

	/**
	Load next while there are pending loaders and we are not at maxLoading.
	*/
	function continueLoading()
	{
		while (pendingQueue.length > 0 && activeLoaders.length < maxLoading)
		{
			var info = pendingQueue.shift();
			var loader = info.loader;

			loader.loaded.add(loaderLoaded);
			activeLoaders.push(loader);

			loader.load();
		}
	}

	/**
	Called when the queue completes loading.
	*/
	function queueCompleted()
	{
		loaded.event(completed);
		numLoaded = numFailed = 0;
		loading = false;
	}

	/**
	Cancels all active loaders in the queue. Any loaders which are not active 
	are discarded.
	*/
	public function cancel():Void
	{
		while (activeLoaders.length > 0)
		{
			var loader = activeLoaders.pop();
			loader.loaded.remove(loaderLoaded);
			loader.cancel();
		}

		numLoaded = numFailed = 0;
		pendingQueue = [];

		loaded.event(cancelled);
	}

	/**
	Called when an active loader dispatches a LoaderEvent.
	*/
	function loaderLoaded(event:AnyLoaderEvent)
	{
		var loader = event.target;

		switch (event.type)
		{
			case completed, cancelled: loaderCompleted(loader);
			case failed(e): loaderFailed(loader, e);
			default:
		}
	}

	/**
	Determine if a loader is present in the queue.
	*/
	public function contains(loader:AnyLoader):Bool
	{
		return containsActiveLoader(loader) || containsPendingLoader(loader);
	}

	function containsActiveLoader(loader:AnyLoader)
	{
		for (active in activeLoaders)
			if (active == loader)
				return true;
		return false;
	}

	function containsPendingLoader(loader:AnyLoader)
	{
		for (pending in pendingQueue)
			if (pending.loader == loader)
				return true;
		return false;
	}

	function removeActiveLoader(loader:AnyLoader)
	{
		var i = activeLoaders.length;
		while (i-- > 0)
		{
			if (activeLoaders[i] == loader)
			{
				loader.loaded.remove(loaderLoaded);
				activeLoaders.splice(i, 1);

				// no break as could be added more than once
			}
		}
	}

	function removePendingLoader(loader:AnyLoader)
	{
		var i = pendingQueue.length;
		while (i-- > 0)
			if (pendingQueue[i].loader == loader)
				pendingQueue.splice(i, 1);
	}
}

private typedef PendingLoader =
{
	var loader:AnyLoader;
	var priority:Int;
}
