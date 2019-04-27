//
//  TerminalType.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum TerminalType: String {
    
    case terminal = "Terminal"
    case iTerm = "iTerm"
    case hyper = "Hyper"
    case alacritty = "Alacritty"
    
    public var bundleId: String {
        switch self {
        case .terminal:
            return "com.apple.Terminal"
        case .iTerm:
            return "com.googlecode.iterm2"
        case .hyper:
            return "co.zeit.hyper"
        case .alacritty:
            return "io.alacritty"
        }
    }
    
    public func instance() -> Terminal {
        switch self {
        case .terminal:
            return TerminalApp()
        case .iTerm:
            return iTermApp()
        case .hyper:
            return HyperApp()
        case .alacritty:
            return AlacrittyApp()
        }
    }
    
}
