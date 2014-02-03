/** @file */

#pragma mark Errors

/*!
 @brief The `NSError` domain for errors in LogTenSafe.
 */

extern NSString *LTSErrorDomain;

/*!
 @brief `NSError` codes in the `LTSErrorDomain` domain.
 */

typedef enum _LTSErrorCodes {
    /*! @brief A connection failure has occurred. */
    LTSErrorCodeConnectionFailure = 1,
    /*! @brief A file system error occurred when reading logbook. */
    LTSErrorCodeCantReadLogbook,
    /*! @brief No authentication credentials are saved in the user defaults. */
    LTSErrorCodeAuthenticationRequired,
    /*! @brief An unexpected HTTP response code was received. */
    LTSErrorCodeBadResponse,
    /*! @brief A JSON parse error occurred. */
    LTSErrorCodeParseError,
    /*! @brief Some data was not properly gzip-formatted. */
    LTSErrorCodeGzipFailure
} LTSErrorCodes;

#pragma mark User defaults

/*!
 @brief User defaults key for the user's login for LogTenSafe.
 */

extern NSString *LTSUserDefaultKeyLogin;

/*!
 @brief User defaults key for the user's password for LogTenSafe.
 */

extern NSString *LTSUserDefaultKeyPassword;

#pragma mark Launch daemon

/*!
 @brief The launchctl identifier for the CheckLogbookForChanges daemon.
 */

extern NSString *LTSLaunchDaemonIdentifier;
