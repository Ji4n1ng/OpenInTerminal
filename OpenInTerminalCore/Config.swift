//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/17.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public struct OITCoreConfig {
    
    public static var firstUsage: FirstUsageType {
        if Defaults[.firstUsage] == nil {
            Defaults[.firstUsage] = FirstUsageType._false.rawValue
            return ._true
        } else {
            return ._false
        }
    }
    
}

struct Config {
    
    struct Finder {
        static let id = "com.apple.Finder"
    }
    
}

public enum NewOptionType: String {
    case tab
    case window
}

public enum VisibleType: String {
    case visible
    case invisible
}

public enum ClearOptionType: String {
    case clear
    case noClear
}

public enum FirstUsageType: String {
    case _true
    case _false
}
