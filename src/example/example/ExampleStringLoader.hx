package example;

import mloader.Loader;
import mloader.StringLoader;

class ExampleStringLoader
{
	var loader:StringLoader;

	public function new()
	{
		loader = new StringLoader(Example.BASE_DIR + "example.txt");
		loader.loaded.add(loaded);
		loader.load();
	}

	function loaded(event:StringLoaderEvent)
	{
		switch (event.type)
		{
			case failed(error):
				trace(error);

			case completed:
				trace(event.target.content);

				loader.url = Example.BASE_DIR + "not_a_real_url.txt";
				loader.load();

			default:
		}
	}
}
