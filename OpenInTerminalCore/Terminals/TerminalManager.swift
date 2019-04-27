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
    
    /// get default terminal from UserDefaults
    public func getDefaultTerminal() -> TerminalType? {
        return Defaults[.defaultTerminal]
            .map(TerminalType.init(rawValue: )) ?? nil
    }
    
    /// get default terminal from UserDefaults or AlertBox
    public func getOrPickDefaultTerminal() -> TerminalType? {
        
        if let defaultTerminal = getDefaultTerminal() {
            return defaultTerminal
        }
        
        guard let selectedTerminal = pickTerminalAlert() else {
            return nil
        }
        
        setDefaultTerminal(selectedTerminal)
        
        return selectedTerminal
    }
    
    public func setDefaultTerminal(_ terminal: TerminalType) {
        Defaults[.defaultTerminal] = terminal.rawValue
    }
    
    public func removeDefaultTerminal() {
        Defaults.removeObject(forKey: Constants.Key.defaultTerminal)
    }
    
    public func getNewOption(_ terminal: TerminalType) -> NewOptionType? {
        var option: String?
        switch terminal {
        case .terminal:
            option = Defaults[.terminalNewOption]
        case .iTerm:
            option = Defaults[.iTermNewOption]
        case .hyper, .alacritty:
            return nil
        }
        
        return option.map(NewOptionType.init(rawValue: )) ?? nil
    }
    
    public func setNewOption(_ terminal: TerminalType, _ newOption: NewOptionType) {
        
        switch terminal {
        case .terminal:
            Defaults[.terminalNewOption] = newOption.rawValue
        case .iTerm:
            Defaults[.iTermNewOption] = newOption.rawValue
        case .hyper, .alacritty:
            return
        }
    }
    
    public func getClearOption(_ terminal: TerminalType) -> ClearOptionType? {
        var option: String?
        switch terminal {
        case .terminal:
            option = Defaults[.terminalClearOption]
        case .iTerm:
            option = Defaults[.iTermClearOption]
        case .hyper, .alacritty:
            return nil
        }
        
        return option.map(ClearOptionType.init(rawValue: )) ?? nil
    }
    
    public func setClearOption(_ terminal: TerminalType, _ clearOption: ClearOptionType) {
        
        switch terminal {
        case .terminal:
            Defaults[.terminalClearOption] = clearOption.rawValue
        case .iTerm:
            Defaults[.iTermClearOption] = clearOption.rawValue
        case .hyper, .alacritty:
            return
        }
    }
    
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
            
            let newOption = TerminalManager.shared.getNewOption(terminalType) ?? .window
            let clearOption = TerminalManager.shared.getClearOption(terminalType) ?? .noClear
            try terminal.open(path, newOption, clearOption)
        } catch {
            log(error, .error)
        }
    }
    
    // MARK: private methods
    
    private func pickTerminalAlert() -> TerminalType? {
        
        let alert = NSAlert()
        
        alert.messageText = "Open In?"
        alert.informativeText = "Please select one of the following terminals as the default terminal to open."
        
        // Add button and avoid the focus ring
        alert.addButton(withTitle: "Cancel").refusesFirstResponder = true
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
