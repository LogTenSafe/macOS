import AppKit
import SwiftUI

/**
 * Delegate for the "About LogTenSafe" window.
 */

@objc class AboutViewDelegate: NSObject {
    var window: NSWindow?
    //var viewController: AboutViewController!
    
    /**
     * Shows the window.
     */

    @IBAction func show(_ sender: Any) {
        let contentView = AboutView()//.environmentObject(viewController)
        
        if window == nil {
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 460, height: 255),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            window!.center()
            window!.setFrameAutosaveName("About")
            window!.contentView = NSHostingView(rootView: contentView)
            window!.isReleasedWhenClosed = false
            window!.title = "About"
        }
        
        window!.makeKeyAndOrderFront(nil)
    }
}
