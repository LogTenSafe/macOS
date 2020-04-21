import SwiftUI

struct BackupItemView: View {
    let backup: Backup
    
    @EnvironmentObject private var viewController: MainViewController
    
    private static let titleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let flightDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let hoursFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    private static let sizeFormatter = ByteCountFormatter()
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(Self.titleDateFormatter.string(from: backup.createdAt!)).font(.headline)
                Text("from \(backup.hostname)").controlSize(.small)
                if backup.lastFlight != nil {
                    Text("Last flight: \(flightString(backup.lastFlight!))")
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(Self.sizeFormatter.string(fromByteCount: Int64(backup.logbook.size))).controlSize(.small)
                    Button("Restore") { self.viewController.restoreBackup(self.backup) }
                        .controlSize(.small)
                        .disabled(viewController.restoringBackup || !self.backup.logbook.analyzed)
                }
                Text("\(Self.hoursFormatter.string(from: NSNumber(value: backup.totalHours))!) hr").controlSize(.small)
            }
        }
    }
    
    private func flightString(_ flight: Flight) -> String {
        guard let hoursString = Self.hoursFormatter.string(from: NSNumber(value: flight.duration)) else {
            preconditionFailure("Couldn’t format flight duration")
        }
        return "\(Self.flightDateFormatter.string(from: flight.date!)) \(airport(identifier: flight.origin)) → \(airport(identifier: flight.destination)) (\(hoursString) hr)"
    }
    
    private func airport(identifier: String?) -> String {
        return identifier ?? "???"
    }
}

struct BackupItemView_Previews: PreviewProvider {
    static var previews: some View {
        BackupItemView(backup: exampleBackups()[0]).environmentObject(MainViewController())
    }
}
