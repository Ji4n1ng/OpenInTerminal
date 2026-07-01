//
//  Defaults.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

// MARK: - DefaultsStore Protocol

/// Abstract interface for reading/writing settings.
/// Conforming types are used interchangeably between the main app and extensions.
public protocol DefaultsStore: AnyObject {
    // MARK: - KVO support (NSObject required)
    // Conforming types must inherit from NSObject so that AppKit/ShortcutRecorder
    // can observe defaults via addObserver:forKeyPath:options:context:
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String,
                     options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?)
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String)

    // MARK: - Read / Write
    func string(forKey: String) -> String?
    func bool(forKey: String) -> Bool
    func integer(forKey: String) -> Int
    func float(forKey: String) -> Float
    func double(forKey: String) -> Double
    func url(forKey: String) -> URL?
    func value(forKey: String) -> Any?
    func array(forKey: String) -> [Any]?
    func data(forKey: String) -> Data?
    func dictionary(forKey: String) -> [String: Any]?
    func stringArray(forKey: String) -> [String]?
    func set(_ value: Any?, forKey: String)
    func removeObject(forKey: String)
    func synchronize()
    func dictionaryRepresentation() -> [String: Any]
    func removePersistentDomain(forName: String)
}

/// current defaults store.
///
/// In the full version (main app & Finder extension) this is `PersistentDefaults.shared`,
/// which stores settings as a plist inside the shared App Group container so that every
/// write is immediately durable – unlike `UserDefaults(suiteName:)`, which may silently
/// discard writes on macOS 27+ when the process has Hardened Runtime enabled.
///
/// Lite variants fall back to `UserDefaults.standard`.
public var Defaults: DefaultsStore = {
    if Bundle.main.bundleIdentifier == Constants.Id.OpenInTerminalLite ||
        Bundle.main.bundleIdentifier == Constants.Id.OpenInEditorLite {
        return StandardDefaultsBridge()
    } else {
        return PersistentDefaults.shared
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
    static let neovimCommand = DefaultsKey<String>("NeovimCommand")
    static let gitkrakenCommand = DefaultsKey<String>("GitkrakenCommand")

    // for Lite
    static let liteDefaultTerminal = DefaultsKey<String>("LiteDefaultTerminal")
    static let liteDefaultEditor = DefaultsKey<String>("LiteDefaultEditor")
}

// MARK: - PersistentDefaults

/// A thread-safe settings store backed by a plist file inside the shared App Group
/// container, bypassing cfprefsd entirely.
///
/// On macOS 27+ (pre-release), `UserDefaults(suiteName:)` from hardened processes
/// may fail to persist writes to the backing plist (cfprefsd in-memory cache is not
/// flushed to disk). This store uses `NSDictionary.write(to:atomically:)` directly so
/// that every write is immediately durable.
final class PersistentDefaults: NSObject, DefaultsStore {

    static let shared = PersistentDefaults(suiteName: Constants.Id.Group)

    private let fileURL: URL?
    private let lock = NSLock()
    private let useStandard: Bool

    // MARK: - Init

    private init(suiteName: String?) {
        // Phase 1: determine storage path (no self used yet)
        var resolvedURL: URL?
        var useStd = false

        if let name = suiteName {
            // First choice: App Group container (shared with Finder extension).
            if let container = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: name) {
                let candidate = container.appendingPathComponent("Settings.plist")
                // Only write-empty to test writability if file doesn't exist yet.
                // containerURL returns a path even for unsigned processes but
                // writes silently fail – the test catches that. For an existing
                // file we trust it's writable to avoid clobbering settings.
                if FileManager.default.fileExists(atPath: candidate.path) ||
                    ([:] as NSDictionary).write(to: candidate, atomically: true) {
                    resolvedURL = candidate
                }
            }
            // Fallback: ~/Library/Preferences/group.<id>.plist.
            // Works even without proper code-signing (ad-hoc, unsigned).
            if resolvedURL == nil {
                let home = FileManager.default.homeDirectoryForCurrentUser
                let fallback = home.appendingPathComponent("Library/Preferences/\(name).plist")
                // Same guard – don't overwrite existing settings.
                if FileManager.default.fileExists(atPath: fallback.path) ||
                    ([:] as NSDictionary).write(to: fallback, atomically: true) {
                    resolvedURL = fallback
                }
            }
        }
        if resolvedURL == nil { useStd = true }

        self.fileURL = resolvedURL
        self.useStandard = useStd
        super.init()

        // Migration: copy any existing UserDefaults suite keys into the file
        if let name = suiteName { migrateIfNeeded(suiteName: name) }
    }

    /// If the old `UserDefaults(suiteName:)` store has data that isn't yet in our
    /// plist, copy it over. This ensures a smooth upgrade path.
    private func migrateIfNeeded(suiteName: String) {
        guard let fileURL else { return }
        let old = UserDefaults(suiteName: suiteName)?.dictionaryRepresentation() ?? [:]
        guard !old.isEmpty else { return }
        let existing = NSDictionary(contentsOf: fileURL) as? [String: Any] ?? [:]
        // Only copy keys that are missing from our file
        var merged = existing
        var migrated = false
        for (k, v) in old where existing[k] == nil {
            merged[k] = v
            migrated = true
        }
        if migrated {
            (merged as NSDictionary).write(to: fileURL, atomically: true)
        }
    }

    // MARK: - Internal helpers

    private var cache: [String: Any] {
        if useStandard {
            return UserDefaults.standard.dictionaryRepresentation()
        }
        guard let fileURL else { return [:] }
        lock.lock()
        defer { lock.unlock() }
        return NSDictionary(contentsOf: fileURL) as? [String: Any] ?? [:]
    }

    private func save(_ dict: [String: Any]) {
        if useStandard { return }
        guard let fileURL else { return }
        lock.lock()
        (dict as NSDictionary).write(to: fileURL, atomically: true)
        lock.unlock()
    }

    // MARK: - DefaultsStore

    func string(forKey key: String) -> String? { cache[key] as? String }
    func bool(forKey key: String) -> Bool     { (cache[key] as? Bool) ?? false }
    func integer(forKey key: String) -> Int   { (cache[key] as? Int) ?? 0 }
    func float(forKey key: String) -> Float   { (cache[key] as? Float) ?? 0 }
    func double(forKey key: String) -> Double { (cache[key] as? Double) ?? 0.0 }
    func url(forKey key: String) -> URL?      { cache[key] as? URL }
    override func value(forKey key: String) -> Any?    { cache[key] }
    func array(forKey key: String) -> [Any]?  { cache[key] as? [Any] }
    func data(forKey key: String) -> Data?    { cache[key] as? Data }
    func dictionary(forKey key: String) -> [String: Any]? { cache[key] as? [String: Any] }
    func stringArray(forKey key: String) -> [String]?     { cache[key] as? [String] }

    func set(_ value: Any?, forKey key: String) {
        if useStandard {
            UserDefaults.standard.set(value, forKey: key)
            return
        }
        var dict = cache
        if let value = value {
            dict[key] = value
        } else {
            dict.removeValue(forKey: key)
        }
        save(dict)
    }

    func removeObject(forKey key: String) {
        set(nil, forKey: key)
    }

    func synchronize() {
        // Writes are already synchronous; nothing to do.
    }

    func dictionaryRepresentation() -> [String: Any] {
        cache
    }

    func removePersistentDomain(forName _: String) {
        save([:])
    }
}

// MARK: - StandardDefaultsBridge (for Lite variant)

/// Thin wrapper around `UserDefaults.standard` so Lite variants can conform
/// to `DefaultsStore`.
final class StandardDefaultsBridge: NSObject, DefaultsStore {
    func string(forKey key: String) -> String? { UserDefaults.standard.string(forKey: key) }
    func bool(forKey key: String) -> Bool { UserDefaults.standard.bool(forKey: key) }
    func integer(forKey key: String) -> Int { UserDefaults.standard.integer(forKey: key) }
    func float(forKey key: String) -> Float { UserDefaults.standard.float(forKey: key) }
    func double(forKey key: String) -> Double { UserDefaults.standard.double(forKey: key) }
    func url(forKey key: String) -> URL? { UserDefaults.standard.url(forKey: key) }
    override func value(forKey key: String) -> Any? { UserDefaults.standard.value(forKey: key) }
    func array(forKey key: String) -> [Any]? { UserDefaults.standard.array(forKey: key) }
    func data(forKey key: String) -> Data? { UserDefaults.standard.data(forKey: key) }
    func dictionary(forKey key: String) -> [String: Any]? { UserDefaults.standard.dictionary(forKey: key) }
    func stringArray(forKey key: String) -> [String]? { UserDefaults.standard.stringArray(forKey: key) }
    func set(_ value: Any?, forKey key: String) { UserDefaults.standard.set(value, forKey: key) }
    func removeObject(forKey key: String) { UserDefaults.standard.removeObject(forKey: key) }
    func synchronize() { UserDefaults.standard.synchronize() }
    func dictionaryRepresentation() -> [String: Any] { UserDefaults.standard.dictionaryRepresentation() }
    func removePersistentDomain(forName name: String) { UserDefaults.standard.removePersistentDomain(forName: name) }
}

// MARK: - DefaultsKey Subscripts on DefaultsStore

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
    subscript(key: DefaultsKey<[String: Any]>) -> [String: Any]? {
        get { return dictionary(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    subscript(key: DefaultsKey<[String]>) -> [String]? {
        get { return stringArray(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
}
