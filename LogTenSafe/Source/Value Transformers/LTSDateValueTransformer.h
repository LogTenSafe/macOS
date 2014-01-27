/*!
 @brief Value transfformer that formats a date using the given formatting style.
 */

@interface LTSDateValueTransformer : NSValueTransformer

/*!
 @brief The date formatter style to use.
 */

@property (assign) NSDateFormatterStyle style;

/*!
 @brief The date formatter to use (lazy-initialized).
 */

@property (readonly) NSDateFormatter *dateFormatter;

@end
