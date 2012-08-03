package example;

import mloader.LoaderQueue;

class ExampleLoaderQueue
{
	public function new()
	{
		var queue = new LoaderQueue();
		queue.ignoreFailures = false;

		#if (js || flash || nme)
		queue.add(new mloader.ImageLoader(Example.BASE_DIR + "example.jpg"));
		#end
		queue.add(new mloader.JSONLoader(Example.BASE_DIR + "example.json"));
		queue.add(new mloader.StringLoader(Example.BASE_DIR + "example.txt"));
		#if (flash || nme)
		queue.add(new mloader.SWFLoader(Example.BASE_DIR + "example.swf"));
		#end
		queue.add(new mloader.XMLLoader(Example.BASE_DIR + "example.xmls"));
		queue.loaded.add(queueLoaded);
		queue.load();
	}

	function queueLoaded(event:LoaderQueueEvent)
	{
		switch (event.type)
		{
			case progressed:
				trace(event.type + ":" + event.target.progress);

			default:
				trace(event.type);
		}
	}
}
