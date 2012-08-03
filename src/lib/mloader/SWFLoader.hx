package mloader;

import mloader.Loader;
import msignal.Event;

/**
The SWFLoader class loads an SWF file. It also raises an IO error if the
SWF file fails to load.
*/

#if flash
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.ApplicationDomain;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;

typedef FlashLoader = flash.display.Loader;
typedef FlashEvent = flash.events.Event;

typedef SWFLoaderEvent = Event<Loader<FlashLoader>, LoaderEvent>;

class SWFLoader extends LoaderBase<FlashLoader>
{
	/**
	The Loader object used to load the SWF file
	*/
	public var loader:FlashLoader;

	/**
	@param url  the url to load the resource from
	*/
	public function new(?url)
	{
		super(url);
		
		loader = new flash.display.Loader();

		var loaderInfo = loader.contentLoaderInfo;
		loaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
		loaderInfo.addEventListener(FlashEvent.COMPLETE, loadComplete);
		loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
	}
	
	/**
	Loads the SWF file. 

	@param url The url of the flash file to load.
	*/
	override public function load()
	{
		super.load();
		loader.load(new URLRequest(url), new LoaderContext(true, ApplicationDomain.currentDomain));
	}

	/**
	Cancels a request to load an SWF file. Dispatches the cancelled event when 
	called.
	*/
	override public function cancel()
	{
		loader.close();
		loaded.event(cancelled);
	}
	
	function loadProgress(event)
	{
		progress = 0.0;

		if (event.bytesTotal > 0)
		{
			progress = event.bytesLoaded / event.bytesTotal;
		}

		loaded.event(progressed);
	}

	function loadComplete(event)
	{
		content = loader;
		loaded.event(completed);
	}

	function loadError(event)
	{
		loaded.event(failed(io(Std.string(event))));
	}
}

#else
import mcore.exception.MissingImplementationException;

typedef SWFLoaderEvent = Event<SWFLoader, LoaderEvent>;

class SWFLoader extends LoaderBase<Dynamic>
{
	public function new(?url:String)
	{
		super(url);
		throw new mcore.exception.UnsupportedPlatformException("mloader.SWFLoader is not implemented on this platform");
	}
}

#end
