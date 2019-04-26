//
//  EditorType.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum EditorType: String {
    
    case vscode = "com.microsoft.VSCode"
    case atom = "com.github.atom"
    case sublime = "com.sublimetext.3"
    
    public var name: String {
        switch self {
        case .vscode:
            return "Visual Studio Code"
        case .atom:
            return "Atom"
        case .sublime:
            return "Sublime Text"
        }
    }
    
    public var abbreviation: String {
        switch self {
        case .vscode:
            return "VS Code"
        case .atom:
            return "Atom"
        case .sublime:
            return "Sublime"
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
        }
    }
}
