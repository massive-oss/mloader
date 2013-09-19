/*
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

package example;

import mloader.Loader;
import mloader.LoaderQueue;

class ExampleLoaderQueue
{
	public function new()
	{
		var queue = new LoaderQueue();
		queue.ignoreFailures = false;

		#if (js || flash || nme || openfl)
		queue.add(new mloader.ImageLoader(Example.BASE_DIR + "example.jpg"));
		#end
		queue.add(new mloader.JsonLoader(Example.BASE_DIR + "example.json"));
		queue.add(new mloader.StringLoader(Example.BASE_DIR + "example.txt"));
		#if (flash || nme || openfl)
		queue.add(new mloader.SwfLoader(Example.BASE_DIR + "example.swf"));
		#end
		queue.add(new mloader.XmlLoader(Example.BASE_DIR + "example.xmls"));
		queue.loaded.add(queueLoaded);
		queue.load();
	}

	function queueLoaded(event:Dynamic)
	{
		switch (event.type)
		{
			case Progress:
				trace(event.type + ":" + event.target.progress);

			default:
				trace(event.type);
		}
	}
}
