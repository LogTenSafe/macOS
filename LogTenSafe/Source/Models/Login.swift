fileprivate struct User: Codable {
    var email: String
    var password: String
}

/** Stores credentials used for logging in a user. */

struct Login: Codable {
    fileprivate var user: User
    
    /**
     * Creates a new User object for storing credentials.
     *
     * - Parameter email: The email address.
     * - Parameter password: The user's password.
     */
    
    init(email: String, password: String) {
        user = User(email: email, password: password)
    }
}
