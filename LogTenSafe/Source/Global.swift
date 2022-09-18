import Foundation
import Defaults
import Alamofire

extension Defaults.Keys {
    /** User defaults key for the JSON web token. */
    static let JWT = Key<String?>("JWT", default: nil)
    
    /**
     * User defaults key for the security-scoped bookmark for the local logbook
     * file.
     */
    static let logbookData = Key<Data?>("logbookData", default: nil)
    
    /**
     * User defaults key for the MD5 checksum of the last logbook file to be
     * uploaded.
     */
    static let lastChecksum = Key<String?>("lastChecksum", default: nil)
    
    /** User defaults key for the state of the "auto-backup" setting. */
    static let autoBackup = Key<Bool>("autoBackup", default: false)
}

let defaultLogbookURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Containers/com.coradine.LogTenProX/Data/Documents/LogTenProData/LogTenCoreDataStore.sql")

func isAuthorizationError(_ error: Error) -> Bool {
    switch error {
        case AFError.responseValidationFailed(let reason):
            switch reason {
                case .unacceptableStatusCode(let code):
                    return code == 401
                default: return false
        }
        default: return false
    }
}

/** Application errors. */

public enum LogTenSafeError: Error {
    
    /** Thrown when login credentials are invalid. */
    case invalidLogin
    
    /**
     * Thrown when data received from the WebSocket can't be parsed.
     *
     * * `data`: The invalid websocket data.
     */
    case invalidWebSocketData(data: String)
    
    /**
     * Thrown when LogTenSafe returns a non-200 status code.
     *
     * * `statusCode`: The HTTP status code.
     */
    case badStatusCode(_ statusCode: Int)
}

extension LogTenSafeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .invalidLogin: return "Your email or password was incorrect."
            case .invalidWebSocketData: return "There was a problem with LogTenSafe.com."
            case let .badStatusCode(statusCode): return "LogTenSafe.com responded with a \(statusCode) error."
        }
    }
}

/** The API endpoint. */
public let appURL: URL = {
    if CommandLine.arguments.contains("--localhost") {
        return URL(string: "http://localhost:5100")
    } else {
        return URL(string: "https://app.logtensafe.com")
    }
}()!

/** The WebSockets endpoint. */
public let websocketsURL: URL = {
    if CommandLine.arguments.contains("--localhost") {
        return URL(string: "ws://localhost:28080/cable")
    } else {
        return URL(string: "wss://app.logtensafe.com/cable")
    }
}()!
