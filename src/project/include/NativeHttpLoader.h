#import <UIKit/UIKit.h>
#include "AFNetworking.h"

extern "C"
{
	void downloadmanager_onTaskFailed(const char* taskIdentifier, 
		const char* responseDatas, int errorCode);

	void downloadmanager_onTaskCompleted(const char* taskIdentifier, 
		const char* responseDatas);
}

@interface MLoaderQueue : NSOperationQueue
+ (id)instance;
@end

@interface NativeHttpLoader : NSObject

@property(atomic, strong) AFHTTPRequestOperation *operation;
@property(atomic, strong) NSMutableDictionary *variables;
@property(atomic, strong) NSMutableURLRequest* request;
@property(atomic, strong) NSString* source;
@property(atomic, strong) NSString* taskIdentifier;

- (id)initWithUrl:(NSString*)url andTaskId:(NSString *)taskId;
- (void)close;
- (void)load;
- (void)setHttpBody:(NSString*)data;
- (void)setHttpHeaderFor:(NSString*)key withValue:(NSString*)value;
- (void)setHttpMethod:(NSString*)method;
- (void)setHttpVariableFor:(NSString*)key withValue:(NSString*)value;

@end
