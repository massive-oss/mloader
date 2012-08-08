package mloader;

import mloader.Loader;
import msignal.EventSignal;

/**
Loads a single image at a defined url.

An IO error will be dispatched through the failed signal if the image fails to load.
*/
#if js

typedef ImageLoaderEvent = Event<Loader<js.Dom.Image>, LoaderEvent>;

class ImageLoader extends LoaderBase<js.Dom.Image>
{
	/**
	@param url  the url to load the resource from
	*/
	public function new(?url:String)
	{
		super(url);
	}
	
	override function loaderLoad()
	{
		content = cast js.Lib.document.createElement("img");
		content.onload = imageLoad;
		content.onerror = imageError;
		content.src = url;
	}

	override function loaderCancel():Void
	{
		content.src = "";
	}

	function imageLoad(event)
	{
		content.onload = null;
		content.onerror = null;
		loaderComplete();
	}

	function imageError(event)
	{
		content.onload = null;
		content.onerror = null;
		loaderFail(IO(Std.string(event)));
	}
}

#elseif (flash || cpp)

import flash.display.BitmapData;

typedef ImageLoaderEvent = Event<Loader<BitmapData>, LoaderEvent>;

class ImageLoader extends LoaderBase<BitmapData>
{
	var loader:flash.display.Loader;

	public function new(?url:String)
	{
		super(url);

		loader = new flash.display.Loader();

		var loaderInfo = loader.contentLoaderInfo;
		loaderInfo.addEventListener(flash.events.ProgressEvent.PROGRESS, loaderProgressed);
		loaderInfo.addEventListener(flash.events.Event.COMPLETE, loaderCompleted);
		loaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, loaderErrored);
	}

	override function loaderLoad()
	{
		loader.load(new flash.net.URLRequest(url));
	}

	override function loaderCancel()
	{
		#if !nme loader.close(); #end
	}
	
	function loaderProgressed(event)
	{
		progress = 0.0;

		if (event.bytesTotal > 0)
		{
			progress = event.bytesLoaded / event.bytesTotal;
		}

		loaded.dispatchType(Progressed);
	}

	function loaderCompleted(event)
	{
		content = untyped loader.content.bitmapData;
		loaderComplete();
	}

	function loaderErrored(event)
	{
		loaderFail(IO(Std.string(event)));
	}
}

#else

class ImageLoader extends LoaderBase<Dynamic>
{
	public function new(?url:String)
	{
		super(url);
		
		throw "mloader.ImageLoader is not implemented on this platform";
	}
}
#end
