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
    
    // The values corresponding to the following keys are String.
    
    // value example: FirstUsage._true.rawValue
    static let firstUsage = DefaultsKey<String>(Constants.Key.firstUsage)
    
    // value example: TerminalType.terminal.rawValue
    static let defaultTerminal = DefaultsKey<String>(Constants.Key.defaultTerminal)
    
    // value example: EditorType.vscode.rawValue
    static let defaultEditor = DefaultsKey<String>(Constants.Key.defaultEditor)
    
    // value example: NewOptionType.window.rawValue
    static let terminalNewOption = DefaultsKey<String>(Constants.Key.terminalNewOption)
    static let iTermNewOption = DefaultsKey<String>(Constants.Key.iTermNewOption)
    
    // value example: ClearType.clear.rawValue
    static let terminalClear = DefaultsKey<String>(Constants.Key.terminalClearOption)
    static let iTermClear = DefaultsKey<String>(Constants.Key.iTermClearOption)
    
    static let copyPathToClipboardVisible = DefaultsKey<String>(Constants.Key.copyPathToClipboardVisible)
    
}

let Defaults = UserDefaults.standard

extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get { return string(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
}
