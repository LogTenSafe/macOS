#import "LTSLaunchDaemonManager.h"

static LTSLaunchDaemonManager *sharedManager = nil;

@interface LTSLaunchDaemonManager ()

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *launchAgentsDirectory;
- (void) createLauchPlist;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *executablePath;
- (void) toggleLaunchAgent:(BOOL)enabled;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL launchAgentEnabled;

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

- (instancetype) init {
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
        self.disabled = ![self launchAgentEnabled];

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
    NSDictionary *settings = @{@"Label": LTSLaunchDaemonIdentifier,
                               @"ProgramArguments": @[[self executablePath]],
                               @"StartInterval": @(1800)};
    [settings writeToFile:launchPlistPath atomically:NO];

}

- (NSString *) executablePath {
    NSString *ownPath = [NSBundle mainBundle].resourcePath;
    return [[ownPath.stringByDeletingLastPathComponent
             stringByAppendingPathComponent:@"Resources"]
            stringByAppendingPathComponent:@"CheckLogbookForChanges"];
}

- (void) toggleLaunchAgent:(BOOL)enabled {
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
    if (enabled) [arguments addObject:@"load"];
    else [arguments addObject:@"unload"];
    [arguments addObject:@"-w"];
    [arguments addObject:launchPlistPath];

    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:arguments];
    [task waitUntilExit];
}

- (BOOL) launchAgentEnabled {
    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:@[@"list", LTSLaunchDaemonIdentifier]];
    [task waitUntilExit];

    return !task.terminationStatus;
}

#pragma mark NSKeyValueObserving

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"disabled"]) {
        [self toggleLaunchAgent:!self.disabled];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
