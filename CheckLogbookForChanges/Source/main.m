#pragma mark Interfaces

/*! @private */
NSString *logbookPath(void);

/*! @private */
NSData *logbookData(void);

/*! @private */
void uploadNewBackup(void);

#pragma mark Implementations

/*!
 @brief Entry point for the CheckForLogbookChanges binary.
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[NSUserDefaults standardUserDefaults] addSuiteNamed:@"info.timothymorgan.LogTenSafe"];
        [LTSNetworkManager sharedManager].synchronous = YES;
        
        // allow user to provide path to Constants.plist (for testing)
        if (argc == 2) {
            NSString *plistPath = @(argv[1]);
            [LTSNetworkManager sharedManager].constantsPlistPath = plistPath;
        }
        
        [[LTSNetworkManager sharedManager] loadBackupsListAnd:^(NSData *data) {
            NSError *error = nil;
            NSArray *backupsData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                NSLog(@"Error when parsing backups data: %@", error);
                exit(LTSErrorCodeConnectionFailure);
            }
            
            BOOL matchingBackupFound = NO;
            NSString *fingerprint = [logbookData() hexMD5];
            for (NSDictionary *backup in backupsData) {
                if ([backup[@"logbook"][@"fingerprint"] isEqual:fingerprint]) {
                    matchingBackupFound = YES;
                    break;
                }
            }
            if (!matchingBackupFound) {
                [[LTSNetworkManager sharedManager] addBackup:logbookPath()
                                                   onSuccess:^{
                                                       NSLog(@"New logbook backup uploaded.");
                                                   }
                                                     onError:^(NSError *error) {
                                                         NSLog(@"Error when upload new backup: %@", error);
                                                         exit((int)error.code);
                                                     }];
            }
        } onError:^(NSError *error) {
            NSLog(@"Error when attempting to load backup list: %@", error);
            exit((int)error.code);
        }];
    }
    return 0;
}

NSString *logbookPath(void) {
    NSString *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    return [libraryDirectory stringByAppendingPathComponent:@"Containers/com.coradine.LogTenPro6/Data/Documents/LogTenProData/LogTenCoreDataStore.sql"];
}

NSData *logbookData(void) {
    return [NSData dataWithContentsOfFile:logbookPath()];
}

void uploadNewBackup(void) {
    
}
