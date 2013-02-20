In order to get this working in your project you'll need to drop the nme.extension.android.HttpLoader class 
into your NME Android extension and then recompile it.

Once you've done that the mloader.NativeHttpLoader should be plugged into all the concrete HttpLoaders 
(JsonLoader, StringLoader etc) so you'll get native background loading under Android. Other targets 
will use the usual mloader.HttpLoader.
