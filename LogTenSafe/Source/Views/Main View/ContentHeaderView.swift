import SwiftUI
import Defaults

struct ContentHeaderView: View {
    @EnvironmentObject private var viewController: MainViewController
    @Default(.autoBackup) var autoBackup
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Toggle(isOn: $autoBackup) {
                    Text("Check for logbook changes and automatically back up")
                }.disabled(viewController.disableAutoBackup)
                
                if viewController.disableAutoBackup {
                    Text("You must click “Back Up Now” before you can turn on auto-backups.").lineLimit(nil).font(.caption)
                } else {
                    Text("New backups will only be added if your logbook has changed since the last time it was backed up.").lineLimit(nil).font(.caption)
                }
            }
            Spacer()
            Button(action: { self.viewController.backupsViewController.addBackup() }) {
                Text("Back Up Now")
            }.disabled(viewController.backupsViewController.makingBackup)
        }
    }
}

struct BackupView_Previews: PreviewProvider {
    static var previews: some View {
        ContentHeaderView().environmentObject(MainViewController())
    }
}
