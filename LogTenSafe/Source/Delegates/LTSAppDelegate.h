/*!
 @brief The application delegate.
 */

@interface LTSAppDelegate : NSObject <NSApplicationDelegate>

/*!
 @brief The window controller for the main backups list window. Created by the
 application delegate when the program is launched.
 */

@property (strong) LTSBackupListWindowController *windowController;

@end
