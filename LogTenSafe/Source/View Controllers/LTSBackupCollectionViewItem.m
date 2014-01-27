#import "LTSBackupCollectionViewItem.h"

@interface LTSBackupCollectionViewItem ()

- (NSData *) uncompessLogbook:(NSData *)compressedData;
- (LTSBackupResult) restoreLogbook:(NSData *)logbookData;
- (void) displaySuccess:(LTSBackupResult)result;

@end

#pragma mark -

@implementation LTSBackupCollectionViewItem

#pragma mark Actions

- (IBAction) restoreFromBackup:(id)sender {
    if (self.downloadRequest) {
        NSBeep();
        return;
    }
    
    typeof(self) weakSelf = self;
    self.downloadRequest = [[LTSNetworkManager sharedManager] downloadBackup:((LTSBackup *)(self.representedObject)).downloadURL onSuccess:^(NSData *backupData) {
        LTSBackupResult result = [self restoreLogbook:backupData];
        self.downloadRequest = nil;
        if (result) [self displaySuccess:result];
    } onError:^(NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:weakSelf.view.window completionHandler:nil];
        self.downloadRequest = nil;
    }];
}

#pragma mark Private methods

- (NSData *) uncompessLogbook:(NSData *)compressedData {
    NSError *error = nil;
    NSData *uncompressedData = [compressedData gzipInflateWithError:&error];
    if (error) {
        NSString *errorSubtext = [NSString stringWithFormat:NSLocalizedString(@"Gzip error: %@", @"%@ = a non-localized gzip error message"), error.userInfo[@"gzipErrorMessage"]];
        NSError *displayError = [NSError errorWithDomain:error.domain
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn’t download that logbook backup.", nil),
                                                           NSLocalizedRecoverySuggestionErrorKey: errorSubtext}];
        NSAlert *alert = [NSAlert alertWithError:displayError];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        return nil;
    }
    
    return uncompressedData;
}

- (LTSBackupResult) restoreLogbook:(NSData *)logbookData {
    NSData *uncompressedData = [self uncompessLogbook:logbookData];
    if (!uncompressedData) return NO;
    
    NSError *error = nil;
    LTSBackupResult result = [[LTSBackupsManager sharedManager] restoreLogbook:uncompressedData outError:&error];
    if (error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
    return result;
}

- (void) displaySuccess:(LTSBackupResult)result {
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"Your logbook has been reverted to a previous backup.", nil);
    if (result == LTSBackupResultOverwrite) {
        alert.informativeText = NSLocalizedString(@"Your previous logbook has been saved to your Desktop in case anything went wrong.", nil);
    }
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}


@end
