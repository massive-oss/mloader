package example;

import mloader.Loader;
import mloader.ImageLoader;
import mcore.exception.MissingImplementationException;

class ExampleImageLoader
{
	var loader:ImageLoader;

	public function new()
	{
		#if (js || flash || nme)
			loader = new ImageLoader(Example.BASE_DIR + "example.jpg");
			loader.loaded.add(loaded);
			loader.load();
		#else
			try
			{
				loader = new ImageLoader();
			}
			catch(e:MissingImplementationException)
			{
				trace(e.message);
			}
		#end
	}

	function loaded(event:ImageLoaderEvent)
	{
		switch (event.type)
		{
			case failed(error):
				trace(error);

			case completed:
				#if js
				js.Lib.document.body.appendChild(event.target.content);
				#elseif (flash || cpp)
				var bitmap = new flash.display.Bitmap(event.target.content);
				flash.Lib.current.addChild(bitmap);
				#end

			default:
		}
	}
}
