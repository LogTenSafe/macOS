import Combine
import Dispatch
import Foundation
import Alamofire
import Defaults

/**
 * An enum representing which sheet is being shown over the main window. Since
 * only one sheet view is associated with a window, this enum is used to
 * determine which subview is rendered into that view.
 */

enum MainViewSheet {
    
    /** The generic "error occurred" sheet. */
    case error
    
    /** The login form sheet. */
    case login
    
    /** The upload progress bar sheet. */
    case uploadProgress
    
    /** The download progress bar sheet. */
    case downloadProgress
    
    /** No sheet is currently being displayed. */
    case none
}

/**
 * This hefty class is the primary controller between the main view (the list of
 * backups and all primary application controls) and the various services that
 * communicate with the filesystem and backend (APIService, LogbookService,
 * etc.).
 *
 * This class mainly exposes reactive bindings that views can use to bind to
 * data received by the services, and listens for reactive changes to UI
 * controls, updating backend services as necessary.
 *
 * Because ObservableObject requires one object be shared by all views in a view
 * hierarchy, this class overfloweth with functionality, providing any and all
 * bindings that any subview might need to render itself or expose its
 * functionality.
 */

@available(OSX 11.0, *)
@objc class MainViewController: NSObject, ObservableObject {
    
    /** The API service to use. */
    let APIService: APIService
    
    /** The local logbook file service to use. */
    let logbookService: LogbookService
    
    /** The automatic backup service to use. */
    let autoBackupService: AutoBackupService
    
    /** The Action Cable WebSockets client to use. */
    var backupWSService: ActionCableService<Backup>? = nil
    
    /** Publisher that pipes whether or not the user is logged in. */
    @Published var loggedIn = false
    
    /** Publisher that pipes the auto-backup setting to the UI. */
    @Published var disableAutoBackup = false
    
    /** Publisher that pipes to the progress spinner on the login sheet. */
    @Published var loggingIn = false
    /**
     * Publisher that pipes to the login sheet's error text when a login error
     * occurs.
     */
    @Published var loginError: Error? = nil
    
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
    
    /** Publisher that pipes an error to the generic error sheet. */
    @Published var error: Error? = nil
    
    /** Publisher that pipes to the view which sheet is shown (if any). */
    @Published var currentSheet: MainViewSheet = .none
    /** Publisher that pipes to the view whether a sheet should be displayed. */
    @Published var sheetActive = false
    
    private var cancellables = Set<AnyCancellable>()
    
    /**
     * Creates an instance with the default service classes.
     */
    
    convenience override init() {
        self.init(APIService: .init(), logbookService: .init())
    }
    
    /**
     * Creates an instance with the given service classes.
     */
    
    required init(APIService: APIService, logbookService: LogbookService) {
        self.APIService = APIService
        self.logbookService = logbookService
        self.autoBackupService = AutoBackupService(logbookService: logbookService, APIService: APIService)
        
        super.init()
        
        Defaults.publisher(.JWT)
            .map { $0.newValue != nil }
            .receive(on: RunLoop.main).assign(to: &$loggedIn)
        
        //TODO do we need the whole big-ass type annotation here?
        let sheetPublisher: Publishers.Map<Publishers.CombineLatest4<AnyPublisher<Defaults.KeyChange<String?>, Never>, Published<Progress?>.Publisher, Published<Progress?>.Publisher, Published<Error?>.Publisher>, MainViewSheet> = Defaults.publisher(.JWT).combineLatest($backupProgress, $downloadProgress, $error).map { JWT, backupProgress, downloadProgress, error in
            if error != nil { return .error }
            if JWT.newValue == nil { return .login }
            if backupProgress != nil { return .uploadProgress }
            if downloadProgress != nil { return .downloadProgress }
            return .none
        }
        sheetPublisher.receive(on: RunLoop.main).assign(to: &$currentSheet)
        sheetPublisher.map { $0 != .none }.receive(on: RunLoop.main).assign(to: &$sheetActive)
        
        autoBackupService.started = Defaults[.autoBackup]
        Defaults.publisher(.autoBackup)
            .map { $0.newValue }
            .receive(on: RunLoop.main).assign(to: \.started, on: autoBackupService)
            .store(in: &cancellables)
        Defaults.publisher(.logbookData)
            .map { $0.newValue == nil }
            .receive(on: RunLoop.main).assign(to: &$disableAutoBackup)
        
        Defaults.publisher(.JWT).map { $0.newValue }.receive(on: RunLoop.main).sink { [weak self] JWT in
            if let JWT = JWT {
                self?.backupWSService?.stop()
                self?.backupWSService = ActionCableService(URL: websocketsURL, receive: { [weak self] message in
                    switch message {
                        case .success(let backup): self?.receiveBackup(backup)
                        case .failure(let error): self?.error = error
                    }
                })
                _ = self?.backupWSService!.start(JWT: JWT, channel: "BackupsChannel")
            } else {
                self?.backupWSService?.stop()
            }
        }.store(in: &cancellables)
    }
    
    deinit {
        for c in cancellables { c.cancel() }
    }
    
    /**
     * Called when the user requests a login. Attempts to log the user in and
     * load their backup list.
     */
    
    func logIn(email: String, password: String) {
        loginError = nil
        loggingIn = true
        do {
            try APIService.logIn(login: Login(email: email, password: password)) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                        case .success():
                            self?.loadBackups()
                        case .failure(let error):
                            if isAuthorizationError(error) {
                                self?.loginError = LogTenSafeError.invalidLogin
                            }
                            else {
                                self?.loginError = error
                        }
                    }
                    self?.loggingIn = false
                }
            }
        } catch (let error) {
            loginError = error
            loggingIn = false
        }
    }
    
    /**
     * Called when the user requests a logout. Logs the user out, deletes the
     * JWT, and clears the Backup list from memory.
     */
    
    func logOut() {
        APIService.logOut()
        self.backups.removeAll()
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
    
    private func receiveBackup(_ backup: Backup) {
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
    
    func clearError() {
        error = nil
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
                
                APIService.downloadBackup(backup, destination: { _, _ in
                    (logbookURL, [.removePreviousFile])
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
