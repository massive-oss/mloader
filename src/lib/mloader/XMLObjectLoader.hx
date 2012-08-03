package mloader;

import mloader.Loader;

/**
The XMLObjectLoader loads an XML resource of a specific format. Node names are 
mapped against actual class names so that the XML resource is parsed directly 
into a typed object.
*/
class XMLObjectLoader<T> extends HTTPLoader<T>
{
	var parser:XMLObjectParser;

	/**
	@param url  the url to load the resource from
	@param parser An instance of the parser to use. If an instance is not
			passed through a new instance will be created.
	@param http optional Http instance to use for the load request
	*/
	public function new(?url:String, ?parser:XMLObjectParser, ?http:haxe.Http)
	{
		super(url, http);
		
		if (parser == null)
		{
			this.parser = new XMLObjectParser();
		}
		else
		{
			this.parser = parser;
		}
	}

	override function httpData(data:String)
	{
		var object:T = null;
		
		try
		{
			var xml = Xml.parse(data);
			object = cast parser.parse(xml);
		}
		catch (e:Dynamic)
		{
			failed.dispatch(FormatError(Std.string(e)));
			return;
		}
		
		completed.dispatch(object);
	}

	/**
	Sets default content type for POST data
	
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

	/**
	Maps an XML node to a Haxe class
	*/
	public function mapClass(nodeName:String, nodeClass:Class<Dynamic>)
	{
		parser.classMap.set(nodeName, nodeClass);
	}

	/**
	Maps an XML node to another XML node
	*/
	public function mapNode(fromNodeName:String, toNodeName:String)
	{
		parser.nodeMap.set(fromNodeName, toNodeName);
	}
}
