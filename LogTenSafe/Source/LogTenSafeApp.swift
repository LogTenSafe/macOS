import SwiftUI
import Bugsnag

@main
struct LogTenSafeApp: App {
    @State var viewController = MainViewController()
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(viewController)
        }.commands {
            CommandGroup(after: .appInfo) {
                Button(action: { NSWorkspace.shared.open(appURL) }, label: { Text("Visit Website") })
            }
            CommandGroup(replacing: .newItem) {
                Button(action: { viewController.addBackup() }, label: { Text("Back Up Now") })
            }
            CommandGroup(before: .toolbar) {
                Button(action: { viewController.loadBackups() }, label: { Text("Refresh List") })
            }
            CommandGroup(before: .appTermination) {
                Button(action: { viewController.logOut() }, label: { Text("Log Out") })
            }
        }
    }
    
    init() {
        Bugsnag.start(withApiKey: "730d83065b6d027cbded0b6e99314b22")
        viewController.loadBackups()
    }
}
