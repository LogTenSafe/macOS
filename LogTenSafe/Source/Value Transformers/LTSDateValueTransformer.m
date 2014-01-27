#import "LTSDateValueTransformer.h"

@implementation LTSDateValueTransformer

#pragma mark Properties

@synthesize dateFormatter = _dateFormatter;

- (NSDateFormatter *) dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:self.style];
    }
    
    return _dateFormatter;
}

#pragma mark NSValueTransformer

+ (Class) transformedValueClass {
    return [NSObject class];
}

+ (BOOL) allowsReverseTransformation {
    return NO;
}

- (id) transformedValue:(id)value {
    return [self.dateFormatter stringFromDate:(NSDate *)value];
}

@end
