## 2.2.4

- ImageLoader: Fixed issue where cached images were not always triggering onload.

## 2.2.3

- ImageLoader now nullifies listeners on loaderCancel
- Major version bump of mtask to 3.x

## 2.2.2

- Allow opt-out of anonymous cross origin for images

## 2.2.1

- ImageLoader works with openfl html target
- Identify valid JSON strings and fix Android Content-type headers
- Apply URL space encoding fix to C++ targets
- Simplify conditional logic for openFL targets
- Flash: added LoaderContext.checkPolicyFile to ImageLoader request
- Create a typedef for the image type to be loaded in ImageLoader
- For haxe >= 3.1 use the haxe Http class as it has cancel() function

## 2.2.0

- Update ImageLoader.hx
- Set HttpLoader.content to http.responseData onError if applicable.
- Adds support for openfl

1.0.0 Initial release

1.1.0 NME support, custom data parsing hooks
* Added support for async data loading in NME (using URLLoader instead of 
  haxe.Http)
* added optional parseData methods for XmlLoader and JsonLoader

1.2.1 Supporting the loading of images over https using ImageLoader.

2.0.0 Removed haxe.Http, added support for Haxe 3
* Breaking change: removed haxe.Http override because it was a terrible idea. 
  Sorry, but better now while you're upgrading to Haxe 3. To pass in an Http 
  instance you will now need to use mloader.Http instead (which subclasses 
  haxe.Http and adds the ability to cancel requests to flash9/js). In the 
  future we might override/add other things.

2.0.1 Fixed runtime exception in mloader.Http under flash.

2.0.2 Added haxelib.json.

2.1.0 Support the setting of a custom image element on ImageLoader uder js.
2.1.1 Updated msignal dependency with priority fix that was failing test
