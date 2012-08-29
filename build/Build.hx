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

import mtask.target.HaxeLib;
import mtask.target.Neko;
import mtask.target.Directory;
import mtask.target.Web;
import mtask.target.Haxe;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@target function haxelib(target:HaxeLib)
	{
		target.url = "http://github.com/massiveinteractive/mloader";
		target.description = "A cross platform Haxe library for loading resources with utilities for queueing and caching requests. Supports AVM2, JavaScript, Neko and C++.";
		target.versionDescription = "Alpha release, API subject to change.";

		target.addTag("cross");
		target.addTag("utility");
		target.addTag("massive");
		target.addDependency("msignal");

		target.afterCompile = function()
		{
			cp("src/*", target.path);
			cmd("haxe", ["-cp", "src", "-swf", target.path + "/haxedoc.swf", 
				"--no-output", "-lib", "msignal", "-xml", target.path + "/haxedoc.xml",
				"mloader.Loader",
				"mloader.StringLoader", 
				"mloader.XmlLoader", 
				"mloader.JsonLoader", 
				"mloader.ImageLoader", 
				"mloader.SwfLoader", 
				"mloader.XmlObjectLoader", 
				"mloader.LoaderQueue", 
				"mloader.LoaderCache", 
				"mloader.HttpMock"
				]);
			Haxe.filterXml(target.path + "/haxedoc.xml", ["mloader"]);
		}
	}

	@target function example(target:Directory)
	{
		target.afterBuild = function()
		{
			cp("example/*", target.path);
			zip(target.path);
		}
	}

	@task function release()
	{
		invoke("clean");
		invoke("test");
		invoke("build example");
		invoke("build haxelib");
	}

	@task function test()
	{
		cmd("haxelib", ["run", "munit", "test", "-coverage"]);
	}
}
