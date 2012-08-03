Loaders
====================

Unified API for loading external data sources (String, XML, Image, JSON) over HTTP and from the local file system.

Features:

* Notifies observers when loading progresses, completes or fails via Signals.
* Leverages generics <T> to formalise the return type of the completed signal. 
* Utilities for caching and queuing multiple loaders of a similar type


Basic example using StringLoader

	var loader = new StringLoader("http://www.example.org/config.txt");
	loader.completed.addOnce(loaderComplete);
	loader.load();

	...

	function loaderComplete(result:String)
	{
		trace(result);
	}


Example of XML loading

	var loader = new XMLLoader("http://www.example.org/config.xml");
	loader.completed.addOnce(loaderComplete);
	loader.load();

	...

	function loaderComplete(result:Xml)
	{
		trace(result);
	}

Example of loading through the LoadQueue

	var jsonLoader = new JSONLoader("http://www.example.org/data.json");
	jsonLoader.completed.addOnce(dataLoaded);

	var queue = new LoadQueue();
	queue.maxLoading = 2;
	queue.ignoreFailures = false;

	queue.completed.addOnce(queueComplete);
	queue.failed.addOnce(queueFailed);

	queue.add(new ImageLoader("http://www.example.org/img/01.jpg"));
	queue.add(new ImageLoader("http://www.example.org/img/02.jpg"));
	queue.add(new ImageLoader("http://www.example.org/img/03.jpg"));
	queue.add(new ImageLoader("http://www.example.org/img/04.jpg"));
	queue.addWithPriority(jsonLoader, 1);

	queue.load();

	function queueComplete(queue:Loader)
	{
		trace("load queue completed");
	}

	function queueFailed(error:LoadError)
	{
		trace("load queue failed " + error);
	}

	function dataLoaded(data:Dynamic)
	{
		trace("JSON data loaded " + Std.string(data));
	}
