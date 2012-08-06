package mloader;

import mcore.exception.ArgumentException;
import mloader.Loader;
import msignal.Event;

using mcore.util.Strings;

typedef JSONLoaderEvent = Event<Loader<Dynamic>, LoaderEvent>;

/**
The JSONLoader is an extension of the HTTPLoader. It's responsible for loading 
JSON resources and serializing them into objects.

Example

	var loader = new JSONLoader();
	loader.completed.add(completed);
	loader.load("http://some/url/to/load");

	function completed(result:Dynamic)
	{
		trace(result.someValue)
	}
*/
class JSONLoader extends HTTPLoader<Dynamic>
{
	/**
	@param url  the url to load the resource from
	@param http optional Http instance to use for the load request
	*/
	public function new(?url:String, ?http:haxe.Http)
	{
		super(url, http);
	}

	/**
	override httpData to deserialize JSON string into an object.
	triggers FormatError if invalid JSON. 
	*/
	override function httpData(data:String)
	{
		try
		{
			var json:Dynamic = haxe.Json.parse(data);
			loaderCompleted(json);
		}
		catch (e:Dynamic)
		{
			loaded.event(failed(format(Std.string(e))));
		}
	}


	/**
	Ensures POST data is valid JSON string
	
	@param url The URI to load.
	@param data object or JSON string to pass through with the request.
	*/
	override public function send(data:Dynamic)
	{
		if (url == null)
			throw new mcore.exception.ArgumentException("No url defined for Loader");

		try
		{
			if (!Std.is(data, String))
			{
				data = haxe.Json.stringify(data);
			}

			if (!headers.exists("Content-Type"))
			{
				headers.set("Content-Type", "application/json");
			}

			super.send(data);
		}
		catch(e:Dynamic)
		{
			loaded.event(failed(format(Std.string(e))));
		}
	}
}
