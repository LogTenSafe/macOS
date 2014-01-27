/*!
 @brief Additions to `NSData` to support GNU zipping and unzipping.
 
 Credit to http://deusty.blogspot.com/2007/07/gzip-compressiondecompression.html
 */

@interface NSData (LTSGZipping)

/*!
 @brief Treats the data in this `NSData` as gzipped, and returns a new `NSData`
 with the uncompressed data.
 
 @param outError Will contain any error if decompression fails. The `userInfo`
 key `gzipErrorMessage` will contain the error message from gzip.
 @return The uncompressed data, or `nil` if unzipping fails.
 */

- (NSData *) gzipInflateWithError:(NSError **)outError;

/*!
 @brief Returns a new `NSData` with this data, gzipped.
 @return The compressed data.
 */

- (NSData *) gzipDeflate;

@end
