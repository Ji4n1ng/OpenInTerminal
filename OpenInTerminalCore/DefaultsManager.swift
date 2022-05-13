//
//  DefaultsManager.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/10/14.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public class DefaultsManager {
    
    public static var shared = DefaultsManager()
    
    // MARK: - Preferences - General
    
    public var isFirstSetup: Bool {
        get {
            return Defaults[.firstSetup]
        }
        
        set {
            Defaults[.firstSetup] = newValue
        }
    }
    
    public var isLaunchAtLogin: Bool {
        get {
            return Defaults[.launchAtLogin]
        }
        
        set {
            Defaults[.launchAtLogin] = newValue
        }
    }
    
    public var isQuickToggle: Bool {
        get {
            return Defaults[.quickToggle]
        }
        
        set {
            Defaults[.quickToggle] = newValue
        }
    }
    
    public var quickToggleType: QuickToggleType? {
        get {
            return Defaults[.quickToggleType].map(QuickToggleType.init(rawValue: )) ?? nil
        }
        
        set {
            Defaults[.quickToggleType] = newValue?.rawValue
        }
    }
    
    public var isHideStatusItem: Bool {
        get {
            return Defaults[.hideStatusItem]
        }
        
        set {
            Defaults[.hideStatusItem] = newValue
        }
    }
    
    public var isHideContextMenuItems: Bool {
        get {
            return Defaults[.hideContextMenuItems]
        }
        
        set {
            Defaults[.hideContextMenuItems] = newValue
        }
    }
    
    public var defaultTerminal: App? {
        get {
            guard let terminalName = Defaults[.defaultTerminal] else { return nil }
            let app = App(name: terminalName, type: .terminal)
            return app
        }
        
        set {
            guard let newValue = newValue else { return }
            Defaults[.defaultTerminal] = newValue.name
        }
    }
    
    public var defaultEditor: App? {
        get {
            guard let editorName = Defaults[.defaultEditor] else { return nil }
            let app = App(name: editorName, type: .editor)
            return app
        }
        
        set {
            guard let newValue = newValue else { return }
            Defaults[.defaultEditor] = newValue.name
        }
    }
    
    public var liteDefaultTerminal: String? {
        get {
            return Defaults[.liteDefaultTerminal]
        }
        
        set {
            Defaults[.liteDefaultTerminal] = newValue
        }
    }
    
    public var liteDefaultEditor: String? {
        get {
            return Defaults[.liteDefaultEditor]
        }
        
        set {
            Defaults[.liteDefaultEditor] = newValue
        }
    }
    
    // MARK: - Preferences - Custom
    
    public func getNewOption(_ app: SupportedApps) -> NewOptionType? {
        var option: String?
        switch app {
//        case .terminal:
//            option = Defaults[.terminalNewOption]
        case .iTerm:
            option = Defaults[.iTermNewOption]
        default:
            return nil
        }
        return option.map(NewOptionType.init(rawValue: )) ?? nil
    }
    
    public func setNewOption(_ app: SupportedApps, _ newOption: NewOptionType) {
        switch app {
//        case .terminal:
//            Defaults[.terminalNewOption] = newOption.rawValue
//            if let groupDefaults = GroupDefaults {
//                groupDefaults[.terminalNewOption] = newOption.rawValue
//            }
        case .iTerm:
            Defaults[.iTermNewOption] = newOption.rawValue
            let option = newOption == .window ? "true" : "false"
            let source = """
            do shell script "defaults write \(SupportedApps.iTerm.bundleId) OpenFileInNewWindows -bool \(option)"
            """
            let script = NSAppleScript(source: source)!
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if error != nil {
                logw("Setting iTerm new option failed: \(String(describing: error))")
            }
        default:
            return
        }
    }
    
    public var customMenuOptions: [App]? {
        get {
            guard let appsData = Defaults[.customMenuOptions] else { return nil }
            do {
                let apps = try decoder.decode([App].self, from: appsData)
                return apps
            } catch {
                return nil
            }
        }
        
        set {
            guard let newValue = newValue else { return }
            do {
                let data = try encoder.encode(newValue)
                Defaults[.customMenuOptions] = data
            } catch {
                logw("save custom menu options failed: \(error)")
            }
        }
    }
    
    public var isCustomMenuApplyToToolbar: Bool {
        get {
            return Defaults[.customMenuApplyToToolbar]
        }
        
        set {
            Defaults[.customMenuApplyToToolbar] = newValue
        }
    }
    
    public var isCustomMenuApplyToContext: Bool {
        get {
            return Defaults[.customMenuApplyToContext]
        }
        
        set {
            Defaults[.customMenuApplyToContext] = newValue
        }
    }
    
    public var customMenuIconOption: CustomMenuIconOption {
        get {
            let optionValue = Defaults[.customMenuIconOption] ?? "no"
            let option = CustomMenuIconOption(rawValue: optionValue)
            return option ?? .no
        }
        
        set {
            Defaults[.customMenuIconOption] = newValue.rawValue
        }
    }
    
    public func getAppIcon(_ app: App) -> NSImage? {
        switch customMenuIconOption {
        case .no:
            return nil
        case .simple:
            if app.type == .terminal {
                return NSImage(named: "context_menu_icon_terminal")
            } else {
                return NSImage(named: "context_menu_icon_editor")
            }
        case .original:
            if SupportedApps.isSupported(app),
               let icon = NSImage(named: app.name) {
                return icon
            }
            if app.type == .terminal {
                return NSImage(named: "context_menu_icon_color_terminal")
            } else {
                return NSImage(named: "context_menu_icon_color_editor")
            }
        }
    }
    
    // MARK: - Advanced Settings
    
    public func firstSetup() {
        guard isFirstSetup == false else { return }
        logw("First Setup")
        isFirstSetup = true
        isLaunchAtLogin = false
        isQuickToggle = false
        quickToggleType = .openWithDefaultTerminal
        isHideStatusItem = false
        isHideContextMenuItems = false
        defaultTerminal = SupportedApps.terminal.app
        defaultEditor = SupportedApps.textEdit.app
        setNewOption(.terminal, .window)
        setNewOption(.iTerm, .window)
        isCustomMenuApplyToToolbar = false
        isCustomMenuApplyToContext = false
        customMenuIconOption = .no
        Defaults.synchronize()
    }
    
    public func removeAllUserDefaults() {
        logw("Remove all UserDefaults")
        Defaults.removePersistentDomain(forName: Constants.Id.Group)
        Defaults.synchronize()
    }
    
}
