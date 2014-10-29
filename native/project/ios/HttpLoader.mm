#import <UIKit/UIApplication.h>
#import <UIKit/UIKit.h>

#include "HttpLoader.h"
#import "AFNetworking.h"

extern "C"
{
	void mloader_callListener(AutoGCRoot *listener, const char* data);
}

AFHTTPRequestOperationManager *manager;
NSMutableDictionary *variables;
AutoGCRoot *listener;

HttpLoader::HttpLoader(const char* url)
{
	source = url;
	manager = [AFHTTPRequestOperationManager manager];	
	manager.requestSerializer = [AFHTTPRequestSerializer serializer];
}

HttpLoader::~HttpLoader()
{
	//TODO(Johann)
}

void HttpLoader::setListener(AutoGCRoot *value)
{
	listener = value;
}

HttpLoader* HttpLoader::create(const char* url)
{
	return new HttpLoader(url);
}

void HttpLoader::setUrlVariable(const char* name, const char *value)
{
	NSString *nsName = [NSString stringWithUTF8String:name];
	NSString *nsValue = [NSString stringWithUTF8String:value];

	if (variables == nil)
		variables = [[NSMutableDictionary alloc] init];
	[variables setValue:nsValue forKey:nsName];
}

void HttpLoader::load()
{
	NSString *url = [NSString stringWithUTF8String:source];
	[manager GET:url parameters:variables 
		success:^(AFHTTPRequestOperation *operation, 
			id responseObject)
		{
			mloader_callListener(listener, [operation.responseString UTF8String]);
		}
		failure:^(AFHTTPRequestOperation *operation, NSError *error)
		{
			NSLog(@"Error: %@", error);
			//TODO(Johann)
		}
	];
}
