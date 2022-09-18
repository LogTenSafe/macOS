import Foundation

class BackupsViewController: ObservableObject {
    
    /** Publisher that pipes to the progress spinner in the main backup list. */
    @Published var loadingBackups = false
    /** Publisher that pipes the list of Backups to the main view. */
    @Published var backups: Array<Backup> = []
    
    /**
     * Publisher that indicates if the current network operation is an upload.
     */
    @Published var makingBackup = false
    /**
     * Publisher that indicates if the current network operation is a download.
     */
    @Published var restoringBackup = false //TODO can be combined with the progress var?
    /** Publisher that pipes upload progress to the progress sheet. */
    @Published var backupProgress: Progress? = nil
    /** Publisher that pipes download progress to the progress sheet. */
    @Published var downloadProgress: Progress? = nil
    
    /** Any backup error that occurs. */
    @Published var error: Error? = nil
    
    private let APIService: APIService
    private let logbookService: LogbookService
    
    required init(APIService: APIService, logbookService: LogbookService) {
        self.APIService = APIService
        self.logbookService = logbookService
    }
    
    /**
     * Uses the API service to load a list of backups.
     */
    
    func loadBackups() {
        loadingBackups = true
        error = nil
        APIService.loadBackups { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let backups):
                        self?.backups = backups
                    case .failure(let error):
                        if !isAuthorizationError(error) { self?.error = error }
                }
                self?.loadingBackups = false
            }
        }
    }
    
    /** Called when a backup is received via ActionCable. */
    
    func receiveBackup(_ backup: Backup) {
        if backup.isDestroyed {
            backups.removeAll { $0 == backup }
        } else {
            if let existingIndex = backups.firstIndex(of: backup) {
                backups[existingIndex] = backup
            } else {
                backups.append(backup)
            }
            backups.sort { $1.createdAt! < $0.createdAt! }
        }
    }
    
    func addBackup() {
        do {
            try _ = logbookService.loadLogbook { logbookURL, finished in
                DispatchQueue.main.async { [weak self] in self?.makingBackup = true }
                let hostname: String = Host.current().localizedName ?? "unknown"
                let backup = DraftBackup(hostname: hostname, logbook: logbookURL)
                APIService.addBackup(backup, progressHandler: { [weak self] in self?.backupProgress = $0}) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                            case .success: break
                            case .failure(let error):
                                if !isAuthorizationError(error) { self?.error = error }
                        }
                        self?.makingBackup = false
                        self?.backupProgress = nil
                        finished()
                    }
                }
            }
        } catch (let error) {
            self.makingBackup = false
            self.backupProgress = nil
            self.error = error
        }
    }
    
    func restoreBackup(_ backup: Backup) {
        do {
            try _ = logbookService.loadLogbook { logbookURL, finished in
                DispatchQueue.main.async { [weak self] in self?.restoringBackup = true }
                
                APIService.downloadBackup(backup, destination: { tempfileURL, response in
                    guard response.statusCode == 200 else {
                        DispatchQueue.main.sync { [weak self] in
                            self?.error = LogTenSafeError.badStatusCode(response.statusCode)
                        }
                        return (URL(fileURLWithPath: "deleteme", relativeTo: FileManager.default.temporaryDirectory), [.removePreviousFile])
                    }
                    return (logbookURL, [.removePreviousFile])
                }, progressHandler: { [weak self] in self?.downloadProgress = $0 }) { [weak self] result in
                    switch result {
                        case .failure(let error):
                            if !isAuthorizationError(error) { self?.error = error }
                        default: break
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.restoringBackup = false
                        self?.downloadProgress = nil
                        finished()
                    }
                }
            }
        } catch (let error) {
            self.restoringBackup = false
            self.downloadProgress = nil
            self.error = error
        }
    }
}
