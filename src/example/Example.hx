class Example
{
	static public var BASE_DIR:String = "data/";

	public static function main() { new Example(); }

	public function new()
	{
		var queue = new example.ExampleLoaderQueue();
		return;
		var stringExample = new example.ExampleStringLoader();
		var xmlExample = new example.ExampleXMLLoader();
		var image = new example.ExampleImageLoader();
		var swf = new example.ExampleSWFLoader();
		var json = new example.ExampleJSONLoader();
	}
}
