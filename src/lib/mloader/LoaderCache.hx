package mloader;

import mloader.Loader;
import msignal.Event;

using mcore.util.IterableUtil;

/**
The LoadCache class caches any request which has it's base type of Loader. It
also stores reference to items which are currently still being loaded. 
*/
class LoaderCache
{
	var activeLoaders:Hash<ActiveLoader>;
	var duplicateLoaders:Hash<Array<ActiveLoader>>;
	var responseCache:Hash<Dynamic>;

	public function new()
	{
		activeLoaders = new Hash();
		duplicateLoaders = new Hash();
		responseCache = new Hash();
	}

	/**
	Request the LoaderCache to load a

	Initially, the load method attempts to retrieve the request from the cache. 
	If the request isn't found, then the load method checks the items currently
	being loaded for that request. If the request is neither cached nor being 
	loaded a new request is made.
	*/
	public function load(loader:AnyLoader)
	{
		if (responseCache.exists(loader.url))
		{
			completeLoader(loader);
		}
		else if (activeLoaders.exists(loader.url) && activeLoaders.get(loader.url) != loader)
		{
			addDuplicate(loader);
		}
		else
		{
			activeLoaders.set(loader.url, loader);

			loader.loaded.add(loaderLoaded);
			loader.load();
		}
	}

	inline function completeLoader(loader:AnyLoader)
	{
		var response = responseCache.get(loader.url);
		untyped loader.content = response;
		loader.loaded.event(completed);
	}

	/**
	If a Loader is requested to be loaded, and there is already an active Loader with identical url,
	then we store this Loader in a cache until the active one has completed. At that point we'll
	remove this Loader from cache and dispatch its completed event too, setting it with a copy
	of the loaded content before we do so.
	*/
	function addDuplicate(loader:AnyLoader)
	{
		var duplicates:Array<AnyLoader>;

		if (duplicateLoaders.exists(loader.url))
		{
			duplicates = duplicateLoaders.get(loader.url);

			if (duplicates.contains(loader))
				return;
		}
		else
		{
			duplicates = [];
		}

		loader.loaded.add(loaderLoaded);

		duplicates.push(loader);
		duplicateLoaders.set(loader.url, duplicates);
	}

	/**
	Called when an active loader or duplicate loader dispatches a LoaderEvent.
	*/
	function loaderLoaded(event:AnyLoaderEvent)
	{
		var loader = event.target;

		switch (event.type)
		{
			case completed: loaderCompleted(loader);
			case cancelled: loaderCancelled(loader);
			case failed(e): loaderFailed(loader, e);
			default:
		}
	}

	function loaderCompleted(loader:AnyLoader)
	{
		loader.loaded.remove(loaderLoaded);

		var activeLoader = activeLoaders.get(loader.url);
		if (activeLoader != loader)
			activeLoader.loaded.remove(loaderLoaded);

		activeLoaders.remove(loader.url);
		responseCache.set(loader.url, loader.content);

		completeDuplicates(loader);
	}

	function completeDuplicates(loader:AnyLoader)
	{
		if (duplicateLoaders.exists(loader.url))
		{
			for (duplicate in duplicateLoaders.get(loader.url))
			{
				if (duplicate != loader)
				{
					untyped duplicate.content = loader.content;
					duplicate.loaded.event(completed);
				}
			}
			duplicateLoaders.remove(loader.url);
		}
	}

	function loaderFailed(loader:AnyLoader, error:LoaderError)
	{
		loader.loaded.remove(loaderLoaded);

		var activeLoader = activeLoaders.get(loader.url);
		if (activeLoader != loader)
			activeLoader.loaded.remove(loaderLoaded);

		activeLoaders.remove(loader.url);
		responseCache.remove(loader.url);

		failDuplicates(loader);
	}

	function failDuplicates(loader:AnyLoader, error:LoaderError)
	{
		if (duplicateLoaders.exists(loader.url))
		{
			for (duplicate in duplicateLoaders.get(loader.url))
				if (loader != duplicate)
					duplicate.loaded.event(failed(error));

			duplicateLoaders.remove(loader.url);
		}
	}

	function loaderCancelled(loader:AnyLoader)
	{
		loader.loaded.remove(loaderLoaded);

		var duplicates = duplicateLoaders.get(loader.url);

		if (activeLoaders.get(loader.url) == loader)
		{
			activeLoaders.remove(loader.url);

			if (duplicates != null)
				load(duplicates.pop())
		}
		else if (duplicates != null)
		{
			duplicates.remove(loader);

			if (duplicates.length == 0)
				duplicateLoaders.remove(loader.url);
		}
	}
}

private typedef ActiveLoader =
{
	var loader:AnyLoader;
	var dependencies:Array<AnyLoader>;
	function completed(asset:Dynamic):Void;
	function failed(error:LoaderError):Void;
	function cancelled():Void;
}
