/*!
 @brief Represents a backup record downloaded from the server. Initialized from
 its JSON representation.
 */

@interface LTSBackup : NSObject

#pragma mark Properties

/*!
 @brief The date this backup was added.
 */

@property (strong) NSDate *createdAt;

/*!
 @brief The date of the most recent flight.
 */

@property (strong) NSDate *lastFlightDate;

/*!
 @brief The FAA LID of the origin airport of the most recent flight.
 */

@property (strong) NSString *lastFlightOrigin;

/*!
 @brief The FAA LID of the destination airport of the most recent flight.
 */

@property (strong) NSString *lastFlightDestination;

/*!
 @brief The duration of the most recent flight, in hours.
 */

@property (assign) float lastFlightDuration;

/*!
 @brief The total number of hours in this logbook.
 */

@property (assign) float totalHours;

/*!
 @brief The name of the computer this logbook was uploaded from.
 */

@property (strong) NSString *hostname;

/*!
 @brief The size of this logbook, in bytes.
 */

@property (assign) unsigned int logbookFileSize;

/*!
 @brief The MD5 hash of this logbook's data.
 */

@property (strong) NSString *logbookFingerprint;

/*!
 @brief The URL where the logbook can be downloaded.
 */

@property (strong) NSURL *downloadURL;

#pragma mark Initialization

- (instancetype) init NS_UNAVAILABLE;

/*!
 @brief Creates a new backup record from its JSON representation.
 
 @param json The JSON representation of the backup (should be an
 `NSDictionary`).
 @return The initialized record.
 */

- (instancetype) initFromJSON:(id)json NS_DESIGNATED_INITIALIZER;

@end
