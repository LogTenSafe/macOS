#import "LTSLoginSheetWindowController.h"

@implementation LTSLoginSheetWindowController

- (IBAction) logIn:(id)sender {
    [self.parent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction) signUp:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Constants" ofType:@"plist"];
    NSDictionary *constants = [NSDictionary dictionaryWithContentsOfFile:path];
    NSURL *rootURL = [NSURL URLWithString:constants[@"URLBase"]];
    [[NSWorkspace sharedWorkspace] openURL:rootURL];
}

- (IBAction) quit:(id)sender {
    [self.parent endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
