#import <UIKit/UIApplication.h>
#import <UIKit/UIKit.h>

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

@interface MLoaderQueue : NSOperationQueue
+ (id)instance;
@end

@implementation MLoaderQueue

+ (id)instance
{
	static MLoaderQueue *queue = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, 
	^{
		queue = [[self alloc] init];
	});
	return queue;
}

- (id)init
{
	if (self = [super init]) 
	{
		self.name = @"mloader Operation Queue";
	}
	return self;
}

@end

NSMutableDictionary *variables;
static NSMapTable *map = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
	valueOptions:NSMapTableWeakMemory];

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
	HttpLoader* result = (HttpLoader*)[[map objectForKey:nsTaskId] pointerValue];
	if (result != NULL) result->closeRequest();
	[map removeObjectForKey:nsTaskId];
}

const char* HttpLoader::create(const char* url)
{
	NSString *taskId = [[NSUUID UUID] UUIDString];
	const char* cTaskId = [taskId UTF8String];
	HttpLoader* loader = new HttpLoader(url, cTaskId);
	[map setObject:[NSValue valueWithPointer:loader] forKey:taskId];
	HttpLoader* result = HttpLoader::getLoaderByTask(cTaskId);
	return cTaskId;
}

HttpLoader* HttpLoader::getLoaderByTask(const char* taskId)
{
	NSString* nsTaskId = [NSString stringWithUTF8String:taskId];
	HttpLoader* result = (HttpLoader*)[[map objectForKey:nsTaskId] pointerValue];
	return result;
}

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

void HttpLoader::setUrl(const char* taskId, const char* url)
{
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL) loader->source = url;
}

void HttpLoader::configure(const char* taskId, const char* methodValue, 
	const char* dataValue)
{
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL)
	{
		loader->setHttpMethod(methodValue);
		loader->setHttpBody(dataValue);
	}
}

void HttpLoader::setHeader(const char* taskId, const char* key, const char* value)
{	
	NSString *nsTaskId = [NSString stringWithUTF8String:taskId];
	NSString *nsKey = [NSString stringWithUTF8String:key];
	NSString *nsValue = [NSString stringWithUTF8String:value];
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL) loader->setHttpHeader(key, value);
}

void HttpLoader::setVariable(const char* taskId, const char* key, const char* value)
{
	NSString *nsTaskId = [NSString stringWithUTF8String:taskId];
	NSString *nsKey = [NSString stringWithUTF8String:key];
	NSString *nsValue = [NSString stringWithUTF8String:value];
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL) loader->setHttpVariable(key, value);
}

void HttpLoader::setBody(const char* taskId, const char* value)
{
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL) loader->setHttpBody(value);
}

void HttpLoader::load(const char* taskId)
{
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL) loader->execute();
}

void HttpLoader::setSuccessListener(const char* taskId, AutoGCRoot *value)
{
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL) loader->setListener(value);
}

void HttpLoader::setFailureListener(const char* taskId, AutoGCRoot *value)
{
	HttpLoader* loader = HttpLoader::getLoaderByTask(taskId);
	if (loader != NULL) loader->setErrorListener(value);
}

// Non static ------------------------------------------------------------------

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
