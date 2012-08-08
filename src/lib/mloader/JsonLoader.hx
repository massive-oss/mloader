package mloader;

import mcore.exception.ArgumentException;
import mloader.Loader;
import msignal.EventSignal;

using mcore.util.Strings;

typedef JsonLoaderEvent = Event<Loader<Dynamic>, LoaderEvent>;

/**
The JsonLoader is an extension of the HttpLoader. It's responsible for loading 
Json resources.
*/
class JsonLoader<T> extends HttpLoader<T>
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
			content = haxe.Json.parse(data);
		}
		catch (e:Dynamic)
		{
			loaderFail(Format(Std.string(e)));
		}

		loaderComplete();
	}
}
