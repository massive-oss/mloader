package mloader;

import msignal.Signal;
import msignal.EventSignal;
import mloader.Loader;

/**
The LoaderBase class is an abstract implementation of the Loader class.  
*/
class LoaderBase<T> implements Loader<T>
{
	/**
	The current url of the loader.
	*/
	public var url(default, set_url):String;

	/**
	If the url changes while loading, cancel the request.
	*/
	function set_url(value:String):String
	{
		if (value == url) return url;
		if (loading) cancel();
		return url = value;
	}

	/**
	The loaded content, only available after completed is dispatched.
	*/
	public var content(default, null):Null<T>;

	/**
	The current state of the loader: true if content is currently being loaded, 
	false if the loader has completed, failed, or not yet started.
	*/
	public var loading(default, null):Bool;

	/**
	The percentage of loading complete. Between 0 and 1.
	*/
	public var progress(default, null):Float;

	/**
	A signal dispatched when loading status changes. See LoaderEvent.
	*/
	public var loaded(default, null):EventSignal<Loader<T>, LoaderEvent>;

	/**
	@param url  the url to load the resource from
	*/
	public function new(?url:String)
	{
		this.loaded = new EventSignal<Loader<T>, LoaderEvent>(this);
		this.url = url;

		// set initial state
		progress = 0;
		loading = false;
	}

	/**
	Starts a load operation from the loaders url.
	
	If the loader is loading, the previous operation is cancelled before the new 
	operation starts. If no url has been set, and exception is thrown.
	*/
	public function load():Void
	{
		// if currently loading, cancel
		if (loading) cancel();

		// if no url, throw exception
		if (url == null) throw "No url defined for Loader";

		// update state
		loading = true;

		// dispatch started
		loaded.dispatchType(Started);
		
		// call implementation
		loaderLoad();
	}

	/**
	Cancels a load operation currently in progress for this loader instance.

	If the loader is not loading, this method has no effect. Progress is reset 
	to zero and a `cancelled` event is dispatched.
	*/
	public function cancel():Void
	{
		// if not loading, return
		if (!loading) return;

		// call implementation
		loaderCancel();

		// reset state
		progress = 0;
		content = null;
		loading = false;

		// dispatch event
		loaded.dispatchType(Cancelled);
	}

	//-------------------------------------------------------------------------- private

	/**
	The abstract load implementation.
	*/
	function loaderLoad()
	{
		throw "missing implementation";
	}

	/**
	The abstract cancel implementation.
	*/
	function loaderCancel():Void
	{
		throw "missing implementation";
	}
	
	function loaderComplete()
	{
		if (!loading) return;

		// update progress
		progress = 1;

		// update state
		loading = false;
		
		// dispatch event
		loaded.dispatchType(Completed);
	}

	function loaderFail(error:LoaderError)
	{
		if (!loading) return;
		loaded.dispatchType(Failed(error));
	}
}
