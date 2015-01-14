#import "NativeHttpLoader.h"
#import "MassiveUtil.h"

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

@implementation NativeHttpLoader

@synthesize operation;
@synthesize request;
@synthesize source;
@synthesize taskIdentifier;
@synthesize variables;

- (id)initWithUrl:(NSString*)rawUrl andTaskId:(NSString *)taskId
{
	if (self == [super init])
	{
		taskIdentifier = taskId;
		NSURL *url = [NSURL URLWithString:rawUrl];
		source = rawUrl;
		request = request = [NSMutableURLRequest requestWithURL:url 
			cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1000];
	}
	return self;
}

- (void)close
{
	if (operation) [operation cancel];

	operation = nil;
	variables = nil;
	source = nil;
	request = nil;
	taskIdentifier = nil;
}

- (void)setHttpBody:(NSString*)data
{
	// DLog(@"setHttpBody ::: %@", data);
	NSData* nsData = nil;
	if (data) nsData = [data dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody : nsData];
}

- (void)setHttpHeaderFor:(NSString*)key withValue:(NSString*)value
{
	// DLog(@"setHttpHeaderFor ::: %@ = %@", key, value);
	[request setValue:value forHTTPHeaderField:key];
}

- (void)setHttpVariableFor:(NSString*)key withValue:(NSString*)value
{
	// DLog(@"setHttpVariableFor ::: %@ = %@", key, value);
	if (variables == nil)
		variables = [NSMutableDictionary dictionary];
	[variables setValue:value forKey:key];
}

- (void)setHttpMethod:(NSString*)method
{
	[request setHTTPMethod:method];
}

- (void)load
{
	// DLog(@"load");
	__weak __typeof__(self) weakSelf = self;

	operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *completedOperation, 
		id responseObject)
	{
		__typeof__(self) strongSelf = weakSelf;

		NSString *result = [completedOperation responseString];
		const char *taskId = [strongSelf.taskIdentifier UTF8String];
		const char *resultDatas = [result UTF8String];
		downloadmanager_onTaskCompleted(taskId, resultDatas);
		[strongSelf close];
	} 
	failure:^(AFHTTPRequestOperation *failedOperation, NSError *error)
	{
		__typeof__(self) strongSelf = weakSelf;

		NSString *result = [failedOperation responseString];
		NSInteger statusCode = failedOperation.response.statusCode;
		const char* taskId = [strongSelf.taskIdentifier UTF8String];
		const char *datas = [result UTF8String];
		downloadmanager_onTaskFailed(taskId, datas, statusCode);

		[strongSelf close];
	}];

	#ifdef DEBUG
	AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
	[policy setAllowInvalidCertificates:YES]; // TODO(Johann) : Add a setting to that one
	operation.securityPolicy = policy;
	#endif

	[[MLoaderQueue instance] addOperation:operation];
}

@end
