import Foundation
import Alamofire
import Defaults

/**
 * This service class is the interface between the application and the API
 * backend.
 */

public class APIService {
    fileprivate var authHeader: String? {
        if let JWT = Defaults[.JWT] {
            return "Bearer \(JWT)"
        } else {
            return nil
        }
    }
    private var authInterceptor: AuthHeaderInterceptor { return AuthHeaderInterceptor(service: self) }
    
    /**
     * Logs a user in.
     *
     * - Parameter login: The credentials to use.
     * - Parameter handler: Called with the result of the login operation.
     * - Parameter result: The result of the login operation. Contains the error
     *   if failed.
     */
    
    func logIn(login: Login, handler: @escaping(_ result: Result<Void, Error>) -> Void = { _ in }) throws {
        APIRequest("login.json", method: .post, body: login, bodyDecoder: NoBody.self) { [weak self] response in
            self?.setJWTFromResponse(response)
            switch response.result {
                case .success: handler(.success(()))
                case .failure(let error): handler(.failure(error))
            }
        }
    }
    
    /** Logs a user out. */
    
    func logOut() {
        APIRequest("logout.json", method: .delete, bodyDecoder: NoBody.self) { _ in
            Defaults[.JWT] = nil
        }
    }
    
    /**
     * Loads the logged-in user's backups.
     *
     * - Parameter handler: Called with the result of the operation after the
     *   backups have been loaded.
     * - Parameter result: The result of the load operation. Contains the loaded
     *   Backups on success, or the error on failure.
     */
    
    func loadBackups(handler: @escaping (_ result: Result<Array<Backup>, AFError>) -> Void = { _ in }) {
        APIRequest("backups.json", bodyDecoder: [Backup].self) { [weak self] response in
            self?.deleteJWTIfAuthorizationFails(response.result)
            handler(response.result)
        }
    }
    
    /**
     * Uploads a backup to the server.
     *
     * - Parameter backup: The backup data to upload.
     * - Parameter progressHandler: A handler that is repeatedly called with a
     *   `Progress` object during the upload.
     * - Parameter handler: Called when the upload is complete with the result
     *   of the operation.
     * - Parameter result: The result of the backup operation. Contains the
     *   created Backup on success, or the error on failure.
     */
    
    public func addBackup(_ backup: DraftBackup, progressHandler: @escaping Request.ProgressHandler = { _ in },  handler: @escaping (_ result: Result<Backup, Error>) -> Void = { _ in }) {
        AF.upload(multipartFormData: { formData in
            formData.append(Data(backup.hostname.utf8), withName: "backup[hostname]")
            formData.append(backup.logbook, withName: "backup[logbook]")
        }, to: appURL.appendingPathComponent("backups.json"), interceptor: authInterceptor)
            .uploadProgress(closure: progressHandler)
            .responseDecodable(of: Backup.self) { [weak self] response in
                self?.deleteJWTIfAuthorizationFails(response.result)
                switch response.result {
                    case .success(let backup): handler(.success(backup))
                    case .failure(let error): handler(.failure(error))
                }
        }
    }
    
    /**
     * Downloads the logfile for a Backup.
     *
     * - Parameter backup: The backup to download the logfile for.
     * - Parameter destination: Where to download the logfile to.
     * - Parameter progressHandler: A handler that is repeatedly called with a
     *   `Progress` object during the download.
     * - Parameter handler: Called when the download is complete with the result
     *   of the operation.
     * - Parameter result: The result of the download operation. Contains a
     *   local file URL to the downloaded data on success, or the error on
     *   failure.
     */
    
    func downloadBackup(_ backup: Backup, destination: @escaping DownloadRequest.Destination, progressHandler: @escaping Request.ProgressHandler = { _ in }, handler: @escaping (_ result: Result<URL?, AFError>) -> Void) {
        guard let URL = backup.downloadURL else { return }
        
        AF.download(URL, interceptor: authInterceptor, to: destination)
            .downloadProgress(closure: progressHandler)
            .response { [weak self] response in
            self?.deleteJWTIfAuthorizationFails(response.result)
            handler(response.result)
        }
    }
    
    private struct NoBody: Codable {}
    
    private func APIRequest<RequestType, ResponseType>(_ path: String, method: HTTPMethod = .get, body: RequestType? = nil, bodyDecoder: ResponseType.Type, handler: @escaping(AFDataResponse<ResponseType>) -> Void = { _ in }) where RequestType: Encodable, ResponseType: Decodable {
        AF.request(appURL.appendingPathComponent(path), method: method, parameters: body, encoder: JSONParameterEncoder.default, interceptor: authInterceptor).validate().responseDecodable(of: ResponseType.self) { [weak self] response in
            self?.deleteJWTIfAuthorizationFails(response.result)
            handler(response)
        }
    }
    
    private func APIRequest<ResponseType>(_ path: String, method: HTTPMethod = .get, bodyDecoder: ResponseType.Type, handler: @escaping(AFDataResponse<ResponseType>) -> Void = { _ in }) where ResponseType: Decodable {
        APIRequest(path, method: method, body: Optional<NoBody>.none, bodyDecoder: bodyDecoder, handler: handler)
    }
    
    private func setJWTFromResponse(_ response: DataResponse<APIService.NoBody, AFError>) {
        if let JWT = response.response?.value(forHTTPHeaderField: "Authorization") {
            Defaults[.JWT] = String(JWT.dropFirst(7)) // "Bearer "
        }
    }
    
    private func deleteJWTIfAuthorizationFails<T>(_ result: Result<T, AFError>) {
        switch result {
            case .failure(let error):
                if isAuthorizationError(error) { Defaults[.JWT] = nil }
            default: break
        }
    }
}

fileprivate struct AuthHeaderInterceptor: RequestInterceptor {
    let service: APIService
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let authHeader = service.authHeader {
            urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }
}
