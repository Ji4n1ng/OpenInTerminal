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
    
    /// get terminal from UserDefaults or AlertBox
    ///
    /// First get the default terminal.
    /// If there is no default function, then the user will pick a terminal in AlertBox.
    /// Used in OpenInTerminal-Lite
    public func getTerminal() -> TerminalType? {
        
        if let defaultTerminal = getDefaultTerminal() {
            return defaultTerminal
        }
        
        guard let selectedTerminal = pickTerminalAlert() else {
            return nil
        }
        
        Defaults[.defaultTerminal] = selectedTerminal.rawValue
        
        return selectedTerminal
    }
    
    public func getNewOption(_ terminal: TerminalType) -> NewOptionType? {
        var option: String?
        switch terminal {
        case .terminal:
            option = Defaults[.terminalNewOption]
        case .iTerm:
            option = Defaults[.iTermNewOption]
        case .hyper:
            option = Defaults[.hyperNewOption]
        }
        
        return option.map(NewOptionType.init(rawValue: )) ?? nil
    }
    
    public func getVisble(_ terminal: TerminalType) -> VisibleType? {
        var visble: String?
        switch terminal {
        case .terminal:
            visble = Defaults[.terminalVisible]
        case .iTerm:
            visble = Defaults[.iTermVisible]
        case .hyper:
            visble = Defaults[.hyperVisible]
        }
        
        return visble.map(VisibleType.init(rawValue: )) ?? nil
    }
    
    // MARK: private methods
    
    private func getDefaultTerminal() -> TerminalType? {
        return Defaults[.defaultTerminal]
            .map(TerminalType.init(rawValue: )) ?? nil
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
