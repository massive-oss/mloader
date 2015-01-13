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

#define Gc() \
{ \
	int top = 0; \
	gc_set_top_of_stack(&top,true); \
}

#define NotNull(a) \
{ \
	if (a == NULL) \
		return; \
}

#define IfNullReturn(a, b) \
{ \
	if (a == NULL)\
		return b; \
}

static value mloader_create(value url)
{
	const char *taskId = HttpLoader::create(val_string(url));
	return alloc_string(taskId);
}
DEFINE_PRIM(mloader_create, 1);

static value mloader_setUrlVariable(value taskId, value key, value data)
{
	IfNullReturn(taskId, alloc_null());
	IfNullReturn(key, alloc_null());
	IfNullReturn(data, alloc_null());
	HttpLoader::setVariable(val_string(taskId), val_string(key), val_string(data));
	return alloc_null();
}
DEFINE_PRIM(mloader_setUrlVariable, 3);

static value mloader_setHeaderField(value taskId, value key, value data)
{
	IfNullReturn(key, alloc_null());
	IfNullReturn(data, alloc_null());
	HttpLoader::setHeader(val_string(taskId), val_string(key), val_string(data));
	return alloc_null();
}
DEFINE_PRIM(mloader_setHeaderField, 3);

static value mloader_setHttpBody(value taskId, value data)
{
	IfNullReturn(taskId, alloc_null());
	IfNullReturn(data, alloc_null());
	HttpLoader::setBody(val_string(taskId), val_string(data));
	return alloc_null();
}
DEFINE_PRIM(mloader_setHttpBody, 2);

static value mloader_setUrl(value taskId, value url)
{
	IfNullReturn(taskId, alloc_null());
	IfNullReturn(url, alloc_null());
	HttpLoader::setUrl(val_string(taskId), val_string(url));
	return alloc_null();
}
DEFINE_PRIM(mloader_setUrl, 2);

static value mloader_configure(value taskId, value method, value data)
{
	IfNullReturn(taskId, alloc_null());
	IfNullReturn(method, alloc_null());
	HttpLoader::configure(val_string(taskId), val_string(method), val_string(data));
	return alloc_null();
}
DEFINE_PRIM(mloader_configure, 3);

static value mloader_setListener(value taskId, value haxeListener)
{
	IfNullReturn(haxeListener, alloc_null());
	AutoGCRoot *listener = new AutoGCRoot(haxeListener);
	HttpLoader::setSuccessListener(val_string(taskId), listener);
	return alloc_null();
}
DEFINE_PRIM(mloader_setListener, 2);

static value mloader_close(value taskId)
{
	IfNullReturn(taskId, alloc_null());
	HttpLoader::close(val_string(taskId));
	return alloc_null();	
}

static value mloader_setErrorListener(value taskId, value haxeListener)
{
	IfNullReturn(haxeListener, alloc_null());
	AutoGCRoot *listener = new AutoGCRoot(haxeListener);
	HttpLoader::setFailureListener(val_string(taskId), listener);
	return alloc_null();
}
DEFINE_PRIM(mloader_setErrorListener, 2);

static value mloader_load(value taskId)
{
	IfNullReturn(taskId, alloc_null());
	HttpLoader::load(val_string(taskId));
	return alloc_null();
}
DEFINE_PRIM(mloader_load, 1);

extern "C" void mloader_callListener(AutoGCRoot *listener, const char* data)
{
	Gc();
	NotNull(listener);
	NotNull(listener->get());
	NotNull(data);
	val_call1(listener->get(), alloc_string(data));
}

extern "C" void mloader_callErrorListener(AutoGCRoot *listener, 
	int code, const char* data)
{
	Gc();
	NotNull(listener);
	NotNull(listener->get());
	NotNull(data);
	val_call2(listener->get(), alloc_int(code), alloc_string(data));
}

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
