//
//  TerminalManager.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/16/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import AppKit

class TerminalManager {
    
    static func pickTerminalAlert() -> Terminal? {
        let alert = NSAlert()
        
        alert.messageText = "Open In?"
        alert.informativeText = "Choose which terminal application to open this directory in."
        
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Terminal")
        alert.addButton(withTitle: "iTerm")
        alert.addButton(withTitle: "Hyper")
        
        let modalResult = alert.runModal()
        
        switch modalResult {
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return TerminalType.terminal.instance()
        case .alertThirdButtonReturn:
            return TerminalType.iTerm.instance()
        default:
            return TerminalType.hyper.instance()
        }
    }
}

enum TerminalType: String {
    case terminal
    case iTerm
    case hyper
    
    func instance() -> Terminal {
        switch self {
        case .terminal:
            return TerminalApp()
        case .iTerm:
            return iTermApp()
        case .hyper:
            return HyperApp()
        }
    }
}
