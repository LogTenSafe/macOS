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
@objc class MainViewController: NSObject, ObservableObject, LoginViewDelegate {
    
    /** The API service to use. */
    let APIService: APIService
    
    /** The local logbook file service to use. */
    let logbookService: LogbookService
    
    /** The automatic backup service to use. */
    let autoBackupService: AutoBackupService
    
    /** The Action Cable WebSockets client to use. */
    var backupWSService: ActionCableService<Backup>? = nil
    
    /** The controller for the Login sheet. */
    let loginViewController: LoginViewController
    /** The controller for the Backups list. */
    let backupsViewController: BackupsViewController
    
    /** Publisher that pipes the auto-backup setting to the UI. */
    @Published var disableAutoBackup = false
    
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
        
        loginViewController = LoginViewController(APIService: APIService)
        backupsViewController = BackupsViewController(APIService: APIService, logbookService: logbookService)
        
        super.init()
        
        loginViewController.delegate = self
        
        //TODO do we need the whole big-ass type annotation here?
        let sheetPublisher: Publishers.Map<Publishers.CombineLatest4<AnyPublisher<Defaults.KeyChange<String?>, Never>, Published<Progress?>.Publisher, Published<Progress?>.Publisher, Published<Error?>.Publisher>, MainViewSheet> = Defaults.publisher(.JWT).combineLatest(
            backupsViewController.$backupProgress,
            backupsViewController.$downloadProgress,
            $error
        ).map { JWT, backupProgress, downloadProgress, error in
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
                        case .success(let backup):
                            self?.backupsViewController.receiveBackup(backup)
                        case .failure(let error): self?.error = error
                    }
                })
                _ = self?.backupWSService!.start(JWT: JWT, channel: "BackupsChannel")
            } else {
                self?.backupWSService?.stop()
            }
        }.store(in: &cancellables)
        
        backupsViewController.$error.assign(to: &$error)
    }
    
    deinit {
        for c in cancellables { c.cancel() }
    }
    
    func didLogIn() {
        backupsViewController.loadBackups()
    }
    
    func didLogOut() {
        backupsViewController.backups.removeAll()
    }
}

