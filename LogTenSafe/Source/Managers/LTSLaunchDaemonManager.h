/*!
 Singleton manager for the launch daemon and its plist file.
 
 LogTenPro automatically checks for new backups using a launchd plist file that
 runs an executable stored in the app bundle.
 */

@interface LTSLaunchDaemonManager : NSObject {
    @private
    NSString *launchPlistPath;
    NSMutableDictionary *launchPlist;
}

/*!
 @brief Proxy for the `Disabled` attribute in the launchd plist file.
 
 This attribute is observed by the singleton. When it changes, the plist file is
 updated.
 */

@property (assign) BOOL disabled;


/*!
 @brief Returns the singleton instance.
 
 @return The singleton instance.
 */

+ (LTSLaunchDaemonManager *) sharedManager;

@end
