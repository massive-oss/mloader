MassiveLoader
====================

Unified API for loading external data sources (Strings, Xml, Images, Json) over 
HTTP and from the local file system.

Features:

* Notifies observers when loading progresses, completes or fails via a signal.
* Leverages type parameters to type loaded content.
* Utilities for caching and queuing multiple loaders of a similar type

> Warning: MassiveLoader patches haxe.Http with a minor change to enable 
> abortable XmlHttpRequests. The patch is clearly documented in haxe/Http.hx

Basic example using StringLoader
	
	import mloader.Loader;

	...

	var loader = new mloader.StringLoader("http://www.example.org/config.txt");
	loader.loaded.addOnce(loaderComplete).forType(Completed);
	loader.load();

	...

	function loaderComplete(event:LoaderEvent<String>)
	{
		trace(event.target.content);
	}


Example of Xml loading
	
	var loader = new mloader.XmlLoader("http://www.example.org/config.xml");
	loader.loaded.addOnce(loaderComplete).forType(Completed);
	loader.load();

	...

	function loaderComplete(event:LoaderEvent<Xml>)
	{
		trace(result);
	}

Example of loading through the LoaderQueue

	var jsonLoader = new JsonLoader("http://www.example.org/data.json");
	jsonLoader.loaded.addOnce(dataLoaded).forType(Completed);

	var queue = new LoaderQueue();
	queue.maxLoading = 2;
	queue.ignoreFailures = false;

	queue.loaded.addOnce(queueComplete).forType(Completed);
	queue.loaded.addOnce(queueFailed).forType(Failed);

	queue.add(new ImageLoader("http://www.example.org/img/01.jpg"));
	queue.add(new ImageLoader("http://www.example.org/img/02.jpg"));
	queue.add(new ImageLoader("http://www.example.org/img/03.jpg"));
	queue.add(new ImageLoader("http://www.example.org/img/04.jpg"));
	queue.addWithPriority(jsonLoader, 1);

	queue.load();

	function queueComplete(event:LoaderEvent<Dynamic>)
	{
		trace("load queue completed");
	}

	function queueFailed(event:LoaderEvent<Dynamic>)
	{
		trace("load queue failed " + event.type);
	}

	function dataLoaded(event:LoaderEvent<Dynamic>)
	{
		trace("JSON data loaded " + Std.string(data));
	}
