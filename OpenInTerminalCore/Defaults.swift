//
//  Defaults.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

/// group defaults
let GroupDefaults = UserDefaults(suiteName: Constants.Id.Group)

/// current defaults
public var Defaults: UserDefaults = {
    if Bundle.main.bundleIdentifier == Constants.Id.OpenInTerminalLite ||
        Bundle.main.bundleIdentifier == Constants.Id.OpenInEditorLite {
        return UserDefaults.standard
    } else {
        return GroupDefaults ?? UserDefaults.standard
    }
}()

public class DefaultsKeys {
    let _key: String
    fileprivate init(_ key: String) {
        self._key = key
    }
}

public class DefaultsKey<ValueType>: DefaultsKeys {
    override init(_ key: String) {
        super.init(key)
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

/// Values written by the host app are mirrored into `SharedConfig` so the
/// sandboxed Finder extension - which cannot read the host's preferences -
/// still sees the current configuration. Inside the extension the mirror is the
/// primary source.
private enum SharedMirror {
    static func object(_ key: String) -> Any? {
        guard SharedConfig.isSandboxedExtension else { return nil }
        return SharedConfig.object(forKey: key)
    }

    static func store(_ value: Any?, forKey key: String) {
        SharedConfig.set(value, forKey: key)
    }
}

public extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get {
            if let value = SharedMirror.object(key._key) { return value as? String }
            return string(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<Bool>) -> Bool {
        get {
            if let value = SharedMirror.object(key._key) {
                if let number = value as? NSNumber { return number.boolValue }
                return value as? Bool ?? false
            }
            return bool(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<Int>) -> Int {
        get {
            if let value = SharedMirror.object(key._key) {
                if let number = value as? NSNumber { return number.intValue }
                return value as? Int ?? 0
            }
            return integer(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<Float>) -> Float {
        get {
            if let value = SharedMirror.object(key._key) {
                if let number = value as? NSNumber { return number.floatValue }
                return value as? Float ?? 0
            }
            return float(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<Double>) -> Double {
        get {
            if let value = SharedMirror.object(key._key) {
                if let number = value as? NSNumber { return number.doubleValue }
                return value as? Double ?? 0
            }
            return double(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<URL>) -> URL? {
        get {
            if let value = SharedMirror.object(key._key) { return value as? URL }
            return url(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<Any>) -> Any? {
        get {
            if let value = SharedMirror.object(key._key) { return value }
            return value(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<[Any]>) -> [Any]? {
        get {
            if let value = SharedMirror.object(key._key) { return value as? [Any] }
            return array(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<Data>) -> Data? {
        get {
            if let value = SharedMirror.object(key._key) { return value as? Data }
            return data(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<[String : Any]>) -> [String : Any]? {
        get {
            if let value = SharedMirror.object(key._key) { return value as? [String : Any] }
            return dictionary(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<[String]>) -> [String]? {
        get {
            if let value = SharedMirror.object(key._key) { return value as? [String] }
            return stringArray(forKey: key._key)
        }
        set {
            SharedMirror.store(newValue, forKey: key._key)
            set(newValue, forKey: key._key)
        }
    }
}
