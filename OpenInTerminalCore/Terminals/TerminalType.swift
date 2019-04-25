//
//  TerminalType.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum TerminalType: String {
    
    case terminal = "com.apple.Terminal"
    case iTerm = "com.googlecode.iterm2"
    case hyper = "co.zeit.hyper"
    case alacritty = "io.alacritty"
    
    public var name: String {
        switch self {
        case .terminal:
            return "Terminal"
        case .iTerm:
            return "iTerm"
        case .hyper:
            return "Hyper"
        case .alacritty:
            return "Alacritty"
        }
    }
    
    public func instance() -> Openable {
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
