#import "LTSBackupListWindowController.h"

@class LTSAppDelegate;

@interface LTSBackupListWindowController ()

- (void) requestAuthenticationThen:(void (^)(void))then;

@end

#pragma mark -

@implementation LTSBackupListWindowController

#pragma mark Initialization and deallocation

- (void) awakeFromNib {
    [self.backupsArrayController bind:@"contentArray" toObject:[LTSBackupsManager sharedManager] withKeyPath:@"backups" options:nil];
    // kick off window resizing
    [self windowDidResize:nil];
    // preset backupAutomatically
    self.backupAutomatically = ![LTSLaunchDaemonManager sharedManager].disabled;
    // and observe it
    [self addObserver:self forKeyPath:@"backupAutomatically" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) dealloc {
    [self removeObserver:self forKeyPath:@"backupAutomatically"];
}

#pragma mark Actions

- (IBAction) reloadBackups:(id)sender {
    [[LTSBackupsManager sharedManager] reloadWithErrorHandler:^(NSError *error) {
        if ([error.domain isEqualToString:LTSErrorDomain] && error.code == LTSErrorCodeAuthenticationRequired) {
            [self requestAuthenticationThen:^{ [self reloadBackups:sender]; }];
        } else {
            [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window completionHandler:nil];
        }
    }];
}

- (IBAction) backupNow:(id)sender {
    if (self.progressWindowController) {
        NSBeep();
        return;
    }
    
    ASIHTTPRequest *request = [[LTSBackupsManager sharedManager] addBackupWithErrorHandler:^(NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
    }];

    if (request) {
        self.progressWindowController = [[LTSProgressWindowController alloc] initWithWindowNibName:@"ProgressWindow"];
        self.progressWindowController.request = request;
        self.progressWindowController.prompt = NSLocalizedString(@"Sending logbook data to server…", nil);
        self.progressWindowController.parent = self;
        [self.window beginSheet:self.progressWindowController.window completionHandler:^(NSModalResponse response) {
            self.progressWindowController = nil;
        }];
    }
}

#pragma mark Private methods

- (void) requestAuthenticationThen:(void (^)(void))then {
    if (self.loginSheetController) return;
    
    self.loginSheetController = [[LTSLoginSheetWindowController alloc] initWithWindowNibName:@"LoginWindow"];
    self.loginSheetController.parent = self.window;
    [self.window beginSheet:self.loginSheetController.window completionHandler:^(NSModalResponse response) {
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.loginSheetController = nil;
        if (response == NSModalResponseOK) then();
        else [NSApp terminate:nil];
    }];
}

#pragma mark NSWindowDelegate

- (void) windowDidResize:(NSNotification *)notification {
    CGFloat width = (self.collectionView).enclosingScrollView.bounds.size.width - 2;
    NSSize size = NSMakeSize(width, (self.collectionViewItemTemplate).bounds.size.height);
    (self.collectionView).minItemSize = size;
    (self.collectionView).maxItemSize = size;
}

#pragma mark NSKeyValueObserving

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"backupAutomatically"]) {
        [LTSLaunchDaemonManager sharedManager].disabled = ![change[NSKeyValueChangeNewKey] boolValue];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
