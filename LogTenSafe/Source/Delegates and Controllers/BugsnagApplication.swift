import Cocoa
import Bugsnag

/**
 * This class is necessary for Bugsnag integration.
 */

class BugsnagApplication: NSApplication {
    func reportException(exception: NSException) {
        Bugsnag.notify(exception)
        super.reportException(exception)
    }
}
