package mloader;

import mloader.Loader;
import msignal.Event;

typedef XMLLoaderEvent = Event<Loader<Xml>, LoaderEvent>;

/**
The XMLLoader is an extension of the HTTPLoader. It's responsible for loading 
XML resources. If the format of the XML file is incorrect the failed signal 
will be dispatched, indicating a FormatError.
*/
class XMLLoader extends HTTPLoader<Xml>
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
			loaded.event(failed(format(Std.string(e))));
			return;
		}
		
		loaded.event(completed);
	}

	/**
	Sets default content type for POST data
	
	@param url The URI to load.
	@param data Xml or string to send as post data.
	*/
	override public function send(data:Dynamic)
	{
		if(!headers.exists("Content-Type"))
		{
			headers.set("Content-Type", "application/xml");
		}
		super.send(data);
	}
}
