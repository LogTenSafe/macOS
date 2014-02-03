#import "LTSLaunchDaemonManager.h"

static LTSLaunchDaemonManager *sharedManager = nil;

@interface LTSLaunchDaemonManager ()

- (NSString *) launchAgentsDirectory;
- (void) createLauchPlist;
- (NSString *) executablePath;

@end

#pragma mark -

@implementation LTSLaunchDaemonManager

#pragma mark Singleton

+ (LTSLaunchDaemonManager *) sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark Initialization and deallocation

- (id) init {
    if (self = [super init]) {
        // load or create plist
        launchPlistPath = [[self launchAgentsDirectory] stringByAppendingPathComponent:@"info.timothymorgan.LogTenSafe.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:launchPlistPath]) {
            [self createLauchPlist];
        }
        launchPlist = [NSMutableDictionary dictionaryWithContentsOfFile:launchPlistPath];
        
        // update executable directory
        launchPlist[@"ProgramArguments"][0] = [self executablePath];
        [launchPlist writeToFile:launchPlistPath atomically:NO];
        
        // update disabled
        self.disabled = [launchPlist[@"Disabled"] boolValue];

        // watch disabled for changes
        [self addObserver:self forKeyPath:@"disabled" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void) dealloc {
    [self removeObserver:self forKeyPath:@"disabled"];
}

#pragma mark Private methods

- (NSString *) launchAgentsDirectory {
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    return [directory stringByAppendingPathComponent:@"LaunchAgents"];
}

- (void) createLauchPlist {
    NSDictionary *settings = @{@"Disabled": @(true),
                               @"Label": @"info.timothymorgan.LogTenSafe",
                               @"ProgramArguments": @[[self executablePath]],
                               @"RunAtLoad": @(false),
                               @"StartInterval": @(1800)};
    [settings writeToFile:launchPlistPath atomically:NO];

}

- (NSString *) executablePath {
    NSString *ownPath = [NSBundle mainBundle].resourcePath;
    return [[[ownPath stringByDeletingLastPathComponent]
             stringByAppendingPathComponent:@"Resources"]
            stringByAppendingPathComponent:@"CheckLogbookForChanges"];
}

#pragma mark NSKeyValueObserving

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"disabled"]) {
        launchPlist[@"Disabled"] = @(self.disabled);
        [launchPlist writeToFile:launchPlistPath atomically:NO];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
