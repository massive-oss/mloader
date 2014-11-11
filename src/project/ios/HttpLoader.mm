#import <UIKit/UIApplication.h>
#import <UIKit/UIKit.h>

#include "HttpLoader.h"
#include "AFNetworking.h"

extern "C"
{
	void mloader_callListener(AutoGCRoot *listener, const char* data);
	void mloader_callErrorListener(AutoGCRoot *listener, 
		int code, const char* data);
}

NSMutableDictionary *variables;
AutoGCRoot *listener;
AutoGCRoot *errorListener;

NSString *method;
NSString *rawDatas;
NSString *httpBody;
NSMutableURLRequest *request;

HttpLoader::HttpLoader(const char* url)
{
	source = url;
	NSString* nsSource = [NSString stringWithUTF8String:source];

	NSURL *nsUrl = [NSURL URLWithString:nsSource];

	//Temp debug
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production

	request = [NSMutableURLRequest 
		requestWithURL:nsUrl
		cachePolicy:NSURLRequestReloadIgnoringCacheData  
		timeoutInterval:100];
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

HttpLoader* HttpLoader::create(const char* url)
{
	return new HttpLoader(url);
}

void HttpLoader::configure(const char* methodValue, const char* dataValue)
{
	method = [NSString stringWithUTF8String:methodValue];
	[request setHTTPMethod:method];

	setHttpBody(dataValue);

	rawDatas = [NSString stringWithUTF8String:dataValue];
}

void HttpLoader::setUrl(const char *url)
{
	source = url;
}

void HttpLoader::setHttpBody(const char *data)
{
	NSString *post = data != NULL ? [NSString stringWithUTF8String:data] : NULL;

	[request setHTTPBody:post == NULL ? nil : [post dataUsingEncoding:NSUTF8StringEncoding]];
}

void HttpLoader::setUrlVariable(const char* name, const char *value)
{
	NSString *nsKey = [NSString stringWithUTF8String:name];
	NSString *nsValue = [NSString stringWithUTF8String:value];
	
	if (variables == nil)
		variables = [NSMutableDictionary dictionary];

	[variables setValue:nsValue forKey:nsKey];
}

void HttpLoader::setHeader(const char* key, const char* value)
{	
	NSString *nsKey = [NSString stringWithUTF8String:key];
	NSString *nsValue = [NSString stringWithUTF8String:value];
	
	[request setValue:nsValue forHTTPHeaderField:nsKey];
}

void HttpLoader::load()
{
	AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] 
		initWithRequest:request];

	[op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSString *result = [operation responseString];

	    dispatch_async(dispatch_get_main_queue(), ^{
	    	const char *utf8String = [result UTF8String];
			mloader_callListener(listener, utf8String);
		});
	} 
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
	    NSInteger statusCode = operation.response.statusCode;
		NSString *result = [operation responseString];

	     dispatch_async(dispatch_get_main_queue(), ^{
	    	const char *utf8String = [result UTF8String];
			mloader_callErrorListener(errorListener, statusCode, utf8String);
		});
	}];
	[[NSOperationQueue mainQueue] addOperation:op];
}
