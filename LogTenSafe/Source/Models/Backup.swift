import Foundation

/** A logbook file, parsed from JSON, attached to a Backup. */

public struct Logbook: Codable, Hashable {
    
    /** The file size, in bytes. */
    var size: UInt32
    
    /** Whether the Active Storage analysis jobs have finished. */
    var analyzed: Bool
}

/** A flight, parsed from JSON, attached to a Backup. */

public struct Flight: Codable, Hashable {
    private var dateString: String
    
    /** The location identifier for the origin airport, if any. */
    var origin: String?
    
    /** The location identifier for the destination airport, if any. */
    var destination: String?
    
    /** The duration of the flight, in hours. */
    var duration: Float
    
    /** The date and time the flight began. */
    var date: Date? { return Self.dateParser.date(from: dateString) }
    
    private static let dateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-mm-dd"
        return formatter
    }()
    
    enum CodingKeys: String, CodingKey {
        case dateString = "date"
        case origin = "origin"
        case destination = "destination"
        case duration = "duration"
    }
}

/** A backup, parsed from JSON, received from the backend. */

public struct Backup: Codable, Identifiable, Equatable, Hashable {
    
    /** The database ID. */
    public var id: UInt32
    
    /** The attached logbook file. */
    public var logbook: Logbook
    
    /** The latest flight in the logbook. */
    public var lastFlight: Flight?
    
    /** The total number of hours across all flights in the logbook. */
    public var totalHours: Float { optionalTotalHours ?? 0.0 }
    
    /** The hostname of the computer that uploaded the logbook. */
    public var hostname: String
    
    /** The date this record was created. */
    public var createdAt: Date? { return Self.datetimeParser.date(from: createdAtString) }
    
    /** A temporary URL where the logbook file can be downloaded. */
    public var downloadURL: URL? { return appURL.appendingPathComponent(downloadURLString) }
    
    /**
      * True if the JSON response was from a DELETE operation that destoyed this
     * logbook. */
    public var isDestroyed = false
    
    private var createdAtString: String
    private var optionalTotalHours: Float?
    private var downloadURLString: String
    
    private static let datetimeParser: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
        return formatter
    }()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case logbook = "logbook"
        case createdAtString = "created_at"
        case lastFlight = "last_flight"
        case optionalTotalHours = "total_hours"
        case hostname = "hostname"
        case downloadURLString = "download_url"
        case isDestroyed = "destroyed"
    }
    
    public static func == (_ a: Self, _ b: Self) -> Bool {
        return a.id == b.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/** Backup data to be encoded to JSON and sent to the backend. */

public struct DraftBackup: Encodable {
    
    /** The hostname of the computer uploading the backup. */
    public var hostname: String
    
    /** The filesystem URL of the logbook being uploaded. */
    public var logbook: URL
}
