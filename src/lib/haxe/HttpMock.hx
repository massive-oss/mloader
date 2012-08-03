package haxe;

@IgnoreCover
class HttpMock extends Http
{
	public var publicHeaders:Hash<String>;

	var responders:Hash<HttpResponder>;
	
	public function new(url:String)
	{
		super(url);
		responders = new Hash<HttpResponder>();
		publicHeaders = headers;
	}

	override public function request(post:Bool)
	{
		var responder = if (responders.exists(url)) responders.get(url);
		else new HttpResponder().with(Error("Http Error #404"));//.afterDelay(0);

		if (responder.delay == 0)
		{
			respond(responder.response);
		}
		else
		{
			#if neko
				respond(responder.response);
			#else
				haxe.Timer.delay(callback(respond, responder.response), responder.delay);
			#end
		}
	}

	function respond(type:HttpResponse)
	{
		switch (type)
		{
			case Exception(message):
				throw message;
			case Data(data):
				if (onData != null) onData(data);
			case Status(status):
				if (onStatus != null) onStatus(status);
			case Error(error):
				if (onError != null) onError(error);
		}
	}

	public function getPostData():String
	{
		return postData;
	}

	public function respondTo(url:String):HttpResponder
	{
		var responder = new HttpResponder();
		responders.set(url, responder);
		return responder;
	}
}

class HttpResponder
{
	public var delay(default, null):Int;
	public var response(default, null):HttpResponse;

	public function new()
	{
		delay = 0;
		response = Data("");
	}

	public function afterDelay(delay:Int):HttpResponder
	{
		this.delay = delay;
		return this;
	}

	public function with(response:HttpResponse):HttpResponder
	{
		this.response = response;
		return this;
	}
}

enum HttpResponse
{
	Data(data:String);
	Status(status:Int);
	Error(error:String);
	Exception(message:String);
}
