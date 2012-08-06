package mloader;

import mloader.Loader;
import msignal.EventSignal;

typedef XmlLoaderEvent = Event<Loader<Xml>, LoaderEvent>;

/**
The XMLLoader is an extension of the HTTPLoader. It's responsible for loading 
XML resources. If the format of the XML file is incorrect the failed signal 
will be dispatched, indicating a FormatError.
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
			loaded.dispatchType(Failed(Format(Std.string(e))));
			return;
		}
		
		loaded.dispatchType(Completed);
	}
}
