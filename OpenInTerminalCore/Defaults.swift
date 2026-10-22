//
//  Defaults.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

/// Keep host preferences in its own domain, where unsigned builds can also save.
/// The Finder extension receives a read-only snapshot via Application Scripts.
public var Defaults: UserDefaults = UserDefaults.standard

public enum SharedPreferences {
    static let hostID = "wang.jianing.app.OpenInTerminal"
    static let extensionID = hostID + ".OpenInTerminalFinderExtension"
    static let migrationKey = "LegacyPreferencesMigrated"
    static var observer: NSObjectProtocol?
    private static let snapshotLock = NSLock()

    // Share only preferences consumed by the Finder extension. Shortcuts and
    // launch-at-login settings remain private to the host app.
    static let sharedKeys = [
        "DefaultTerminal", "DefaultEditor", "HideContextMenuItems",
        "ContextMenuUseSubmenu", "CustomMenuOptions", "CustomMenuApplyToToolbar",
        "CustomMenuApplyToContext", "CustomMenuIconOption", "PathEscapeOption",
        "KittyCommand", "NeovimCommand", "GitkrakenCommand"
    ]

    static func snapshotURL() throws -> URL {
        let scripts = try FileManager.default.url(for: .applicationScriptsDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
        let directory = Bundle.main.bundleIdentifier == extensionID
            ? scripts
            : scripts.deletingLastPathComponent().appendingPathComponent(extensionID)
        return directory.appendingPathComponent("shared-settings.plist")
    }

    /// Copy existing values once, without overwriting preferences already saved
    /// in the host domain. Leave the old domain intact for rollback.
    static func migrate(_ legacy: [String: Any], to defaults: UserDefaults) {
        guard !defaults.bool(forKey: migrationKey) else { return }
        for (key, value) in legacy where defaults.object(forKey: key) == nil {
            defaults.set(value, forKey: key)
        }
        defaults.set(true, forKey: migrationKey)
    }

    static func writeSnapshot(from defaults: UserDefaults, to url: URL) throws {
        snapshotLock.lock()
        defer { snapshotLock.unlock() }
        var values = [String: Any]()
        for key in sharedKeys {
            values[key] = defaults.object(forKey: key)
        }
        let data = try PropertyListSerialization.data(fromPropertyList: values,
                                                       format: .binary, options: 0)
        if (try? Data(contentsOf: url)) == data { return }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600],
                                              ofItemAtPath: url.path)
    }

    static func readSnapshot(from url: URL, into defaults: UserDefaults) {
        let values: [String: Any]
        if let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
           let dictionary = plist as? [String: Any] {
            values = dictionary.filter { sharedKeys.contains($0.key) }
        } else {
            values = [:]
        }
        // Replace the whole snapshot so deletions and resets also reach a
        // running extension. This domain is in memory only; the extension never
        // writes to the host's preferences or to the shared file.
        defaults.setVolatileDomain(values, forName: UserDefaults.argumentDomain)
    }

    public static func startHost() {
        guard Bundle.main.bundleIdentifier == hostID, observer == nil else { return }
        if !Defaults.bool(forKey: migrationKey) {
            let legacy = UserDefaults(suiteName: Constants.Id.Group)?
                .persistentDomain(forName: Constants.Id.Group) ?? [:]
            migrate(legacy, to: Defaults)
        }
        observer = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
                                                          object: Defaults, queue: nil) { _ in
            publish()
        }
        publish()
    }

    public static func publish() {
        guard Bundle.main.bundleIdentifier == hostID else { return }
        do {
            try writeSnapshot(from: Defaults, to: snapshotURL())
        } catch {
            NSLog("Unable to share Finder preferences: %@", error.localizedDescription)
        }
    }

    public static func refreshExtension() {
        guard Bundle.main.bundleIdentifier == extensionID else { return }
        do {
            readSnapshot(from: try snapshotURL(), into: Defaults)
        } catch {
            Defaults.setVolatileDomain([:], forName: UserDefaults.argumentDomain)
            NSLog("Unable to read Finder preferences: %@", error.localizedDescription)
        }
    }
}

public class DefaultsKeys {
    fileprivate init() {}
}

public class DefaultsKey<ValueType>: DefaultsKeys {
    let _key: String
    
    init(_ key: String) {
        self._key = key
    }
}

public extension DefaultsKeys {
    // Preferences - General
    static let firstSetup = DefaultsKey<Bool>("FirstSetup")
    static let launchAtLogin = DefaultsKey<Bool>("LaunchAtLogin")
    static let quickToggle = DefaultsKey<Bool>("QuickToggle")
    static let quickToggleType = DefaultsKey<String>("QuickToggleType")
    static let hideStatusItem = DefaultsKey<Bool>("HideStatusItem")
    static let hideContextMenuItems = DefaultsKey<Bool>("HideContextMenuItems")
    static let contextMenuUseSubmenu = DefaultsKey<Bool>("ContextMenuUseSubmenu")
    static let defaultTerminal = DefaultsKey<String>("DefaultTerminal")
    static let defaultEditor = DefaultsKey<String>("DefaultEditor")
    // Preferences - Custom
    static let terminalNewOption = DefaultsKey<String>("TerminalNewOption")
    static let iTermNewOption = DefaultsKey<String>("iTermNewOption")
    static let customMenuOptions = DefaultsKey<Data>("CustomMenuOptions")
    static let customMenuApplyToToolbar = DefaultsKey<Bool>("CustomMenuApplyToToolbar")
    static let customMenuApplyToContext = DefaultsKey<Bool>("CustomMenuApplyToContext")
    static let customMenuIconOption = DefaultsKey<String>("CustomMenuIconOption")
    static let pathEscapeOption = DefaultsKey<Bool>("PathEscapeOption")
    static let kittyCommand = DefaultsKey<String>("KittyCommand")
    static let onlyActivateShortcutsInFinder = DefaultsKey<Bool>("OnlyActivateShortcutsInFinder")
    static let neovimCommand = DefaultsKey<String>("NeovimCommand")
    static let gitkrakenCommand = DefaultsKey<String>("GitkrakenCommand")
    
    // for Lite
    static let liteDefaultTerminal = DefaultsKey<String>("LiteDefaultTerminal")
    static let liteDefaultEditor = DefaultsKey<String>("LiteDefaultEditor")
}

public extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get { return string(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return bool(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<Int>) -> Int {
        get { return integer(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<Float>) -> Float {
        get { return float(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<Double>) -> Double {
        get { return double(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<URL>) -> URL? {
        get { return url(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<Any>) -> Any? {
        get { return value(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<[Any]>) -> [Any]? {
        get { return array(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<Data>) -> Data? {
        get { return data(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<[String : Any]>) -> [String : Any]? {
        get { return dictionary(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<[String]>) -> [String]? {
        get { return stringArray(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
}
