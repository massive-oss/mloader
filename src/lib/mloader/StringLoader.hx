package mloader;

import mloader.Loader;
import msignal.EventSignal;

typedef StringLoaderEvent = Event<Loader<String>, LoaderEvent>;

/**
A loader that loads a string over Http.
*/
class StringLoader extends HttpLoader<String>
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
