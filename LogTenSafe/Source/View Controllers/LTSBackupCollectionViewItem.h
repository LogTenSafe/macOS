/*!
 @brief NSCollectionView item proxy for an @link LTSBackup @endlink entry in the
 backup collection view.
 
 The `representedObject` is a `LTSBackup`.
 */

@interface LTSBackupCollectionViewItem : NSCollectionViewItem

/*!
 @brief If a download is in progress, this property stores the download request
 object, to use for progress indication. Otherwise it is `nil`.
 */

@property (strong) ASIHTTPRequest *downloadRequest;

/*!
 @brief Begins a download and restore operation for the associated `LTSBackup`.
 Does nothing if a download operation is already in progress.
 
 @param sender The object that initiated this action.
 */

- (IBAction) restoreFromBackup:(id)sender;

@end
