/*!
 @brief Adds MD5 hashing capability to `NSData` objects.
 */

@interface NSData (LTSMD5)

/*!
 @brief Returns the hex-encoded MD5 value for this data.
 
 @return The MD5 hash of this data, as a 32-character hex string.
 */

- (NSString *) hexMD5;

@end
