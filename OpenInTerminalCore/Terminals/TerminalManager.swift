//
//  TerminalManager.swift
//  OpenInTerminal
//
//  Created by Cameron Ingham on 4/16/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import AppKit

public class TerminalManager {
    
    public static let shared: TerminalManager = TerminalManager()
    
    // MARK: public methods
    
    public func openTerminal(_ terminalType: TerminalType) {
        do {
            var path = try FinderManager.shared.getPathToFrontFinderWindowOrSelectedFile()
            if path == "" {
                // No Finder window and no file selected.
                let homePath = NSHomeDirectory()
                guard let homeUrl = URL(string: homePath) else { return }
                path = homeUrl.appendingPathComponent("Desktop").path
            }
            
            let terminal = terminalType.instance()
            
            let newOption = DefaultsManager.shared.getNewOption(terminalType) ?? .window
            try terminal.open(path, newOption)
        } catch {
            logw(error.localizedDescription)
        }
    }
    
    public func pickTerminalAlert() -> TerminalType? {
        
        let alert = NSAlert()
        
        alert.messageText = NSLocalizedString("alert.pick_terminal_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_terminal_description", comment: "Please select one of the following terminals as the default terminal to open.")
        
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: TerminalType.hyper.rawValue).refusesFirstResponder = true
        alert.addButton(withTitle: TerminalType.iTerm.rawValue).refusesFirstResponder = true
        alert.addButton(withTitle: TerminalType.terminal.rawValue).refusesFirstResponder = true
        
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
