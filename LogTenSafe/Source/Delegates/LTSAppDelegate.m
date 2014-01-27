#import "LTSAppDelegate.h"

@implementation LTSAppDelegate

#pragma mark Initialization

+ (void) initialize {
    LTSDateValueTransformer *vt = [LTSDateValueTransformer new];
    vt.style = NSDateFormatterShortStyle;
    [NSValueTransformer setValueTransformer:vt forName:@"LTSShortDateValueTransformer"];
}

#pragma mark Application delegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.windowController = [[LTSBackupListWindowController alloc] initWithWindowNibName:@"BackupListWindow"];
    [self.windowController showWindow:nil];
    [self.windowController reloadBackups:nil];
}

#pragma mark Actions

- (IBAction) logOut:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LTSUserDefaultKeyLogin];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LTSUserDefaultKeyPassword];
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"You have been logged out.", nil);
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

@end
