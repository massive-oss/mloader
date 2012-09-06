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
import mloader.ImageLoader;

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
			catch(e:Dynamic)
			{
				trace(e);
			}
		#end
	}

	function loaded(event)
	{
		switch (event.type)
		{
			case Fail(error):
				trace(error);

			case Complete:
				#if js
				js.Lib.document.body.appendChild(event.target.content);
				#elseif (flash || nme)
				var bitmap = new flash.display.Bitmap(event.target.content);
				flash.Lib.current.addChild(bitmap);
				#end

			default:
		}
	}
}
