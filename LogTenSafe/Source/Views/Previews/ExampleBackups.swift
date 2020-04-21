import Foundation
import AppKit

func exampleBackups() -> Array<Backup> {
    let data = NSDataAsset(name: "Backups")!.data
    return try! JSONDecoder().decode(Array<Backup>.self, from: data)
}
