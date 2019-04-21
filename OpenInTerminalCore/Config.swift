//
//  Config.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/4/17.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

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
