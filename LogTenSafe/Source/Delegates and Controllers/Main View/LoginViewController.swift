import Foundation
import Defaults

/**
 The delegate for the `LoginViewController` receives login/logout events.
 */
@objc protocol LoginViewDelegate: AnyObject {
    
    /** Called when login is completed. */
    @objc optional func didLogIn()
    
    /** Called when logout is completed.*/
    @objc optional func didLogOut()
}

class LoginViewController: ObservableObject {
    /** Publisher that pipes whether or not the user is logged in. */
    @Published var loggedIn = false
    
    /** Publisher that pipes to the progress spinner on the login sheet. */
    @Published var loggingIn = false
    /**
     * Publisher that pipes to the login sheet's error text when a login error
     * occurs.
     */
    @Published var loginError: Error? = nil
    
    /** The delegate for login events. */
    weak var delegate: LoginViewDelegate?
    
    private let APIService: APIService
    
    init(APIService: APIService) {
        self.APIService = APIService
        
        Defaults.publisher(.JWT)
            .map { $0.newValue != nil }
            .receive(on: RunLoop.main).assign(to: &$loggedIn)
    }
    
    /**
     * Called when the user requests a login. Attempts to log the user in and
     * call the delegate.
     */
    
    func logIn(email: String, password: String) {
        loginError = nil
        loggingIn = true
        do {
            try APIService.logIn(login: Login(email: email, password: password)) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                        case .success():
                            self?.delegate?.didLogIn?()
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
     * JWT, and calls the delegate.
     */
    
    func logOut() {
        APIService.logOut()
        delegate?.didLogOut?()
    }
}
