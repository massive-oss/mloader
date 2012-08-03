package mloader;

import msignal.Signal;
import msignal.Event;
import msignal.EventSignal;

/**
A convenience type indicating a loader of any type.
*/
typedef AnyLoader = Loader<Dynamic>;

/**
A convenience type indicating an event from a loader of any type.
*/
typedef AnyLoaderEvent = Event<AnyLoader, LoaderEvent>;

/**
The Loader class defines an API for loading url's. Loaders dispatch events 
when their loading state changes.
*/
interface Loader<T>
{
	/**
	The url to load the resource from.
	*/
	var url(default, set_url):String;

	/**
	The percentage of loading complete. Between 0 and 1.
	*/
	var progress(default, null):Float;

	/**
	The loaded content, only available after completed is dispatched.
	*/
	var content(default, null):Null<T>;

	/**
	The current state of the loader: true if it is loading, false if it has 
	completed, failed, or not started.
	*/
	var loading(default, null):Bool;

	/**
	A signal dispatched when loading status changes. See LoaderEvent.
	*/
	var loaded(default, null):EventSignal<Loader<T>, LoaderEvent>;
	
	/**
	Starts a load operation from the loaders url.
	
	If the loader is loading, the previous operation is cancelled before the new 
	operation starts. If no url has been set, and exception is thrown.
	*/
	function load():Void;

	/**
	Cancels a load operation currently in progress for this loader instance.

	If the loader is not loading, this method has no effect. Progress is reset 
	to zero and a `cancelled` event is dispatched.
	*/
	function cancel():Void;
}

/**
Events indicating changes in the state of the loader.
*/
enum LoaderEvent
{
	/**
	Dispatched when the loading operation commences.
	*/
	started;

	/**
	Dispatched when the loading operation is cancelled before completion.
	*/
	cancelled;

	/**
	Dispatched when the loading operation progresses.
	*/
	progressed;

	/**
	Dispatched when the loading operation completes.
	*/
	completed;

	/**
	Dispatched when the loading operation fails due to an error.
	*/
	failed(error:LoaderError);
}

enum LoaderError
{
	/**
	A fatal error terminates the download.
	*/
	io(info:String);

	/**
	An error indicating the loader attempted to perform an insecure operation. 
	The definition of insecure differs between platforms, but generally 
	indicates an attempt to load a resource outside of the security sandbox.
	*/
	security(info:String);

	/**
	An error indicating the loaded resource was in an unexpected format.
	*/
	format(info:String);

	/**
	An error that indicates the load operation failed, but properly formatted 
	data was received. For example: a service might return a non 200 HTTP 
	status, but also data indicating the nature of the failiure.
	*/
	data(info:String, data:String);
}
