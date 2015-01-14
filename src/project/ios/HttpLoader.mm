#import <UIKit/UIApplication.h>
#import <UIKit/UIKit.h>
#import "NativeHttpLoader.h"

#include "HttpLoader.h"
#include "AFNetworking.h"
#include "MassiveUtil.h"
#include <map>

extern "C"
{
	void mloader_callListener(AutoGCRoot *listener, const char* data);
	void mloader_callErrorListener(AutoGCRoot *listener, 
		int code, const char* data);
}

NSMutableDictionary *variables;
static NSMutableDictionary *map = [[NSMutableDictionary alloc] init];

AutoGCRoot *listener;
AutoGCRoot *errorListener;

NSString *method;
NSString *rawDatas;
NSString *httpBody;
NSMutableURLRequest *request;
AFHTTPRequestOperation *op;

// Static ----------------------------------------------------------------------

void close(const char* taskId)
{
	NSString* nsTaskId = [NSString stringWithUTF8String:taskId];
	
	NativeHttpLoader* loader;
	loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
	if (loader) [loader close];
}

const char* HttpLoader::create(const char* url)
{
	NSString* nsUrl = [NSString stringWithUTF8String:url];
	NSString *taskId = [[NSUUID UUID] UUIDString];
	const char* cTaskId = [taskId UTF8String];

	NativeHttpLoader* loader = [[NativeHttpLoader alloc] initWithUrl:nsUrl 
		andTaskId:taskId];

	[map setObject:loader forKey:taskId];
	// DLog(@"create %@", taskId);
	return cTaskId;
}

void HttpLoader::setUrl(const char* taskId, const char* url)
{
	NSString* nsTaskId = [NSString stringWithUTF8String:taskId];
	NativeHttpLoader* loader;
	loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
}

void HttpLoader::configure(const char* taskId, const char* methodValue, 
	const char* dataValue)
{
	NSString* nsTaskId = [NSString stringWithUTF8String:taskId];
	NativeHttpLoader* loader;
	loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
	if (loader != nil)
	{
		NSString* method = methodValue != nil 
			? [NSString stringWithUTF8String:methodValue] : nil;
		[loader setHttpMethod:method];

		NSString* data = dataValue != nil 
			? [NSString stringWithUTF8String:dataValue] : nil;
		[loader setHttpBody:data];
	}
}

void HttpLoader::setHeader(const char* taskId, const char* key, const char* value)
{	
	NSString *nsTaskId = [NSString stringWithUTF8String:taskId];
	NSString *nsKey = [NSString stringWithUTF8String:key];
	NSString *nsValue = [NSString stringWithUTF8String:value];
	NativeHttpLoader* loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
	if (loader != NULL) [loader setHttpHeaderFor:nsKey withValue:nsValue];
}

void HttpLoader::setVariable(const char* taskId, const char* key, const char* value)
{
	NSString *nsTaskId = [NSString stringWithUTF8String:taskId];
	NSString *nsKey = [NSString stringWithUTF8String:key];
	NSString *nsValue = [NSString stringWithUTF8String:value];
	NativeHttpLoader* loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
	if (loader != NULL) [loader setHttpVariableFor:nsKey withValue:nsValue];
}

void HttpLoader::setBody(const char* taskId, const char* value)
{
	NSString *nsTaskId = [NSString stringWithUTF8String:taskId];
	NativeHttpLoader* loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
	NSString *nsValue = [NSString stringWithUTF8String:value];
	if (loader != NULL) [loader setHttpBody:nsValue];
}

void HttpLoader::load(const char* taskId)
{
	NSString *nsTaskId = [NSString stringWithUTF8String:taskId];
	NativeHttpLoader* loader = [map objectForKey:nsTaskId];
	if (loader != NULL) [loader load];
}
