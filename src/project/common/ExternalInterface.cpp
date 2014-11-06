#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "HttpLoader.h"

DEFINE_KIND(kHttpLoader);

//iOS --------------------------------------------------------------------------

#ifdef IPHONE

static value mloader_create(value url)
{
	HttpLoader *result = HttpLoader::create(val_string(url));
	return alloc_float(intptr_t(result));
}
DEFINE_PRIM(mloader_create, 1);

static value mloader_setUrlVariable(value handler, value key, value data)
{
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	if (result != NULL)
		result->setUrlVariable(val_string(key), val_string(data));

	return alloc_null();
}
DEFINE_PRIM(mloader_setUrlVariable, 3);

static value mloader_setHeaderField(value handler, value key, value data)
{
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	if (result != NULL)
		result->setHeader(val_string(key), val_string(data));

	return alloc_null();
}
DEFINE_PRIM(mloader_setHeaderField, 3);

static value mloader_setUrl(value handler, value url)
{
	printf("mloader_setUrl\n");
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	if (result != NULL)
		result->setUrl(val_string(url));

	return alloc_null();
}
DEFINE_PRIM(mloader_setUrl, 2);

static value mloader_configure(value handler, value method, value data)
{
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	if (result != NULL)
		result->configure(val_string(method), val_string(data));
	return alloc_null();
}
DEFINE_PRIM(mloader_configure, 3);

static value mloader_setListener(value handler, value haxeListener)
{
	AutoGCRoot *listener = new AutoGCRoot(haxeListener);
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	if (result != NULL)
		result->setListener(listener);

	return alloc_null();
}
DEFINE_PRIM(mloader_setListener, 2);

static value mloader_setErrorListener(value handler, value haxeListener)
{
	AutoGCRoot *listener = new AutoGCRoot(haxeListener);
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	if (result != NULL)
		result->setErrorListener(listener);

	return alloc_null();
}
DEFINE_PRIM(mloader_setErrorListener, 2);

static value mloader_setHttpBody(value handler, value url)
{
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	if (result != NULL)
		result->setHttpBody(val_string(url));

	return alloc_null();
}
DEFINE_PRIM(mloader_setHttpBody, 2);

extern "C" void mloader_callListener(AutoGCRoot *listener, const char* data)
{
	if(listener->get() != NULL)
	{		
		val_call1(listener->get(), alloc_string(data));
	}
}

extern "C" void mloader_callErrorListener(AutoGCRoot *listener, 
	int code, const char* data)
{
	if(listener->get() != NULL)
	{		
		val_call2(listener->get(), alloc_int(code), alloc_string(data));
	}
}

static value mloader_load(value handler)
{
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	result->load();
	return alloc_null();
}
DEFINE_PRIM(mloader_load, 1);

#endif

extern "C" void mloader_main ()
{
	val_int(0); // Fix Neko init
}
DEFINE_ENTRY_POINT (mloader_main);

extern "C" int mloader_register_prims () 
{ 
	return 0; 
}
