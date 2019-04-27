//
//  CoreManager.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/27.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public class CoreManager {
    
    public static var shared = CoreManager()
    
    public var firstUsage: BoolType {
        if Defaults[.firstUsage] == nil {
            Defaults[.firstUsage] = BoolType._false.rawValue
            return ._true
        } else {
            return ._false
        }
    }
    
    public var launchAtLogin: BoolType? {
        get {
            return Defaults[.launchAtLogin].map(BoolType.init(rawValue: )) ?? nil
        }
        
        set {
            Defaults[.launchAtLogin] = newValue?.rawValue
        }
    }
    
    public var quickOpen: BoolType? {
        get {
            return Defaults[.quickOpen].map(BoolType.init(rawValue: )) ?? nil
        }
        
        set {
            Defaults[.quickOpen] = newValue?.rawValue
        }
    }
    
    public func firstSetup() {
        guard firstUsage == ._true else { return }
        log("First Setup")
        Defaults[.launchAtLogin] = BoolType._false.rawValue
        Defaults[.quickOpen] = BoolType._false.rawValue
        Defaults.removeObject(forKey: Constants.Key.defaultTerminal)
        Defaults.removeObject(forKey: Constants.Key.defaultEditor)
        Defaults[.terminalNewOption] = NewOptionType.window.rawValue
        Defaults[.iTermNewOption] = NewOptionType.window.rawValue
        Defaults[.terminalClearOption] = ClearOptionType.noClear.rawValue
        Defaults[.iTermClearOption] = ClearOptionType.noClear.rawValue
        Defaults.synchronize()
    }
    
    public func removeAllUserDefaults() {
        log("Remove all UserDefaults", .warn)
        let domain = Bundle.main.bundleIdentifier!
        Defaults.removePersistentDomain(forName: domain)
        Defaults.synchronize()
    }
    
}
