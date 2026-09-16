//
//  Defaults.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import os

/// A small persistent key-value store with a `UserDefaults`-like surface.
///
/// The app and its Finder extension used to share preferences through
/// `UserDefaults(suiteName:)` backed by the app group. On newer macOS versions,
/// suite writes without a provisioned Team ID may fail or be dropped before
/// reaching disk (GitHub issue #269): every launch re-ran the first-run setup
/// and the Finder toolbar menu stayed empty because the extension could not
/// read back the default terminal. This store keeps the same subscript API
/// but persists to a shared plist inside the extension's "Application Scripts"
/// folder, which the app can write to and the sandboxed extension can read from.
public final class DefaultsStore: NSObject {

    /// The store posts manual KVO notifications instead of automatic ones.
    override public class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        return false
    }

    private let wrapped: UserDefaults?
    private let fileURL: URL?
    private let queue = DispatchQueue(label: "openinterminal.defaults.store")

    /// File-backed store shared by the app and the Finder extension.
    ///
    /// The plist lives in the extension's "Application Scripts" folder:
    /// macOS 27's system policy denies non-sandboxed processes any write to
    /// group containers (which is what silently killed `UserDefaults(suiteName:)`
    /// persistence, see GitHub issue #269), while this folder is writable by
    /// the app (it installs its AppleScripts there) and readable by the
    /// sandboxed extension (it executes those scripts).
    public init(groupIdentifier: String) {
        wrapped = nil
        let folderURL: URL? = {
            if let scriptsDir = try? FileManager.default.url(for: .applicationScriptsDirectory,
                                                             in: .userDomainMask,
                                                             appropriateFor: nil,
                                                             create: true) {
                if Bundle.main.bundleIdentifier == Constants.Id.FinderExtension {
                    return scriptsDir
                } else {
                    let extDir = scriptsDir.deletingLastPathComponent().appendingPathComponent(Constants.Id.FinderExtension)
                    if !FileManager.default.fileExists(atPath: extDir.path) {
                        try? FileManager.default.createDirectory(at: extDir, withIntermediateDirectories: true, attributes: nil)
                    }
                    return extDir
                }
            }
            return nil
        }()
        fileURL = folderURL?.appendingPathComponent("shared-defaults.plist")
        super.init()
        let storePath = fileURL?.path ?? "nil"
        Self.logger.log("store path: \(storePath, privacy: .public)")
    }

    /// UserDefaults-backed store for the Lite command line apps, whose
    /// preferences never need to be shared with another process.
    public init(userDefaults: UserDefaults) {
        wrapped = userDefaults
        fileURL = nil
        super.init()
    }

    // MARK: - File-backed persistence

    private func loadFileDictionary() -> [String: Any] {
        guard let fileURL = fileURL,
              let data = try? Data(contentsOf: fileURL),
              !data.isEmpty,
              let dictionary = (try? PropertyListSerialization.propertyList(from: data, format: nil)) as? [String: Any]
        else { return [:] }
        return dictionary
    }

    private func fileValue(forKey key: String) -> Any? {
        return queue.sync { loadFileDictionary()[key] }
    }

    private static let logger = Logger(subsystem: "wang.jianing.app.OpenInTerminal", category: "DefaultsStore")

    private func setFileValue(_ value: Any?, forKey key: String) {
        guard let fileURL = fileURL else { return }
        queue.sync {
            let dir = fileURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: dir.path) {
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }
            var dictionary = loadFileDictionary()
            if let value = value {
                dictionary[key] = value
            } else {
                dictionary.removeValue(forKey: key)
            }
            do {
                let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
                try data.write(to: fileURL, options: .atomic)
            } catch {
                Self.logger.error("write \(key, privacy: .public) failed: \(String(describing: error), privacy: .public)")
                logw("DefaultsStore write \(key) failed: \(error)")
            }
        }
    }

    // MARK: - Typed accessors

    public func object(forKey key: String) -> Any? {
        if let wrapped = wrapped { return wrapped.object(forKey: key) }
        return fileValue(forKey: key)
    }

    public func set(_ value: Any?, forKey key: String) {
        willChangeValue(forKey: key)
        if let wrapped = wrapped {
            wrapped.set(value, forKey: key)
        } else {
            setFileValue(value, forKey: key)
        }
        didChangeValue(forKey: key)
    }

    /// KVC-style accessor kept for source compatibility with `UserDefaults`.
    public override func value(forKey key: String) -> Any? {
        if let wrapped = wrapped {
            return wrapped.value(forKey: key)
        }
        return fileValue(forKey: key)
    }

    public override func setValue(_ value: Any?, forKey key: String) {
        set(value, forKey: key)
    }

    public override func value(forUndefinedKey key: String) -> Any? {
        return object(forKey: key)
    }

    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        set(value, forKey: key)
    }

    public func string(forKey key: String) -> String? {
        return object(forKey: key) as? String
    }

    public func bool(forKey key: String) -> Bool {
        return object(forKey: key) as? Bool ?? false
    }

    public func integer(forKey key: String) -> Int {
        return object(forKey: key) as? Int ?? 0
    }

    public func float(forKey key: String) -> Float {
        return object(forKey: key) as? Float ?? 0
    }

    public func double(forKey key: String) -> Double {
        return object(forKey: key) as? Double ?? 0
    }

    public func url(forKey key: String) -> URL? {
        return object(forKey: key) as? URL
    }

    public func data(forKey key: String) -> Data? {
        return object(forKey: key) as? Data
    }

    public func array(forKey key: String) -> [Any]? {
        return object(forKey: key) as? [Any]
    }

    public func stringArray(forKey key: String) -> [String]? {
        return object(forKey: key) as? [String]
    }

    public func dictionary(forKey key: String) -> [String: Any]? {
        return object(forKey: key) as? [String: Any]
    }

    /// Kept for source compatibility with `UserDefaults`; file writes are
    /// synchronous so there is nothing to flush.
    public func synchronize() -> Bool {
        return true
    }

    public func removePersistentDomain(forName domainName: String) {
        if let wrapped = wrapped {
            wrapped.removePersistentDomain(forName: domainName)
            return
        }
        guard let fileURL = fileURL else { return }
        queue.sync {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}

/// current defaults
public let Defaults: DefaultsStore = {
    if Bundle.main.bundleIdentifier == Constants.Id.OpenInTerminalLite ||
        Bundle.main.bundleIdentifier == Constants.Id.OpenInEditorLite {
        return DefaultsStore(userDefaults: .standard)
    } else {
        return DefaultsStore(groupIdentifier: Constants.Id.Group)
    }
}()

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

public extension DefaultsStore {
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
        get { return object(forKey: key._key) }
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
