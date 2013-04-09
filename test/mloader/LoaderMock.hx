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

package mloader;

import mloader.Loader;

class LoaderMock extends LoaderBase<String>
{
	var shouldLoad:Bool;

	public var didLoad:Bool;
	public var didCancel:Bool;
	public var didComplete:Bool;
	public var didFail:Bool;

	public function new(?url:String="foo.txt", ?shouldLoad:Bool=true)
	{
		super(url);
		this.shouldLoad = shouldLoad;
		
		didLoad = didCancel = didComplete = didFail = didCancel = false;
		loaded.addWithPriority(handler, 1);
	}

	function handler(event)
	{
		switch (event.type)
		{
			case Complete: didComplete = true;
			case Fail(_): didFail = true;
			case Cancel: didCancel = true;
			default:
		}
	}

	override function loaderLoad()
	{
		didLoad = true;
		if (shouldLoad) complete();
	}

	override function loaderCancel()
	{
		// ze goggles do nussing
	}

	public function fail(?error:LoaderErrorType=null)
	{
		if (error == null) error = IO("Mock fail.");
		loaderFail(error);
	}

	public function complete()
	{
		content = "content";
		loaderComplete();
	}
}
