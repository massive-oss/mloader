package example;

import mloader.Loader;
import mloader.SWFLoader;
import mcore.exception.MissingImplementationException;

class ExampleSWFLoader
{
	var loader:SWFLoader;

	public function new()
	{
		#if (flash || nme)
			loader = new SWFLoader(Example.BASE_DIR + "example.swf");
			loader.loaded.add(loaded);
			loader.load();
		#else
			try
			{
				loader = new SWFLoader(Example.BASE_DIR + "example.swf");
			}
			catch(e:MissingImplementationException)
			{
				trace(e.message);
			}
		#end
	}

	function loaded(event:SWFLoaderEvent)
	{
		switch (event.type)
		{
			case failed(error):
				trace(error);

			case completed:
				#if (flash || nme)
				flash.Lib.current.addChild(event.target.content);
				#end

			default:
		}
	}
}
