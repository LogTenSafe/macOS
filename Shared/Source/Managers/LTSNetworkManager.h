/*!
 Singleton manager for all network operations with the LogTenSafe website.
 
 This manager requires a Constants.plist file containing the URLs to use. This
 file is automatically located in the application's bundle, or can be manually
 provided using the @link constantsPlistPath @endlink property.
 
 This manager performs all network operations asynchronously unless the
 @link synchronous @endlink property is set. In synchronous mode, callbacks are
 still used, but operations block until completed.
 
 All operations result in an error with the code
 @link ::LTSErrorCodeAuthenticationRequired @endlink if authentication
 credentials have not been provided or are invalid. This is your opportunity to
 prompt the user for credentials and try again.
 */

@interface LTSNetworkManager : NSObject

#pragma mark Properties

/*!
 @brief The path to the Constants.plist file. Automatically located in the
 application bundle if possible.
 */

@property (strong) NSString *constantsPlistPath;

/*!
 @brief If `YES`, network operations are blocking (but callbacks are still
 used).
 */

@property (assign) BOOL synchronous;

#pragma mark Singleton

/*!
 @brief Returns the singleton instance.
 
 @return The singleton instance.
 */

+ (LTSNetworkManager *) sharedManager;

#pragma mark Operations

/*!
 @brief Loads the JSON-formatted list of backups from the server.
 
 @param successHandler Block to be run when backups are loaded. Passed the JSON
 data of the backups.
 @param errorHandler Block to be run when an error occurs. Passed the error.
 */

- (void) loadBackupsListAnd:(void (^)(NSData *))successHandler onError:(void (^)(NSError *error))errorHandler;

/*!
 @brief Uploads a new logbook to the server.
 
 @param backupPath The location of the logbook to upload.
 @param successHandler Block to be run when the upload is successful.
 @param errorHandler Block to be run when an error occurs. Passed the error.
 @return The request object, to track progress.
 */

- (ASIHTTPRequest *) addBackup:(NSString *)backupPath onSuccess:(void (^)(void))successHandler onError:(void (^)(NSError *error))errorHandler;

/*!
 @brief Downloads a logbook backup from the server.
 
 @param backupURL The URL of the logbook to download.
 @param successHandler Block to be run when the download is successful. Passed
 the gzipped logbook data.
 @param errorHandler Block to be run when an error occurs. Passed the error.
 @return The request object, to track progress.
 */

- (ASIHTTPRequest *) downloadBackup:(NSURL *)backupURL onSuccess:(void (^)(NSData *backupData))successHandler onError:(void (^)(NSError *error))errorHandler;

@end
