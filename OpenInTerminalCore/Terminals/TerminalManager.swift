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
    
    /// get default terminal from UserDefaults or AlertBox
    ///
    /// If there is no default terminal, then the user will pick a terminal in AlertBox.
    /// Used in OpenInTerminal-Lite
    public func getDefaultTerminal() -> TerminalType? {
        
        if let defaultTerminal = getUserDefaultTerminal() {
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
        case .alacritty:
            option = Defaults[.alacrittyNewOption]
        }
        
        return option.map(NewOptionType.init(rawValue: )) ?? nil
    }
    
    public func setNewOption(_ terminal: TerminalType, _ newOption: NewOptionType) {
        
        switch terminal {
        case .terminal:
            Defaults[.terminalNewOption] = newOption.rawValue
        case .iTerm:
            Defaults[.iTermNewOption] = newOption.rawValue
        case .hyper:
            Defaults[.hyperNewOption] = newOption.rawValue
        case .alacritty:
            Defaults[.alacrittyNewOption] = newOption.rawValue
        }
    }
    
    public func getClearOption(_ terminal: TerminalType) -> ClearOptionType? {
        var option: String?
        switch terminal {
        case .terminal:
            option = Defaults[.terminalClear]
        case .iTerm:
            option = Defaults[.iTermClear]
        case .hyper, .alacritty:
            return .clear
        }
        
        return option.map(ClearOptionType.init(rawValue: )) ?? nil
    }
    
    public func setClearOption(_ terminal: TerminalType, _ clearOption: ClearOptionType) {
        
        switch terminal {
        case .terminal:
            Defaults[.terminalClear] = clearOption.rawValue
        case .iTerm:
            Defaults[.iTermClear] = clearOption.rawValue
        case .hyper, .alacritty:
            return
        }
    }
    
    public func getVisible(_ terminal: TerminalType) -> VisibleType? {
        var visible: String?
        switch terminal {
        case .terminal:
            visible = Defaults[.terminalVisible]
        case .iTerm:
            visible = Defaults[.iTermVisible]
        case .hyper:
            visible = Defaults[.hyperVisible]
        case .alacritty:
            visible = Defaults[.alacrittyVisible]
        }
        
        return visible.map(VisibleType.init(rawValue: )) ?? nil
    }
    
    public func setVisible(_ terminal: TerminalType, _ visible: VisibleType) {
        
        switch terminal {
        case .terminal:
            Defaults[.terminalVisible] = visible.rawValue
        case .iTerm:
            Defaults[.iTermVisible] = visible.rawValue
        case .hyper:
            Defaults[.hyperVisible] = visible.rawValue
        case .alacritty:
            Defaults[.alacrittyVisible] = visible.rawValue
        }
    }
    
    public func openTerminal(_ terminalType: TerminalType) {
        do {
            var path = try FinderManager.shared.getPathToFrontFinderWindowOrSelectedFile()
            if path == "" {
                // No Finder windows are opened or selected, so open home directory
                path = NSHomeDirectory()
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
    
    private func getUserDefaultTerminal() -> TerminalType? {
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
