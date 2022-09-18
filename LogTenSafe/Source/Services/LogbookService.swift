import Foundation
import Defaults
import AppKit

/**
 * This service class manages reading from and writing to the LogTen Pro logbook
 * file.
 */

public class LogbookService {
    
    /**
     * Loads the LogTen Pro logbook. If a security-scoped bookmark already
     * exists for the file, it is activated and the logbook is yielded to
     * `callback`. Otherwise, a file chooser is displayed allowing the user to
     * locate the logbook file and grant Sandbox access to this application.
     *
     * - Parameter allowPrompt: If true, will display the file chooser if
     *   necessary (if no security-scoped bookmark has been created).
     * - Parameter callback: The logbook file URL is made available to this
     *   block. At this point the URL can be used for reading and writing.
     * - Parameter file: A local file URL which can be used to read from and
     *   write to the logbook file.
     * - Parameter done: Invoke this callback when finished accessing the file,
     *   to clean up Security resources.
     * - Returns: `true` if the file was accessed successfuly, or `false` if
     *   it could not be accessed (e.g., if `allowPrompt` was false but no
     *   security-scoped bookmark was found).
     */
    
    public func loadLogbook(allowPrompt: Bool = true, callback: (_ file: URL, _ done: @escaping (() -> Void)) -> Void) throws -> Bool {
        if let bookmarkData = Defaults[.logbookData] {
            var isStale = false
            let logboookURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, bookmarkDataIsStale: &isStale)
            if !isStale {
                if logboookURL.startAccessingSecurityScopedResource() {
                    callback(logboookURL) { logboookURL.stopAccessingSecurityScopedResource() }
                    return true
                }
            }
        }
        
        if allowPrompt {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            panel.title = "Choose Logbook"
            panel.message = "Choose the LogTenCoreDataStore.sql file:"
            panel.prompt = "Choose"
            panel.directoryURL = defaultLogbookURL
            panel.allowedFileTypes = ["org.iso.sql"]
            
            guard panel.runModal() == .OK else { return false }
            guard let logboookURL = panel.url else { return false }
            
            let bookmarkData = try logboookURL.bookmarkData(options: .withSecurityScope)
            Defaults[.logbookData] = bookmarkData
            
            callback(logboookURL) { }
            return true
        }
        
        return false
    }
}
