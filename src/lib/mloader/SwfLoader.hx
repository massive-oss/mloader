package mloader;

#if flash

import mloader.Loader;
import msignal.EventSignal;

typedef SwfLoaderEvent = Event<Loader<flash.display.Loader>, LoaderEvent>;

/**
The SWFLoader class loads an SWF file. It also raises an IO error if the
SWF file fails to load.
*/
class SwfLoader extends LoaderBase<flash.display.DisplayObject>
{
	var loader:flash.display.Loader;

	public function new(?url)
	{
		super(url);
		
		loader = new flash.display.Loader();

		var loaderInfo = loader.contentLoaderInfo;
		loaderInfo.addEventListener(flash.events.ProgressEvent.PROGRESS, loadProgress);
		loaderInfo.addEventListener(flash.events.Event.COMPLETE, loadComplete);
		loaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, loadError);
	}
	
	override function loaderLoad()
	{
		loader.load(new flash.net.URLRequest(url), 
			new flash.system.LoaderContext(true, flash.system.ApplicationDomain.currentDomain));
	}

	override public function loaderCancel()
	{
		loader.close();
	}
	
	function loadProgress(event)
	{
		progress = 0.0;

		if (event.bytesTotal > 0)
		{
			progress = event.bytesLoaded / event.bytesTotal;
		}

		loaded.dispatchType(Progressed);
	}

	function loadComplete(event)
	{
		content = loader.content;
		loaderComplete();
	}

	function loadError(event)
	{
		loaderFail(IO(Std.string(event)));
	}
}

#else

class SwfLoader extends LoaderBase<Dynamic>
{
	public function new(?url:String)
	{
		super(url);

		throw "mloader.SWFLoader is not implemented on this platform";
	}
}

#end
