import Foundation

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else { fatalError(message) }
}

if CommandLine.arguments[1] == "read-snapshot" {
    let reader = UserDefaults.standard
    reader.setVolatileDomain(["DefaultTerminal": "stale", "DefaultEditor": "stale",
                              "HideContextMenuItems": true], forName: UserDefaults.argumentDomain)
    SharedPreferences.readSnapshot(from: URL(fileURLWithPath: CommandLine.arguments[2]), into: reader)
    let data = try PropertyListSerialization.data(
        fromPropertyList: reader.volatileDomain(forName: UserDefaults.argumentDomain),
        format: .binary, options: 0)
    let values = reader.volatileDomain(forName: UserDefaults.argumentDomain)
    check(reader[.defaultTerminal] == values["DefaultTerminal"] as? String, "typed string read differs")
    check(reader[.hideContextMenuItems] == (values["HideContextMenuItems"] as? Bool ?? false), "typed bool read differs")
    check(reader[.customMenuOptions] == values["CustomMenuOptions"] as? Data, "typed Data read differs")
    FileHandle.standardOutput.write(data)
    exit(0)
}

func readSnapshot(_ url: URL) throws -> [String: Any] {
    // Match the real host/extension process boundary: NSArgumentDomain is
    // process-wide and must never contaminate the host under test.
    let process = Process()
    process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    process.arguments = ["read-snapshot", url.path]
    let pipe = Pipe()
    process.standardOutput = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    check(process.terminationStatus == 0, "extension reader failed")
    return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
}

let root = URL(fileURLWithPath: CommandLine.arguments[1])
let domain = "OpenInTerminal-tests-" + root.lastPathComponent
let defaults = UserDefaults(suiteName: domain)!
let snapshot = root.appendingPathComponent("scripts/shared-settings.plist")

if CommandLine.arguments.last == "verify-relaunch" {
    check(defaults.string(forKey: "DefaultTerminal") == "Ghostty", "host lost terminal after process exit")
    check(defaults.string(forKey: "DefaultEditor") == "Visual Studio Code", "host lost editor after process exit")
    check(defaults.bool(forKey: SharedPreferences.migrationKey), "migration marker was not persisted")
    defaults.removePersistentDomain(forName: domain)
    print("PASS: host preferences survive a separate process")
    exit(0)
}

defaults.removePersistentDomain(forName: domain)
SharedPreferences.migrate([
    "DefaultTerminal": "Ghostty", "DefaultEditor": "Visual Studio Code",
    "FirstSetup": true, "LaunchAtLogin": true,
    "OIT_DefaultTerminalShortcut": ["keyCode": 17, "modifierFlags": 1048576]
], to: defaults)
check(defaults.string(forKey: "DefaultTerminal") == "Ghostty", "legacy terminal not migrated")
check(defaults.dictionary(forKey: "OIT_DefaultTerminalShortcut") != nil, "shortcut not migrated")
SharedPreferences.migrate(["DefaultTerminal": "Terminal"], to: defaults)
check(defaults.string(forKey: "DefaultTerminal") == "Ghostty", "legacy data overwrote new settings")

try SharedPreferences.writeSnapshot(from: defaults, to: snapshot)
var reader = try readSnapshot(snapshot)
check(reader["DefaultTerminal"] as? String == "Ghostty", "extension cannot read terminal")
check(reader["DefaultEditor"] as? String == "Visual Studio Code", "extension cannot read editor")
check(reader["LaunchAtLogin"] == nil, "host-only setting leaked into snapshot")
check(reader["OIT_DefaultTerminalShortcut"] == nil, "shortcut leaked into snapshot")
let mode = try FileManager.default.attributesOfItem(atPath: snapshot.path)[.posixPermissions] as! NSNumber
check(mode.intValue == 0o600, "snapshot permissions are not private")

// Cocoa bindings and typed setters must both publish before set() returns.
var notifications = 0
let token = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
                                                  object: defaults, queue: nil) { _ in
    notifications += 1
    try! SharedPreferences.writeSnapshot(from: defaults, to: snapshot)
}
defaults[.hideContextMenuItems] = true
reader = try readSnapshot(snapshot)
check((reader["HideContextMenuItems"] as? Bool ?? false), "typed setting did not publish synchronously")
defaults.setValue(false, forKey: "HideContextMenuItems")
reader = try readSnapshot(snapshot)
check(!(reader["HideContextMenuItems"] as? Bool ?? false), "Cocoa binding did not publish synchronously")
check(notifications >= 2, "missing UserDefaults notifications")

let options = Data("custom menu".utf8)
defaults[.customMenuOptions] = options
reader = try readSnapshot(snapshot)
check(reader["CustomMenuOptions"] as? Data == options, "custom menu Data did not round-trip")
defaults.removeObject(forKey: "CustomMenuOptions")
reader = try readSnapshot(snapshot)
check(reader["CustomMenuOptions"] as? Data == nil, "removed setting remained in extension")

defaults.removePersistentDomain(forName: domain)
try SharedPreferences.writeSnapshot(from: defaults, to: snapshot)
reader = try readSnapshot(snapshot)
check(reader["DefaultTerminal"] as? String == nil, "reset retained stale terminal")
check(reader["DefaultEditor"] as? String == nil, "reset retained stale editor")
try Data("broken plist".utf8).write(to: snapshot)
reader = try readSnapshot(snapshot)
check(reader["DefaultTerminal"] as? String == nil, "corrupt snapshot retained stale terminal")
try FileManager.default.removeItem(at: snapshot)
reader = try readSnapshot(snapshot)
check(!(reader["HideContextMenuItems"] as? Bool ?? false), "missing snapshot broke boolean defaults")

NotificationCenter.default.removeObserver(token)
defaults.set("Ghostty", forKey: "DefaultTerminal")
defaults.set("Visual Studio Code", forKey: "DefaultEditor")
SharedPreferences.migrate(["DefaultTerminal": "Terminal"], to: defaults)
check(defaults.string(forKey: "DefaultTerminal") == "Ghostty", "migration replaced existing host value")
check(defaults.synchronize(), "host could not flush its own domain")
print("PASS: migration, live updates, data, deletion, reset, missing/corrupt snapshots, permissions")
