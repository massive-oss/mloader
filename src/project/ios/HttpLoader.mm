#import <UIKit/UIApplication.h>
#import <UIKit/UIKit.h>

#include "HttpLoader.h"

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

	request = [NSMutableURLRequest 
		requestWithURL:[NSURL URLWithString:nsSource]
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
	// NSURL *url = [NSURL URLWithString:urlString];
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[NSURLConnection sendAsynchronousRequest:request queue:queue 
		completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	{
		if (error)
		{
		    NSLog(@"Error,%@", [error localizedDescription]);
		    int code = [error code];
		    NSString *description = [error localizedDescription];
		    dispatch_async(dispatch_get_main_queue(), ^{
		    	const char *utf8String = [description UTF8String];
				mloader_callErrorListener(errorListener, code, utf8String);
			});
		}
		else 
		{
		    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		    
		    dispatch_async(dispatch_get_main_queue(), ^{
		    	const char *utf8String = [result UTF8String];
				mloader_callListener(listener, utf8String);
			});
		} 
	}];
}
