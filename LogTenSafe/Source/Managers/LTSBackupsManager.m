#import "LTSBackupsManager.h"

static LTSBackupsManager *sharedManager = nil;

@interface LTSBackupsManager ()

- (NSString *) LogTenDataPath;

@end

#pragma mark -

@implementation LTSBackupsManager

#pragma mark Singleton

+ (LTSBackupsManager *) sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark Logbook operations

- (void) reloadWithErrorHandler:(void (^)(NSError *))errorHandler {
    [[LTSNetworkManager sharedManager] loadBackupsListAnd:^(NSData *data){
        NSError *error = nil;
        NSArray *backupsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            NSError *newError = [NSError errorWithDomain:LTSErrorDomain
                                                    code:LTSErrorCodeParseError
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn’t download your list of previous backups.", nil),
                                                           @"originalError": error}];
            if (errorHandler) errorHandler(newError);
            return;
        }
        
        NSMutableArray *backups = [[NSMutableArray alloc] initWithCapacity:[backupsData count]];
        for (NSDictionary *backupData in backupsData) {
            LTSBackup *backup = [[LTSBackup alloc] initFromJSON:backupData];
            [backups addObject:backup];
        }
        self.backups = backups;
    } onError:^(NSError *error) {
        if (errorHandler) errorHandler(error);
    }];
}

- (ASIHTTPRequest *) addBackupWithErrorHandler:(void (^)(NSError *))errorHandler {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self LogTenDataPath]]) {
        NSError *error = [NSError errorWithDomain:LTSErrorDomain
                                             code:LTSErrorCodeCantReadLogbook
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn’t find your LogTen Pro logbook.", nil),
                                                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"You must have LogTen Pro 6 or newer for Mac to use this program.", nil)}];
        errorHandler(error);
        return nil;
    }
    
    return [[LTSNetworkManager sharedManager] addBackup:[self LogTenDataPath]
                                              onSuccess:^{
                                                  [self reloadWithErrorHandler:nil];
                                              }
                                                onError:errorHandler];
}

- (LTSBackupResult) restoreLogbook:(NSData *)logbookData outError:(NSError **)outError {
    LTSBackupResult result = LTSBackupResultCreate;
    
    // back up previous logbook
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self LogTenDataPath]]) {
        result = LTSBackupResultOverwrite;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd HHmmss";
        NSString *filename = [NSString stringWithFormat:@"LogTenCoreDataStore %@.sql", [dateFormatter stringFromDate:[NSDate date]]];

        NSString *backupPath = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)[0];
        backupPath = [backupPath stringByAppendingPathComponent:filename];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:[self LogTenDataPath] toPath:backupPath error:&error];
        if (error) {
            if (outError) *outError = error;
            return LTSBackupResultFailure;
        }
    }
    
    NSError *error = nil;
    [logbookData writeToFile:[self LogTenDataPath] options:0 error:&error];
    if (error) {
        if (outError) *outError = error;
        return LTSBackupResultFailure;
    }
    
    return result;
}

#pragma mark Helper methods

- (NSString *) LogTenDataPath {
    NSString *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    return [libraryDirectory stringByAppendingPathComponent:@"Containers/com.coradine.LogTenPro6/Data/Documents/LogTenProData/LogTenCoreDataStore.sql"];
}

@end
