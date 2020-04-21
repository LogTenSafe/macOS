import SwiftUI
import Defaults
import Combine

struct MainView: View {
    @EnvironmentObject private var viewController: MainViewController
    
    var body: some View {
        VStack(alignment: .leading) {
            ContentHeaderView().padding()
            BackupListView(backups: viewController.backups)
        }.frame(minWidth: 500, minHeight: 250)
            .sheet(isPresented: $viewController.sheetActive) {
                if self.viewController.currentSheet == .error {
                    AlertSheetView(error: self.$viewController.error).environmentObject(self.viewController) //TODO why is this necessary
                } else if self.viewController.currentSheet == .login {
                     LoginSheetView().environmentObject(self.viewController)
                } else if self.viewController.currentSheet == .downloadProgress {
                    ProgressSheetView(prompt: "Downloading backup…", progress: self.viewController.downloadProgress!)
                } else if self.viewController.currentSheet == .uploadProgress {
                    ProgressSheetView(prompt: "Uploading logbook…", progress: self.viewController.backupProgress!)
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let state = MainViewController()
        state.backups = exampleBackups()
        return MainView().environmentObject(state)
    }
}
