#import "NSData+LTSMD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (LTSMD5)

- (NSString *) hexMD5 {
    unsigned char result[16];
    CC_MD5([self bytes], (CC_LONG)[self length], result);
    
    NSMutableString *hexString = [[NSMutableString alloc] initWithCapacity:32];
    for (int i=0; i!=16; i++) [hexString appendFormat:@"%02x", result[i]];
    return hexString;
}

@end
