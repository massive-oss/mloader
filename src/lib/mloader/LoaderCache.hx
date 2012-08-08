package mloader;

import mloader.Loader;
import msignal.EventSignal;

using mcore.util.Iterables;

/**
The LoadCache class caches any request which has it's base type of Loader. It
also stores reference to items which are currently still being loaded. 
*/
class LoaderCache
{
	/**
	Loaders currently being loaded by the cache, indexed by url.
	*/
	var loadingLoaders:Hash<AnyLoader>;

	/**
	Loaders that are waiting for a loading loader to complete, indexed by url.
	*/
	var waitingLoaders:Hash<Array<AnyLoader>>;

	/**
	A cache of succefully loaded Loader.content, index by url.
	*/
	var cache:Hash<Dynamic>;

	public function new()
	{
		loadingLoaders = new Hash();
		waitingLoaders = new Hash();
		cache = new Hash();
	}

	/**
	Request the LoaderCache to load a loader.

	Initially, the load method attempts to retrieve the request from the cache. 
	If the request isn't found, then the load method checks the items currently
	being loaded for that request. If the request is neither cached nor being 
	loaded a new request is made.
	*/
	public function load(loader:AnyLoader)
	{
		if (cache.exists(loader.url))
		{
			Console.log("cached " + loader.url);
			// if the url has been cached, complete with the cached content
			untyped loader.content = cache.get(loader.url);
			untyped loader.progress = 1;
			loader.loaded.dispatchType(Completed);
		}
		else if (loadingLoaders.exists(loader.url) && loadingLoaders.get(loader.url) != loader)
		{
			Console.log("waiting " + loader.url);
			// if the url is currently loading, add the loader to the waiting hash
			addWaiting(loader);
		}
		else
		{
			Console.log("loading " + loader.url);
			// otherwise add the loader to the loading hash, and start loading
			loadingLoaders.set(loader.url, loader);
			loader.loaded.add(loaderLoaded);
			loader.load();
		}
	}

	/**
	If a Loader is requested to be loaded, and there is already an active Loader 
	with the same url, then we store this Loader in a cache until the active 
	one has completed. At that point we'll remove this Loader from cache and 
	dispatch its completed event too, setting it with a copy of the loaded 
	content before we do so.
	*/
	function addWaiting(loader:AnyLoader)
	{
		// prevents users from loading
		untyped loader.loading = true;

		var waiting:Array<AnyLoader>;

		if (waitingLoaders.exists(loader.url))
		{
			waiting = waitingLoaders.get(loader.url);
		}
		else
		{
			waiting = [];
			waitingLoaders.set(loader.url, waiting);
		}

		waiting.push(loader);
	}

	/**
	Called when an active loader or dispatches a LoaderEvent.
	*/
	function loaderLoaded(event:AnyLoaderEvent)
	{
		Console.log(event.type);
		var loader = event.target;

		switch (event.type)
		{
			case Completed: loaderCompleted(loader);
			case Cancelled: loaderCancelled(loader);
			case Failed(e): loaderFail(loader, e);
			default:
		}
	}

	function loaderCompleted(loader:AnyLoader)
	{
		loader.loaded.remove(loaderLoaded);
		loadingLoaders.remove(loader.url);
		cache.set(loader.url, loader.content);

		if (waitingLoaders.exists(loader.url))
		{
			for (waiting in waitingLoaders.get(loader.url))
			{
				// if user has cancelled loader, don't complete it
				if (!waiting.loading) continue;

				// update loader state
				untyped waiting.loading = false;
				untyped waiting.content = loader.content;
				untyped waiting.progress = 1;

				// dispatch completed
				waiting.loaded.dispatchType(Completed);
			}

			waitingLoaders.remove(loader.url);
		}
	}

	function loaderFail(loader:AnyLoader, error:LoaderError)
	{
		// remove loading loader
		loader.loaded.remove(loaderLoaded);
		loadingLoaders.remove(loader.url);

		if (waitingLoaders.exists(loader.url))
		{
			for (waiting in waitingLoaders.get(loader.url))
			{
				// if user has cancelled loader, don't fail it
				if (!waiting.loading) continue;

				// update loader state
				untyped waiting.loading = false;

				// dispatch error
				waiting.loaded.dispatchType(Failed(error));
			}

			waitingLoaders.remove(loader.url);
		}
	}

	/**
	If a loading loader is cancelled, we stop listening to it and check if there 
	are any waiting loaders for that url. If there are, we load the first one.
	*/
	function loaderCancelled(loader:AnyLoader)
	{
		// remove loading loader
		loader.loaded.remove(loaderLoaded);
		loadingLoaders.remove(loader.url);

		if (waitingLoaders.exists(loader.url))
		{
			var loader = waitingLoaders.get(loader.url).shift();
			if (loader != null)
			{
				// need to reset loading state to it will load
				untyped loader.loading = false;
				load(loader);
			}
		}
	}
}
