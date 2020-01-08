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
    
    public var currentDefaults: UserDefaults {
        if Bundle.main.bundleIdentifier == Constants.openInTerminalLiteIdentifier || Bundle.main.bundleIdentifier == Constants.openInEditorLiteIdentifier {
            return Defaults
        } else {
            return GroupDefaults ?? Defaults
        }
    }
    
    public var isFirstUsage: BoolType {
        if Defaults[.firstUsage] == nil {
            Defaults[.firstUsage] = BoolType._false.rawValue
            return ._true
        } else {
            return ._false
        }
    }
    
    // MARK: - General Settings
    
    public var defaultTerminal: TerminalType? {
        get {
            return currentDefaults[.defaultTerminal]
                .map(TerminalType.init(rawValue: )) ?? nil
        }
        
        set {
            guard let newValue = newValue else { return }
            currentDefaults[.defaultTerminal] = newValue.rawValue
        }
    }
    
    public func removeDefaultTerminal() {
        currentDefaults.removeObject(forKey: Constants.Key.defaultTerminal)
    }
    
    public var defaultEditor: EditorType? {
        get {
            return currentDefaults[.defaultEditor]
                .map(EditorType.init(rawValue: )) ?? nil
        }
        
        set {
            guard let newValue = newValue else { return }
            currentDefaults[.defaultEditor] = newValue.rawValue
        }
    }
    
    public func removeDefaultEditor() {
        currentDefaults.removeObject(forKey: Constants.Key.defaultEditor)
    }
    
    public var isLaunchAtLogin: BoolType {
        get {
            let defaultValue = currentDefaults[.launchAtLogin].map(BoolType.init(rawValue: )) ?? nil
            if let boolValue = defaultValue {
                return boolValue
            } else {
                // Since we have initialized all the values at first setup, if we still get a nil value,
                // that means bad guys changed it to arbitrarily string.
                // We should changed it to default value.
                currentDefaults[.launchAtLogin] = BoolType._false.rawValue
                return ._false
            }
        }
        
        set {
            currentDefaults[.launchAtLogin] = newValue.rawValue
        }
    }
    
    public var isHideStatusItem: BoolType {
        get {
            let defaultValue = currentDefaults[.hideStatusItem].map(BoolType.init(rawValue: )) ?? nil
            if let boolValue = defaultValue {
                return boolValue
            } else {
                currentDefaults[.hideStatusItem] = BoolType._false.rawValue
                return ._false
            }
        }
        
        set {
            currentDefaults[.hideStatusItem] = newValue.rawValue
        }
    }
    
    public var isHideContextMenuItems: BoolType {
        get {
            let defaultValue = currentDefaults[.hideContextMenuItems].map(BoolType.init(rawValue: )) ?? nil
            if let boolValue = defaultValue {
                return boolValue
            } else {
                currentDefaults[.hideContextMenuItems] = BoolType._false.rawValue
                return ._false
            }
        }
        
        set {
            currentDefaults[.hideContextMenuItems] = newValue.rawValue
        }
    }
    
    public var isQuickToggle: BoolType {
        get {
            let defaultValue = currentDefaults[.quickToggle].map(BoolType.init(rawValue: )) ?? nil
            if let boolValue = defaultValue {
                return boolValue
            } else {
                currentDefaults[.quickToggle] = BoolType._false.rawValue
                return ._false
            }
        }
        
        set {
            currentDefaults[.quickToggle] = newValue.rawValue
        }
    }
    
    public var quickToggleType: QuickToggleType? {
        get {
            return currentDefaults[.quickToggleType].map(QuickToggleType.init(rawValue: )) ?? nil
        }
        
        set {
            currentDefaults[.quickToggleType] = newValue?.rawValue
        }
    }
    
    // MARK: - Terminal Settings
    
    public func getNewOption(_ terminal: TerminalType) -> NewOptionType? {
        var option: String?
        switch terminal {
        case .terminal:
            option = currentDefaults[.terminalNewOption]
        case .iTerm:
            option = currentDefaults[.iTermNewOption]
        case .hyper, .alacritty:
            return nil
        }
        
        return option.map(NewOptionType.init(rawValue: )) ?? nil
    }
    
    public func setNewOption(_ terminal: TerminalType, _ newOption: NewOptionType) throws {
        switch terminal {
        case .terminal:
            Defaults[.terminalNewOption] = newOption.rawValue
            if let groupDefaults = GroupDefaults {
                groupDefaults[.terminalNewOption] = newOption.rawValue
            }
        case .iTerm:
            currentDefaults[.iTermNewOption] = newOption.rawValue
            
            let option = newOption == .window ? "true" : "false"
            
            let source = """
            do shell script "defaults write \(TerminalType.iTerm.bundleId) OpenFileInNewWindows -bool \(option)"
            """
            let script = NSAppleScript(source: source)!
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if error != nil {
                throw OITError.cannotSetItermNewOption
            }
        case .hyper, .alacritty:
            return
        }
    }
    
    // MARK: - Advanced Settings
    
    public func firstSetup() {
        guard isFirstUsage == ._true else { return }
        logw("First Setup")
        currentDefaults[.launchAtLogin] = BoolType._false.rawValue
        currentDefaults[.hideStatusItem] = BoolType._false.rawValue
        currentDefaults[.quickToggle] = BoolType._false.rawValue
        currentDefaults[.quickToggleType] = QuickToggleType.openWithDefaultTerminal.rawValue
        currentDefaults.removeObject(forKey: Constants.Key.defaultTerminal)
        currentDefaults.removeObject(forKey: Constants.Key.defaultEditor)
        currentDefaults[.terminalNewOption] = NewOptionType.window.rawValue
        currentDefaults[.iTermNewOption] = NewOptionType.window.rawValue
        currentDefaults.synchronize()
    }
    
    public func removeAllUserDefaults() {
        logw("Remove all UserDefaults")
        currentDefaults.removePersistentDomain(forName: Constants.groupIdentifier)
        currentDefaults.synchronize()
    }
    
}
