import Foundation
import AppKit
import Defaults
import Checksum
import Dispatch

/**
 * This service manages backing up the logbook at regular intervals. Because of
 * sandbox limitations, this can no longer be done by a daemon, and must be done
 * while the app is running.
 */

class AutoBackupService {
    private var logbookService: LogbookService
    private var APIService: APIService
    
    private static let checkInterval: TimeInterval = 86400/3 // 3 times a day
    
    /**
     * Set this to `true` to begin the auto-backup timer, or `false` to stop it.
     */
    
    var started = false {
        didSet {
            started ? start() : stop()
        }
    }
    
    private var timer: Timer? = nil
    
    init(logbookService: LogbookService = .init(), APIService: APIService = .init()) {
        self.logbookService = logbookService
        self.APIService = APIService
    }
    
    /**
     * Starts the auto-backup timer, beginning regular automatic backups.
     */
    
    func start() {
        timer?.invalidate()
        timer = Timer(timeInterval: Self.checkInterval, target: self, selector: #selector(automatiallyBackUp), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .default)
    }
    
    /**
     * Stops the auto-backup timer.
     */
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func automatiallyBackUp() throws {
        print("Checking for changes to LogTen Pro logbook")
        let didOpenFile = try logbookService.loadLogbook(allowPrompt: false) { logbookURL, finished in
            logbookURL.checksum(algorithm: .md5, queue: DispatchQueue.main) { [unowned self] result in
                switch result {
                    case .success(let checksum):
                        if self.logbookChanged(checksum: checksum) {
                            print("Changes detected. Uploading…")
                            self.uploadLogbook(localURL: logbookURL, checksum: checksum) {
                                finished()
                                print("Upload finished")
//                                self.group.leave()
                            }
                        }
                        else {
                            print("No changes detected")
//                            self.group.leave()
                        }
                    case .failure(let error):
                        self.handleError(error)
//                        self.group.leave()
                }
            }
        }
        
        if !didOpenFile {
            print("Couldn’t open logbook file")
//            group.leave()
        }
    }
    
    private func logbookChanged(checksum: String) -> Bool {
        guard let lastChecksum = Defaults[.lastChecksum] else{ return true }
        return lastChecksum != checksum
    }
    
    private func uploadLogbook(localURL: URL, checksum: String, callback: @escaping () -> Void) {
        let hostname: String = Host.current().localizedName ?? "unknown"
        let backup = DraftBackup(hostname: hostname, logbook: localURL)
        self.APIService.addBackup(backup, handler:  { _ in
            Defaults[.lastChecksum] = checksum
            callback()
        })
    }
    
    private func handleError(_ error: Error) {
        print("CheckForLogbookChanges failed to complete.")
        print(error.localizedDescription)
//        group.leave()
    }
}
