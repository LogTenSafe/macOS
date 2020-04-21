import Foundation
import ActionCableClient

/**
 * This service manages the WebSockets connection with the backend. WebSockets
 * are used to receive realtime streaming updates on the user's backups. The
 * backend uses Action Cable to send these updates, and so this service uses an
 * Action Cable client.
 *
 * This generic class can be type-constrained to a Codable representing the JSON
 * data you expect to receive over the WebSocket.
 */

class ActionCableService<T> where T: Codable {
    
    /** The URL endpoint for the WebSocket. */
    var websocketURL: URLComponents
    
    /** Function called when a */
    var receive: (Result<T, Error>) -> Void
    private var client: ActionCableClient?
    private var channel: Channel?
    
    /** The encoder used when sending data to the backend. */
    let encoder: JSONEncoder
    
    /** The decoder used when receiving data from the backend. */
    let decoder: JSONDecoder
    
    /**
     * Creates a new Action Cable service.
     *
     * - Parameter URL: The WebSocket endpoint.
     * - Parameter receive: The function to invoke any time an object is
     *   received over the socket.
     * - Parameter encoder: The encoder to use when sending data.
     * - Parameter decoder: The decoder to use when receiving data.
     * - Parameter result: Contains the decoded object on success, or the error
     *   on failure.
     */
    
    init(URL: URL, receive: @escaping (_ result: Result<T, Error>) -> Void, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        self.receive = receive
        websocketURL = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
        self.encoder = encoder
        self.decoder = decoder
    }
    
    /**
     * Opens a WebSocket connection to the remote endpoint and subscribes to a
     * a channel, listening for new data.
     *
     * - Parameter JWT: The user's JSON Web Token, used as a bearer token for
     *   authorization.
     * - Parameter channel: The Action Cable channel to subscribe to.
     * - Returns: Whether or not a connection was successfully opened.
     */
    
    func start(JWT: String, channel: String) -> Bool {
        websocketURL.queryItems = [.init(name: "jwt", value: JWT)]
        guard let URL = websocketURL.url else { return false }
        client = ActionCableClient(url: URL, origin: appURL.absoluteString)
        
        client!.onConnected = { [weak self] in
            guard let this = self else { return }
            
            this.channel = this.client!.create("BackupsChannel", identifier: nil, autoSubscribe: false)
            this.channel!.onReceive = { [weak self] (message, error) in
                guard let this = self else { return }
                if let error = error {
                    this.receive(.failure(error))
                } else if let message = message as? String {
                    do {
                        guard let data = message.data(using: .utf8) else {
                            this.receive(.failure(LogTenSafeError.invalidWebSocketData(data: message)))
                            return
                        }
                        let object = try this.decoder.decode(T.self, from: data)
                        this.receive(.success(object))
                    } catch (let error) {
                        this.receive(.failure(error))
                    }
                }
            }
            this.channel!.subscribe()
        }
        
        client!.connect()
        return true
    }
    
    /**
     * Stops listening to a WebSocket connection and disconnects from the
     * socket. Does nothing if the client is already disconnected.
     */

    func stop() {
        client?.disconnect()
        client = nil
    }
}

