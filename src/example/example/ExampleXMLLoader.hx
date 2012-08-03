package example;

import mloader.Loader;
import mloader.XMLLoader;

class ExampleXMLLoader
{
	var loader:XMLLoader;

	public function new()
	{
		loader = new XMLLoader(Example.BASE_DIR + "example.xml");
		loader.loaded.add(loaded);
		loader.load();
	}

	function loaded(event:XMLLoaderEvent)
	{
		switch (event.type)
		{
			case failed(error):
				trace(error);

			case completed:
				trace(event.target.content);
				loader.url = Example.BASE_DIR + "exampleInvalid.xml";
				loader.load();

			default:
		}
	}
}