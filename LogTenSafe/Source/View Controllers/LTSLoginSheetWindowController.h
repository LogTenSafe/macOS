/*!
 @brief Window controller for the login sheet that automatically appears when
 a network request is made without authentication credentials being stored.
 
 Authentication credentials are stored in the user defaults. The login and
 password fields for this controller's view are bound to the user defaults
 controller.
 
 Because this is a sheet window controller, it must have its
 @link parent @endlink property set to properly end the sheet.
 */

@interface LTSLoginSheetWindowController : NSWindowController <NSWindowDelegate>

#pragma mark Properties

/*!
 @brief The window that this sheet is running on.
 */

@property (weak) NSWindow *parent;

#pragma mark Actions

/*!
 @brief Invoked when the user clicks the Log In button. Closes the sheet so that
 the previous network request can be retried (with response
 `NSModalResponseOK`).
 
 @param sender The object that initiated the action.
 */

- (IBAction) logIn:(id)sender;

/*!
 @brief Invoked when the user clicks the sign up button. Visits the LogTenSafe
 home page in the default browser.
 
 @param sender The object that initiated the action.
 */

- (IBAction) signUp:(id)sender;

/*!
 @brief Invoked when the user clicks the Quit button. Ends the sheet so that
 the application can be quit (with response `NSModalResponseCancel`).
 
 @param sender The object that initiated the action.
 */

- (IBAction) quit:(id)sender;

@end
