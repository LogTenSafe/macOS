import SwiftUI

struct BackupListView: View {
    @EnvironmentObject private var viewController: BackupsViewController
    
    var body: some View {
        List(viewController.backups, id: \.id) { backup in
            VStack {
                BackupItemView(backup: backup,
                               restoringBackup: viewController.restoringBackup,
                               restoreBackup: viewController.restoreBackup)
                Divider()
            }
        }
    }
}

struct BackupListView_Previews: PreviewProvider {
    private static let controller = MainViewController()
    
    static var previews: some View {
        BackupListView()
            .environmentObject(controller.backupsViewController)
    }
}
