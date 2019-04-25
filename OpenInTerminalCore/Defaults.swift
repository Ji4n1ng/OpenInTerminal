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
    
    // value example: TerminalType.terminal.rawValue
    static let defaultTerminal = DefaultsKey<String>("OIT_TerminalBundleIdentifier")
    
    // value example: VisibleType.visble.rawValue
    static let terminalVisible = DefaultsKey<String>("OIT_TerminalVisible")
    static let iTermVisible = DefaultsKey<String>("OIT_iTermVisible")
    static let hyperVisible = DefaultsKey<String>("OIT_HyperVisible")
    static let alacrittyVisible = DefaultsKey<String>("OIT_AlacrittyVisible")
    static let vscodeVisible = DefaultsKey<String>("OIT_VSCodeVisible")
    static let atomVisible = DefaultsKey<String>("OIT_AtomVisible")
    static let sublimeVisible = DefaultsKey<String>("OIT_SublimeVisible")
    
    // value example: NewOptionType.window.rawValue
    static let terminalNewOption = DefaultsKey<String>("OIT_TerminalNewOption")
    static let iTermNewOption = DefaultsKey<String>("OIT_iTermNewOption")
    static let hyperNewOption = DefaultsKey<String>("OIT_HyperNewOption")
    static let alacrittyNewOption = DefaultsKey<String>("OIT_AlacrittyNewOption")
    
    static let copyPathToClipboardVisible = DefaultsKey<String>("OIT_CopyPathToClipboardVisible")
    
}

let Defaults = UserDefaults.standard

extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get { return string(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
}
