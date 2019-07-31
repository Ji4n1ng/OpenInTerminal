//
//  EditorType.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum EditorType: String {
    
    case vscode = "VSCode"
    case atom = "Atom"
    case sublime = "Sublime"
    case vscodium = "VSCodium"
    case bbedit = "BBEdit"
    case vscodeInsiders = "VSCodeInsiders"
    
    public var fullName: String {
        switch self {
        case .vscode:
            return "Visual Studio Code"
        case .atom:
            return "Atom"
        case .sublime:
            return "Sublime Text"
        case .vscodium:
            return "VSCodium"
        case .bbedit:
            return "BBEdit"
        case .vscodeInsiders:
            return "Visual Studio Code - Insiders"
        }
    }
    
    public var bundleId: String {
        switch self {
        case .vscode:
            return "com.microsoft.VSCode"
        case .atom:
            return "com.github.atom"
        case .sublime:
            return "com.sublimetext.3"
        case .vscodium:
            return "com.visualstudio.code.oss"
        case .bbedit:
            return "com.barebones.bbedit"
        case .vscodeInsiders:
            return "com.microsoft.VSCodeInsiders"
        }
    }
    
    public func instance() -> Editor {
        switch self {
        case .vscode:
            return VSCodeApp()
        case .atom:
            return AtomApp()
        case .sublime:
            return SublimeApp()
        case .vscodium:
            return VSCodiumApp()
        case .bbedit:
            return BBEditApp()
        case .vscodeInsiders:
            return VSCodeInsidersApp()
        }
    }
}
