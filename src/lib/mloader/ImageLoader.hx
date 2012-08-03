package mloader;

import mloader.Loader;
import msignal.Event;

/**
Loads a single image at a defined url.

An IO error will be dispatched through the failed signal if the image fails to load.
*/
#if js

typedef ImageLoaderEvent = Event<Loader<js.Dom.Image>, LoaderEvent>;

class ImageLoader extends LoaderBase<js.Dom.Image>
{
	/**
	The dom object used to load an image.
	*/
	public var image:js.Dom.Image;

	/**
	@param url  the url to load the resource from
	*/
	public function new(?url:String)
	{
		super(url);
		image = cast js.Lib.document.createElement("img");
	}
	
	/**
	Loads an image with the supplied url.
	*/
	override public function load()
	{
		super.load();

		image.onload = imageLoad;
		image.onerror = imageError;
		image.src = this.url;

		loaderStarted();
	}

	/**
	Cancels the request to load an image. Dispatches the cancelled 
	signal when called.
	*/
	override public function cancel()
	{
		image.src = "";
		loaded.event(cancelled);
	}

	function imageLoad(event)
	{
		image.onload = null;
		image.onerror = null;
		loaderCompleted(image);
	}

	function imageError(event)
	{
		image.onload = null;
		image.onerror = null;
		loaded.event(failed(io(Std.string(event))));
	}
}

#elseif (flash || cpp)

import mloader.Loader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;

typedef ImageLoaderEvent = Event<Loader<BitmapData>, LoaderEvent>;

class ImageLoader extends LoaderBase<BitmapData>
{
	/**
	The Loader object used to load an image.
	*/
	public var loader:flash.display.Loader;

	public function new(?url:String)
	{
		super(url);

		loader = new flash.display.Loader();

		var loaderInfo = loader.contentLoaderInfo;
		loaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
		loaderInfo.addEventListener(flash.events.Event.COMPLETE, loadComplete);
		loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
	}

	/**
	Loads an image with the supplied url.
	
	@param url The URI to load.
	*/
	override public function load()
	{
		super.load();
		loader.load(new flash.net.URLRequest(url));
		loaderStarted();
	}

	/**
	Cancels the request to load an image. Dispatches the cancelled signal when called.
	*/
	override public function cancel()
	{
		#if !nme loader.close(); #end
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
		var bitmap:Bitmap = cast loader.content;
		loaderCompleted(bitmap.bitmapData);
	}

	function loadError(event)
	{
		loaded.event(failed(io(Std.string(event))));
	}
}

#else
import mcore.exception.MissingImplementationException;

typedef ImageLoaderEvent = Event<Loader<Dynamic>, LoaderEvent>;

class ImageLoader extends LoaderBase<Dynamic>
{
	public function new(?url:String)
	{
		super(url);
		throw new MissingImplementationException("mloader.ImageLoader is not implemented on this platform");
	}
}
#end
