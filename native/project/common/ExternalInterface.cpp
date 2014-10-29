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

static value mloader_setListener(value handler, value method)
{
	AutoGCRoot *listener = new AutoGCRoot(method);

	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	result->setListener(listener);

	return alloc_null();
}
DEFINE_PRIM(mloader_setListener, 2);

extern "C" void mloader_callListener(AutoGCRoot *listener, const char* data)
{
	if(listener->get() != NULL)
	{		
		val_call1(listener->get(), alloc_string(data));
	}
}

static value mloader_load(value handler)
{
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	result->load();
	return alloc_null();
}
DEFINE_PRIM(mloader_load, 1);

static value mloader_setUrlVariable(value handler,value name, value data)
{
	HttpLoader* result = (HttpLoader*)(intptr_t)val_float (handler);
	result->setUrlVariable(val_string(name), val_string(data));
	return alloc_null();
}
DEFINE_PRIM(mloader_setUrlVariable, 3);

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
