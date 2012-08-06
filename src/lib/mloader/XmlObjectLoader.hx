package mloader;

import mloader.Loader;

/**
The XmlObjectLoader loads an Xml resource of a specific format. Node names are 
mapped against actual class names so that the Xml resource is parsed directly 
into a typed object.
*/
class XmlObjectLoader<T> extends HttpLoader<T>
{
	/**
	The XmlObjectParser used to parse responses into objects.
	*/
	var parser:XmlObjectParser;

	/**
	@param url  the url to load the resource from
	@param parser An instance of the parser to use. If an instance is not
			passed through a new instance will be created.
	@param http optional Http instance to use for the load request
	*/
	public function new(?url:String, ?parser:XmlObjectParser, ?http:haxe.Http)
	{
		super(url, http);
		
		if (parser == null)
		{
			this.parser = new XmlObjectParser();
		}
		else
		{
			this.parser = parser;
		}
	}

	override function httpData(data:String)
	{
		try
		{
			var xml = Xml.parse(data);
			content = cast parser.parse(xml);
		}
		catch (e:Dynamic)
		{
			loaderFail(Format(Std.string(e)));
			return;
		}
		
		loaderComplete();
	}

	/**
	Maps an Xml node to a class.
	*/
	public function mapClass(nodeName:String, nodeClass:Class<Dynamic>)
	{
		parser.classMap.set(nodeName, nodeClass);
	}

	/**
	Maps an Xml node to another Xml node.
	*/
	public function mapNode(fromNodeName:String, toNodeName:String)
	{
		parser.nodeMap.set(fromNodeName, toNodeName);
	}
}
