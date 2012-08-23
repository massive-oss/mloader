## Overview

MLoader is a cross platform Haxe library for loading resources with utilities for queueing 
and caching requests. Supports AVM2, JavaScript, Neko and C++.

* Signal based notification of loading events and errors
* Leverages type parameters to type loaded content
* Utilities for caching and queuing loaders
* Supports local urls in Neko

> Note: MassiveLoader includes a patch to haxe.Http to enable abortable Http 
> requests. The patch is clearly documented in haxe/Http.hx

**Installation**

Install mloader from haxelib:

	haxelib install mloader

Or if you want to install the latest directly from github:

	haxelib git mloader https://github.com/massiveinteractive/mloader.git src/lib

And to point to your local fork:

	haxelib dev mloader /ABSOLUTE_PATH_TO_REPO/src/lib

## Basic Usage

You can download an more comprehensive cross platform example project 
[here](https://github.com/downloads/massiveinteractive/mloader/example.zip).

To load a string:
	
	import mloader.Loader;

	class Main
	{
		public static function main()
		{
			var loader = new mloader.StringLoader("something.txt");
			loader.loaded.add(onLoaded);
			loader.load();
		}

		static function onLoaded(event:LoaderEvent<String>)
		{
			switch (event.type)
			{
				case Complete: trace(event.target.content);
				case Fail(e): trace("Loader failed: " + e);
			}
		}
	}

You can also listen for specific events using msignal's `forType` method:
	
	loader.loaded.add(onComplete).forType(Complete);

`XmlLoader` and `JsonLoader` will attempt to parse the response:
	
	import mloader.Loader;

	class Main
	{
		public static function main()
		{
			var loader = new mloader.XmlLoader("something.xml");
			loader.loaded.add(onLoaded);
			loader.load();
		}

		static function onLoaded(event:LoaderEvent<Xml>)
		{
			switch (event.type)
			{
				case Complete:
					trace(event.target.content.firstElement());

				case Fail(e):
					switch (e)
					{
						case Format(info): trace("Could not parse Xml: " + info);
						case IO(info): trace("URL could not be reached: " + info);
						default: trace(e);
					}
			}
		}
	}

`LoaderQueue` will sequentially load a list of loaders:
	
	import mloader.Loader;
	import mloader.LoaderQueue;
	import mloader.ImageLoader;
	import mloader.JsonLoader;

	class Main
	{
		public static function main()
		{
			var queue = new LoaderQueue();
			queue.maxLoading = 2; // max concurrent
			queue.ignoreFailures = false; // carry on regardless
			queue.loaded.addOnce(queueComplete).forType(Complete);

			var json = new JsonLoader("data.json");
			json.loaded.addOnce(jsonComplete).forType(Complete);

			queue.add(new ImageLoader("image-01.jpg"));
			queue.add(new ImageLoader("image-02.jpg"));
			queue.add(new ImageLoader("image-03.jpg"));
			queue.add(new ImageLoader("image-04.jpg"));
			queue.addWithPriority(jsonLoader, 1); // load first

			// start the queue
			queue.load();
		}
	}

	function queueComplete(event:LoaderEvent<Dynamic>)
	{
		trace("LoaderQueue completed!");
	}

	function jsonComplete(event:LoaderEvent<Dynamic>)
	{
		trace("JSON data loaded " + Std.string(event.target.content));
	}

## Documentation

The API documentation is available on the [haxelib project page](http://lib.haxe.org/d/mloader).

Or you can just read through the source ;)

## How to contribute

If you find a bug, [report it](https://github.com/massiveinteractive/mloader/issues).

If you want to help, [fork it](https://github.com/massiveinteractive/mloader/fork_select).

If you want to make sure it works, install [munit](https://github.com/massiveinteractive/MassiveUnit) 
so you can run the test suite from the project root:

	haxelib run munit test -js -as3 -neko

## Credits

This project is brought to you by [David](https://github.com/DavidPeek) and [Mike](https://github.com/mikestead) 
from [Massive Interactive](http://massiveinteractive.com)
