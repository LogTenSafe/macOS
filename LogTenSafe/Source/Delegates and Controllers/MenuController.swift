import AppKit

/**
 * View controller for menu item actions.
 */

@objc class MenuController: NSObject {
    @IBOutlet var viewController: MainViewController!
    
    private var appDelegate: AppDelegate {
        NSApp.delegate as! AppDelegate
    }
    
    /**
     * Called when the LogTenSafe link is clicked.
     */
    
    @IBAction func visitWebsite(_ sender: Any) {
        NSWorkspace.shared.open(appURL)
    }
    
    /**
     * Called when the Log Out menu item is invoked.
     */
    
    @IBAction func logOut(_ sender: Any) {
        viewController.logOut()
    }
    
    /**
     * Called when the Back Up Now menu item is invoked.
     */
    
    @IBAction func backUpNow(_ sender: Any) {
        viewController.addBackup()
    }
    
    /**
     * Called when the Refresh List menu item is invoked.
     */
    
    @IBAction func refresh(_ sender: Any) {
        viewController.loadBackups()
    }
    
    /**
     * Called when the Backup List (show window) menu item is invoked.
     */
    
    @IBAction func showBackupsList(_ sender: Any) {
        appDelegate.window?.makeKeyAndOrderFront(sender)
    }
}
