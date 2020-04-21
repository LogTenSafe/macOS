import SwiftUI

struct BackupListView: View {
    var backups: Array<Backup>
    
    var body: some View {
        List(backups, id: \.id) { backup in
            VStack {
                BackupItemView(backup: backup)
                Divider()
            }
        }
    }
}

struct BackupListView_Previews: PreviewProvider {
    static var previews: some View {
        BackupListView(backups: exampleBackups())
    }
}
