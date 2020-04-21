import AppKit
import SwiftUI
import Defaults
import Combine
import Bugsnag

/**
 * The delegate for application events.
 */

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    @IBOutlet var viewController: MainViewController!
    
    @objc dynamic var loggedIn = false
    private var loggedInCancellable: AnyCancellable!
    
    override init() {
        super.init()
        loggedInCancellable = Defaults.publisher(.JWT)
            .map { $0.newValue != nil }
            .receive(on: RunLoop.main).assign(to: \.loggedIn, on: self)
    }
    
    deinit {
        loggedInCancellable.cancel()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Bugsnag.start(withApiKey: "730d83065b6d027cbded0b6e99314b22")
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = MainView().environmentObject(viewController)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("LogTenSafe")
        window.contentView = NSHostingView(rootView: contentView)
        window.isReleasedWhenClosed = false
        window.title = "LogTenSafe"
        window.makeKeyAndOrderFront(nil)
        
        // Load logbook data
        viewController.loadBackups()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

