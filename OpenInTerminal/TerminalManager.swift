//
//  TerminalManager.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/16/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import AppKit

class TerminalManager {
    
    static let shared: TerminalManager = TerminalManager()
    
    func getTerminal() -> Terminal? {
        
        if let defaultTerminal = Config.userPreferredTerminal {
            return defaultTerminal.instance()
        }
        
        guard let selectedTerminal = pickTerminalAlert() else {
            return nil
        }
        
        UserDefaults.standard.set(selectedTerminal.rawValue, forKey: Config.Key.terminalBundleIdentifier)
        
        return selectedTerminal.instance()
    }
    
    private func pickTerminalAlert() -> TerminalType? {
        
        let alert = NSAlert()
        
        alert.messageText = "Open In?"
        alert.informativeText = "Please select one of the following terminals as the default terminal to open."
        
        // Add button and avoid the focus ring
        alert.addButton(withTitle: "Cancel").refusesFirstResponder = true
        alert.addButton(withTitle: TerminalType.hyper.name).refusesFirstResponder = true
        alert.addButton(withTitle: TerminalType.iTerm.name).refusesFirstResponder = true
        alert.addButton(withTitle: TerminalType.terminal.name).refusesFirstResponder = true
        
        let modalResult = alert.runModal()
        
        switch modalResult {
            
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return .hyper
        case .alertThirdButtonReturn:
            return .iTerm
        default:
            return .terminal
        }
    }
}
