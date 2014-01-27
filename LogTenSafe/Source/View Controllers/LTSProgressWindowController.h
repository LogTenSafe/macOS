/*!
 @brief Window controller for the progress sheet that is displayed when an
 upload operation is in progress.
 
 This sheet displays upload progress. When the upload portion of the request is
 complete, the progress bar becomes indeterminate. When the download portion is
 complete, the sheet closes itself.
 
 Because this is a sheet window controller, it must have its
 @link parent @endlink property set to properly end the sheet. You should set
 _all_ properties to fully configure the window controller before beginning the
 sheet.
 */

@interface LTSProgressWindowController : NSWindowController <ASIHTTPRequestDelegate>

/*!
 @brief The HTTP request this sheet is displaying progress for.
 */

@property (strong) ASIHTTPRequest *request;

/*!
 @brief The string to display above the progress bar.
 */

@property (strong) NSString *prompt;

/*!
 @brief The window this sheet is running on.
 */

@property (weak) NSWindowController *parent;

@end
