package mloader;

#if (js && !(nme || openfl))

	#if haxe3
	typedef LoadableImage = js.html.ImageElement;
	#else
	typedef LoadableImage = js.Dom.Image;
	#end

#elseif (flash || nme || openfl)

	typedef LoadableImage = flash.display.BitmapData;

#else

	typedef LoadableImage = Dynamic;

#end
