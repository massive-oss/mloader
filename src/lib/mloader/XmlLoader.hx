package mloader;

import mloader.Loader;
import msignal.EventSignal;

typedef XmlLoaderEvent = Event<Loader<Xml>, LoaderEvent>;

/**
The XmlLoader is an extension of the HttpLoader. It's responsible for loading 
Xml resources. If the format of the Xml file is incorrect the a failed event is 
dispatched indicting the nature of the fault.
*/
class XmlLoader extends HttpLoader<Xml>
{
	/**
	@param url  the url to load the resource from
	@param http optional Http instance to use for the load request
	*/
	public function new(?url:String, ?http:haxe.Http)
	{
		super(url, http);
	}

	override function httpData(data:String)
	{
		try
		{
			content = Xml.parse(data);
		}
		catch (e:Dynamic)
		{
			loaderFail(Format(Std.string(e)));
			return;
		}
		
		loaderComplete();
	}
}
