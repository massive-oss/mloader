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
			case Completed: didComplete = true;
			case Failed(e): didFail = true;
			case Cancelled: didCancel = true;
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

	public function fail(?error:LoaderError=null)
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
