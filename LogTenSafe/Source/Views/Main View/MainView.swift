import SwiftUI
import Defaults
import Combine

struct MainView: View {
    @EnvironmentObject private var viewController: MainViewController
    
    var body: some View {
        VStack(alignment: .leading) {
            ContentHeaderView().padding()
            BackupListView()
                .environmentObject(viewController.backupsViewController)
        }.frame(minWidth: 500, minHeight: 250)
            .sheet(isPresented: $viewController.sheetActive) {
                if self.viewController.currentSheet == .error {
                    AlertSheetView(error: self.$viewController.error)
                } else if self.viewController.currentSheet == .login {
                    LoginSheetView().environmentObject(self.viewController.loginViewController)
                } else if self.viewController.currentSheet == .downloadProgress {
                    ProgressSheetView(prompt: "Downloading backup…", progress: self.viewController.backupsViewController.downloadProgress!)
                } else if self.viewController.currentSheet == .uploadProgress {
                    ProgressSheetView(prompt: "Uploading logbook…", progress: self.viewController.backupsViewController.backupProgress!)
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MainViewController()
        state.backupsViewController.backups = exampleBackups()
        return MainView().environmentObject(state)
    }
}
