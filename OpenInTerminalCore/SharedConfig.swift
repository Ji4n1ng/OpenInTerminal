//
//  SharedConfig.swift
//  OpenInTerminalCore
//
//  Cross-process configuration channel between the (unsandboxed) host app and
//  the (sandboxed) Finder Sync extension.
//
//  Why this exists:
//  The host and the extension used to share preferences through the App Group
//  `group.wang.jianing.app.OpenInTerminal`. Since macOS 26 that only works when
//  the group identifier is owned by the process (Team-ID prefixed, provisioned
//  container). Our identifier is not, so `cfprefsd` hands the extension an
//  empty suite: `DefaultsManager.shared.defaultTerminal` came back `nil`, the
//  toolbar menu was built with zero items and clicking the Finder toolbar icon
//  did nothing at all.
//
//  Instead of relying on App Group container magic we use a plain plist file in
//  the extension's *Application Scripts* directory:
//
//      ~/Library/Application Scripts/<ext bundle id>/shared-settings.plist
//
//  That directory is written by the host app (it already installs its
//  AppleScripts there) and is readable by the sandboxed extension, which is the
//  one directory both processes are guaranteed to agree on.
//

import Foundation

public enum SharedConfig {

    /// Name of the plist file inside the shared directory.
    public static let fileName = "shared-settings.plist"

    /// `true` when running inside the Finder Sync extension.
    public static var isSandboxedExtension: Bool {
        return Bundle.main.bundlePath.hasSuffix(".appex")
    }

    /// Everything `DefaultsKeys` knows about. Used for the initial snapshot and
    /// for migrating settings out of the legacy App Group suite.
    static var allKeys: [String] {
        let keys: [DefaultsKeys] = [
            DefaultsKeys.firstSetup,
            DefaultsKeys.launchAtLogin,
            DefaultsKeys.quickToggle,
            DefaultsKeys.quickToggleType,
            DefaultsKeys.hideStatusItem,
            DefaultsKeys.hideContextMenuItems,
            DefaultsKeys.contextMenuUseSubmenu,
            DefaultsKeys.defaultTerminal,
            DefaultsKeys.defaultEditor,
            DefaultsKeys.terminalNewOption,
            DefaultsKeys.iTermNewOption,
            DefaultsKeys.customMenuOptions,
            DefaultsKeys.customMenuApplyToToolbar,
            DefaultsKeys.customMenuApplyToContext,
            DefaultsKeys.customMenuIconOption,
            DefaultsKeys.pathEscapeOption,
            DefaultsKeys.kittyCommand,
            DefaultsKeys.onlyActivateShortcutsInFinder,
            DefaultsKeys.neovimCommand,
            DefaultsKeys.gitkrakenCommand,
            DefaultsKeys.liteDefaultTerminal,
            DefaultsKeys.liteDefaultEditor
        ]
        return keys.map { $0._key }
    }

    // MARK: - Location

    /// `~/Library/Application Scripts/wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension`
    ///
    /// Resolved through `FileManager.url(for: .applicationScriptsDirectory:)`,
    /// which yields the correct path for both the host app and the extension.
    public static func directoryURL(create: Bool) -> URL? {
        let fileManager = FileManager.default

        var scriptsURL: URL?
        if let url = try? fileManager.url(for: .applicationScriptsDirectory,
                                          in: .userDomainMask,
                                          appropriateFor: nil,
                                          create: create) {
            scriptsURL = url
        } else if create {
            let fallback = URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent("Library/Application Scripts")
            try? fileManager.createDirectory(at: fallback, withIntermediateDirectories: true)
            scriptsURL = fallback
        }

        guard let url = scriptsURL else { return nil }

        // Inside the extension the API already points at the extension's own
        // directory; inside the host app it points at the host's directory, so
        // the extension directory is its sibling.
        let directory = url.lastPathComponent == Constants.Id.FinderExtension
            ? url
            : url.deletingLastPathComponent().appendingPathComponent(Constants.Id.FinderExtension)

        if create, !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    public static var fileURL: URL? {
        return directoryURL(create: false)?.appendingPathComponent(fileName)
    }

    // MARK: - Reading

    /// All shared values, or an empty dictionary when nothing has been shared yet.
    public static func allValues() -> [String: Any] {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let propertyList = try? PropertyListSerialization.propertyList(from: data,
                                                                             options: [],
                                                                             format: nil),
              let dictionary = propertyList as? [String: Any] else {
            return [:]
        }
        return dictionary
    }

    public static func object(forKey key: String) -> Any? {
        return allValues()[key]
    }

    // MARK: - Writing

    /// Writes a single value. Only the host app writes; the extension is
    /// read-only (its sandbox may not grant write access and it never needs it).
    public static func set(_ value: Any?, forKey key: String) {
        guard !isSandboxedExtension else { return }
        var values = allValues()
        if let value = value {
            values[key] = value
        } else {
            values.removeValue(forKey: key)
        }
        write(values)
    }

    private static func write(_ values: [String: Any]) {
        guard let directory = directoryURL(create: true),
              let data = try? PropertyListSerialization.data(fromPropertyList: values,
                                                             format: .binary,
                                                             options: 0) else {
            logw("SharedConfig: unable to serialize shared settings")
            return
        }
        let url = directory.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: .atomic)
            // keep the file private to the current user
            try? FileManager.default.setAttributes([.posixPermissions: 0o600],
                                                  ofItemAtPath: url.path)
        } catch {
            logw("SharedConfig: writing \(url.path) failed: \(error.localizedDescription)")
        }
    }

    /// Publishes the complete preference set of the host app.
    ///
    /// Call this once at launch so that values written before the shared file
    /// existed (and values written through paths that bypass the subscripts)
    /// also reach the extension.
    public static func publish(from defaults: UserDefaults) {
        guard !isSandboxedExtension else { return }
        var values = allValues()
        for key in allKeys {
            if let value = defaults.object(forKey: key) {
                values[key] = value
            }
        }
        write(values)
    }

    /// Copies settings out of the legacy App Group suite into the shared file
    /// for keys the shared file does not have yet. Never overwrites newer values.
    public static func migrateFromLegacyAppGroup() {
        guard !isSandboxedExtension else { return }
        guard let legacy = UserDefaults(suiteName: Constants.Id.Group) else { return }
        var values = allValues()
        var migrated = false
        for key in allKeys where values[key] == nil {
            if let value = legacy.object(forKey: key) {
                values[key] = value
                migrated = true
            }
        }
        if migrated {
            write(values)
            logw("SharedConfig: migrated legacy preferences into \(directoryURL(create: true)?.path ?? "?")")
        }
    }

    /// Removes every shared preference (used by "reset settings").
    public static func removeAll() {
        guard !isSandboxedExtension else { return }
        if let url = fileURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
