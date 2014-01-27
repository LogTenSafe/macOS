/** @file */

/*!
 @brief Possible result codes for a call to
 @link LTSBackupsManager::restoreLogbook:outError: @endlink.
 */

typedef enum _LTSBackupResult {
    /*! @brief Logbook restore failed. */
    LTSBackupResultFailure = 0,
    /*! @brief Logbook restore succeeded; an existing logbook was overwritten. */
    LTSBackupResultOverwrite,
    /*! @brief Logbook restore succeeded; no prior logbook was found. */
    LTSBackupResultCreate
} LTSBackupResult;

/*!
 @brief Singleton class that handles logbook operations, including backng up and
 restoring the LogTen Pro logbook.
 
 All network operations use the @link LTSNetworkManager @endlink singleton.
 */

@interface LTSBackupsManager : NSObject

#pragma mark Properties

/*!
 @brief The cached list of backups available from the server. This can be
 populated by calling @link reloadWithErrorHandler: @endlink.
 */

@property (nonatomic, copy) NSArray *backups;

#pragma mark Singleton

/*!
 @brief Returns the singleton instance.
 @return The singleton instance.
 */

+ (LTSBackupsManager *) sharedManager;

#pragma mark Logbook operations

/*!
 @brief Reloads the list of backups available on the server, and stores the
 result in the @link backups @endlink property.
 
 The download is performed asynchronously unless
 @link LTSNetworkManager::synchronous @endlink is set.
 
 @param errorHandler Block to be executed when a network or JSON error occurs.
 Passed the error information.
 */

- (void) reloadWithErrorHandler:(void (^)(NSError *error))errorHandler;

/*!
 @brief Uploads a new backup to the server. Uses the current
 LogTenProCoreData.sql file. Calls @link reloadWithErrorHandler: @endlink when
 the upload succeeds.
 
 The upload is performed asynchronously unless
 @link LTSNetworkManager::synchronous @endlink is set.
 
 @param errorHandler Block to be executed when a network error occurs. Passed
 the error information.
 @return The HTTP request object.
 */

- (ASIHTTPRequest *) addBackupWithErrorHandler:(void (^)(NSError *))errorHandler;

/*!
 @brief Replaces the LogTenProCoreData.sql file with the given logbook data. If
 the logbook file already exists, it is backed up to the desktop with a
 timestamped file name.
 
 @param logbookData The new logbook data to replace the existing logbook with.
 @param outError Contains any error that occurs during the operation.
 @return The result of the operation.
 */

- (LTSBackupResult) restoreLogbook:(NSData *)logbookData outError:(NSError **)outError;

@end
