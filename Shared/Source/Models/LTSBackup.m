#import "LTSBackup.h"

static NSDateFormatter *ISO8601Formatter;
static NSDateFormatter *dateOnlyFormatter;

@implementation LTSBackup

+ (void) initialize {
    ISO8601Formatter = [[NSDateFormatter alloc] init];
    ISO8601Formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
    
    dateOnlyFormatter = [[NSDateFormatter alloc] init];
    dateOnlyFormatter.dateFormat = @"yyyy-MM-dd";
}

- (instancetype) initFromJSON:(id)json {
    if (self = [super init]) {
        if (![json isKindOfClass:[NSDictionary class]]) {
            [[NSException exceptionWithName:@"LTSInvalidJSON"
                                     reason:@"The JSON description for a Backup was invalid."
                                   userInfo:@{@"json": json}] raise];
        }
        
        self.createdAt = [ISO8601Formatter dateFromString:json[@"created_at"]];
        self.lastFlightDate = [dateOnlyFormatter dateFromString:json[@"last_flight_date"]];
        self.lastFlightOrigin = json[@"last_flight"][@"origin"];
        self.lastFlightDestination = json[@"last_flight"][@"destination"];
        self.lastFlightDuration = [json[@"last_flight"][@"duration"] floatValue];
        self.totalHours = [json[@"total_hours"] floatValue];
        self.hostname = json[@"hostname"];
        self.logbookFileSize = [json[@"logbook"][@"size"] floatValue];
        self.logbookFingerprint = json[@"logbook"][@"fingerprint"];
        self.downloadURL = [[NSURL alloc] initWithString:json[@"download_url"]];
    }
    return self;
}

@end
