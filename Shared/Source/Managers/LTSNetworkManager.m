#import "LTSNetworkManager.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>

static LTSNetworkManager *sharedManager = nil;

@interface LTSNetworkManager ()

#pragma mark Properties

@property (readonly) NSString *login;
@property (readonly) NSString *password;
@property (readonly) NSDictionary *constants;

#pragma mark Private methods

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL credentialsProvided;
- (NSString *) defaultConstantsPlistPath;

@end

#pragma mark -

@implementation LTSNetworkManager

#pragma mark Properties

@dynamic login;
@dynamic password;
@dynamic constants;

#pragma mark Singleton

+ (LTSNetworkManager *) sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark Initialization

- (instancetype) init {
    self = [super init];
    if (self) {
        self.constantsPlistPath = [self defaultConstantsPlistPath];
        self.synchronous = NO;
    }
    return self;
}

#pragma mark Operations

- (void) loadBackupsListAnd:(void (^)(NSData *))successHandler onError:(void (^)(NSError *))errorHandler {
    NSURL *loadURL = [[NSURL alloc] initWithString:self.constants[@"URLBase"]];
    loadURL = [loadURL URLByAppendingPathComponent:self.constants[@"BackupsPath"]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:loadURL];
    request.username = self.login;
    request.password = self.password;
    
    __weak typeof(request) weakRequest = request;
    request.completionBlock = ^{
        if (weakRequest.responseStatusCode == 200) {
            if (successHandler) successHandler(weakRequest.responseData);
        }
        else {
            NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                                 code:LTSErrorCodeBadResponse
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"An error occurred when downloading your list of prior backups from LogTenSafe.", nil),
                                                        @"statusCode": @(weakRequest.responseStatusCode)}];
            if (errorHandler) errorHandler(error);
        }
        
    };
    request.failedBlock = ^{
        if (weakRequest.error.domain == NetworkRequestErrorDomain && weakRequest.error.code == ASIAuthenticationErrorType) {
            NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                                 code:LTSErrorCodeAuthenticationRequired
                                             userInfo:nil];
            if (errorHandler) errorHandler(error);
        } else {
            NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                                 code:LTSErrorCodeConnectionFailure
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"A network error occurred.", nil),
                                                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please make sure you are connected to the Internet.", nil),
                                                        @"originalError": weakRequest.error}];
            if (errorHandler) errorHandler(error);
        }
    };
    
    if (self.synchronous) [request startSynchronous];
    else [request startAsynchronous];
}

- (ASIHTTPRequest *) addBackup:(NSString *)backupPath onSuccess:(void (^)(void))successHandler onError:(void (^)(NSError *))errorHandler {
    NSURL *backupURL = [[NSURL alloc] initWithString:self.constants[@"URLBase"]];
    backupURL = [backupURL URLByAppendingPathComponent:self.constants[@"UploadPath"]];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:backupURL];
    request.username = self.login;
    request.password = self.password;
    [request setPostValue:[NSHost currentHost].localizedName forKey:@"backup[hostname]"];
    [request setFile:backupPath forKey:@"backup[logbook]"];
    
    __weak typeof(request) weakRequest = request;
    request.completionBlock = ^{
        if (weakRequest.responseStatusCode == 201) {
            if (successHandler) successHandler();
        }
        else if (weakRequest.responseStatusCode == 422) {
            NSError *parseError = nil;
            NSDictionary *errorData = [NSJSONSerialization JSONObjectWithData:weakRequest.responseData options:0 error:&parseError];
            if (parseError) {
                NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                                     code:LTSErrorCodeBadResponse
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"An error occurred when sending your backup to LogTenSafe.", nil)}];
                errorHandler(error);
                return;
            }
            NSMutableArray *errors = [NSMutableArray new];
            for (NSString *field in errorData[@"errors"]) {
                for (NSString *fieldError in errorData[@"errors"][field]) {
                    [errors addObject:[NSString stringWithFormat:@"%@ %@", field, fieldError]];
                }
            }
            NSString *combinedError = [errors componentsJoinedByString:@", "];
            NSString *suggestionString = [NSString stringWithFormat:NSLocalizedString(@"The error was: %@", @"%@ = list of errors"), combinedError];
            
            NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                                 code:LTSErrorCodeBadResponse
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"An error occurred when sending your backup to LogTenSafe.", nil),
                                                        NSLocalizedRecoverySuggestionErrorKey: suggestionString}];
            errorHandler(error);
            return;

        }
        else {
            NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                                 code:LTSErrorCodeBadResponse
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"An error occurred when sending your backup to LogTenSafe.", nil),
                                                        @"statusCode": @(weakRequest.responseStatusCode)}];
            errorHandler(error);
        }
    };
    request.failedBlock = ^{
        NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                             code:LTSErrorCodeConnectionFailure
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"A network error occurred.", nil),
                                                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please make sure you are connected to the Internet.", nil),
                                                    @"originalError": weakRequest.error}];
        errorHandler(error);
    };
    
    if (self.synchronous) [request startSynchronous];
    else [request startAsynchronous];
    
    return request;
}

- (ASIHTTPRequest *) downloadBackup:(NSURL *)backupURL onSuccess:(void (^)(NSData *))successHandler onError:(void (^)(NSError *))errorHandler {
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:backupURL];
    request.username = self.login;
    request.password = self.password;
    
    typeof(request) weakRequest = request;
    request.completionBlock = ^{
        if (weakRequest.responseStatusCode == 200) {
            successHandler(weakRequest.responseData);
        }
        else {
            NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                                 code:LTSErrorCodeBadResponse
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn’t download that logbook backup.", nil)}];
            errorHandler(error);
        }
    };
    request.failedBlock = ^{
        NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                             code:LTSErrorCodeConnectionFailure
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn’t download that logbook backup.", nil)}];
        errorHandler(error);
    };
    
    if (self.synchronous) [request startSynchronous];
    else [request startAsynchronous];
    
    return request;
}

#pragma mark Private properties

- (NSString *) login {
    return [[NSUserDefaults standardUserDefaults] stringForKey:LTSUserDefaultKeyLogin];
}

- (NSString *) password {
    return [[NSUserDefaults standardUserDefaults] stringForKey:LTSUserDefaultKeyPassword];
}

- (NSDictionary *) constants {
    if (!self.constantsPlistPath) [[NSException exceptionWithName:@"LTSNoExecutableBundle"
                                                           reason:@"CheckLogbookForChanges must be run inside LogTenSafe's bundle."
                                                         userInfo:nil] raise];
    
    return [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:self.constantsPlistPath]
                                            mutabilityOption:NSPropertyListImmutable
                                                      format:nil
                                            errorDescription:nil];
}

#pragma mark Private methods

- (BOOL) credentialsProvided {
    return self.login && self.password;
}


- (NSString *) defaultConstantsPlistPath {
    return [[NSBundle mainBundle] pathForResource:@"Constants" ofType:@"plist"];
}

@end
