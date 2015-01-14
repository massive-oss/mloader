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
	// NSString* nsTaskId = [NSString stringWithUTF8String:taskId];
	// HttpLoader* result = (__bridge HttpLoader*)[map objectForKey:nsTaskId];
	// if (result != NULL) result->closeRequest();
	// [map removeObjectForKey:nsTaskId];
}

const char* HttpLoader::create(const char* url)
{
	NSString* nsUrl = [NSString stringWithUTF8String:url];
	NSString *taskId = [[NSUUID UUID] UUIDString];
	const char* cTaskId = [taskId UTF8String];

	NativeHttpLoader* loader = [[NativeHttpLoader alloc] initWithUrl:nsUrl 
		andTaskId:taskId];

	[map setObject:loader forKey:taskId];
	DLog(@"create %@", taskId);
	return cTaskId;
}

void HttpLoader::setUrl(const char* taskId, const char* url)
{
	NSString* nsTaskId = [NSString stringWithUTF8String:taskId];
	NativeHttpLoader* loader;
	loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
	// HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	// if (loader != NULL) loader->source = url;
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

void HttpLoader::setSuccessListener(const char* taskId, AutoGCRoot *value)
{
	NSString *nsTaskId = [NSString stringWithUTF8String:taskId];
	NativeHttpLoader* loader = (NativeHttpLoader*)[map objectForKey:nsTaskId];
	// if (loader != NULL) loader->setListener(value);
}

void HttpLoader::setFailureListener(const char* taskId, AutoGCRoot *value)
{
	// HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	// if (loader != NULL) loader->setErrorListener(value);
}

// Non static ------------------------------------------------------------------
/*
HttpLoader::HttpLoader(const char* url, const char* taskId)
{
	source = url;
	NSString* nsSource = [NSString stringWithUTF8String:source];
	NSURL *nsUrl = [NSURL URLWithString:nsSource];
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	#ifdef DEBUG
	manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
	#endif

	request = [NSMutableURLRequest requestWithURL:nsUrl 
		cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1000];
}


HttpLoader::~HttpLoader()
{
	//TODO(Johann)
}

void HttpLoader::setListener(AutoGCRoot *value)
{
	listener = value;
}

void HttpLoader::setErrorListener(AutoGCRoot *value)
{
	errorListener = value;
}

void HttpLoader::setHttpBody(const char* data)
{
	NSString *post = data != NULL ? [NSString stringWithUTF8String:data] : NULL;
	[request setHTTPBody:post == NULL ? nil : [post dataUsingEncoding:NSUTF8StringEncoding]];
}

void HttpLoader::setHttpHeader(const char* key, const char* value)
{
	NSString *nsKey = [NSString stringWithUTF8String:key];
	NSString *nsValue = [NSString stringWithUTF8String:value];	
	[request setValue:nsValue forHTTPHeaderField:nsKey];
}

void HttpLoader::setHttpVariable(const char* key, const char* value)
{
	NSString *nsKey = [NSString stringWithUTF8String:key];
	NSString *nsValue = [NSString stringWithUTF8String:value];	
	if (variables == nil)
		variables = [NSMutableDictionary dictionary];
	[variables setValue:nsValue forKey:nsKey];
}

void HttpLoader::setHttpMethod(const char* value)
{
	method = [NSString stringWithUTF8String:value];
	[request setHTTPMethod:method];
}

void HttpLoader::closeRequest()
{
	if (op != nil) [op cancel];
	listener = nil;
	errorListener = nil;
	request = nil;
	op = nil;
}

void HttpLoader::execute()
{
	op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	
	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, 
		id responseObject)
	{
		NSString *result = [operation responseString];
		if (result && listener)
		{
			dispatch_async(dispatch_get_main_queue(), 
			^{
				if (result && listener)
				{
					const char *utf8String = [result UTF8String];
					mloader_callListener(listener, utf8String);
				}
			});
		}
	} 
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		NSInteger statusCode = operation.response.statusCode;
		NSString *result = [operation responseString];
		if (result == nil) result = @"Request error";
		dispatch_async(dispatch_get_main_queue(), 
		^{
			if (result && errorListener)
			{
				const char *utf8String = [result UTF8String];
				mloader_callErrorListener(errorListener, statusCode, utf8String);
			}
		});
	}];
	
	#ifdef DEBUG
	AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
	[policy setAllowInvalidCertificates:YES]; // TODO(Johann) : Add a setting to that one
	op.securityPolicy = policy;
	#endif

	[[MLoaderQueue instance] addOperation:op];
}
*/
