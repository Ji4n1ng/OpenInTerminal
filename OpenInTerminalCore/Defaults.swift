//
//  Defaults.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

class DefaultsKeys {
    fileprivate init() {}
}

class DefaultsKey<ValueType>: DefaultsKeys {
    let _key: String
    
    init(_ key: String) {
        self._key = key
    }
    
}

extension DefaultsKeys {
    
    // The type of values corresponding to the following keys is String.
    
    // value example: BoolType._true.rawValue
    static let firstUsage = DefaultsKey<String>(Constants.Key.firstUsage)
    static let launchAtLogin = DefaultsKey<String>(Constants.Key.launchAtLogin)
    static let hideStatusItem = DefaultsKey<String>(Constants.Key.hideStatusItem)
    static let hideContextMenuItems = DefaultsKey<String>(Constants.Key.hideContextMenuItems)
    static let quickToggle = DefaultsKey<String>(Constants.Key.quickToggle)
    static let quickToggleType = DefaultsKey<String>(Constants.Key.quickToggleType)
    
    // value example: TerminalType.terminal.rawValue
    static let defaultTerminal = DefaultsKey<String>(Constants.Key.defaultTerminal)
    
    // value example: EditorType.vscode.rawValue
    static let defaultEditor = DefaultsKey<String>(Constants.Key.defaultEditor)
    
    // value example: NewOptionType.window.rawValue
    static let terminalNewOption = DefaultsKey<String>(Constants.Key.terminalNewOption)
    static let iTermNewOption = DefaultsKey<String>(Constants.Key.iTermNewOption)
    
}

let Defaults = UserDefaults.standard
let GroupDefaults = UserDefaults(suiteName: Constants.groupIdentifier)

extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get { return string(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
}
