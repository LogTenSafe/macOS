/*!
 @brief Window controller for the main backup list window. Coordinates
 downloading the list of backups, adding new backups, requesting authentication,
 and configuring the collection list view.
 */

@interface LTSBackupListWindowController : NSWindowController <NSWindowDelegate>

#pragma mark Properties

/*!
 @brief If a login sheet is currently displayed, this property contains the
 window controller for that sheet.
 */

@property (strong) LTSLoginSheetWindowController *loginSheetController;

/*!
 @brief Outlet for the backups list collection view.
 
 When this window controller loads, the collection view is configured so that
 its subviews automatically resize to fit the width of their parent view.
 */

@property (weak) IBOutlet NSCollectionView *collectionView;

/*!
 @brief Outlet for the backups list collection view item template.
 */

@property (weak) IBOutlet NSView *collectionViewItemTemplate;

/*!
 @brief Outlet for the backups list array controller that powers the collection
 view.
 */

@property (weak) IBOutlet NSArrayController *backupsArrayController;

/*!
 @brief Proxy property that is observed in order to alter the launchd plist file
 to reflect the user's desire to backup automatically.
 
 The source of truth for this setting is actually the value of the `Disabled`
 key in the launchd plist file for the CheckLogbookForChanges executable. This
 property is connected to the checkbox, and the window controller observes it
 for changes, so that it can update the plist file accordingly. It is
 initialized to the appropriate value given the plist file, or `NO` if the file
 has not yet been created.
 */

@property (assign) BOOL backupAutomatically;

/*!
 @brief If an upload progress sheet is currently displayed, this property
 contains the window controller for that sheet.
 */

@property (strong) LTSProgressWindowController *progressWindowController;

#pragma mark Actions

/*!
 @brief Reloads the list of backups. Nothing is currently linked to this action.
 
 @param sender The object that initiated this action.
 */

- (IBAction) reloadBackups:(id)sender;

/*!
 @brief Action that is invoked when the user clicks "Backup Now".
 
 @param sender The object that initiated this action.
 */

- (IBAction) backupNow:(id)sender;

@end
