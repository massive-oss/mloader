package mloader;

import mloader.Loader;
import msignal.Event;

typedef StringLoaderEvent = Event<Loader<String>, LoaderEvent>;

/**
A loader that loads a string over HTTP.
*/
class StringLoader extends HTTPLoader<String>
{
	/**
	@param url  the url to load the resource from
	@param http optional Http instance to use for the load request
	*/
	public function new(?url:String, ?http:haxe.Http)
	{
		super(url, http);
	}
}
