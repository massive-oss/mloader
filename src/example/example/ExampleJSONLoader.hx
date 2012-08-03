package example;

import mloader.Loader;
import mloader.JSONLoader;

class ExampleJSONLoader
{
	var loader:JSONLoader;

	public function new()
	{
		loader = new JSONLoader(Example.BASE_DIR + "example.json");
		loader.loaded.add(loaded);
		loader.load();
	}

	function loaded(event:JSONLoaderEvent)
	{
		switch (event.type)
		{
			case failed(error):
				trace(error);

			case completed:
				trace(event.target.content);

				loader.url = Example.BASE_DIR + "exampleInvalid.json";
				loader.load();

			default:
		}
	}
}
