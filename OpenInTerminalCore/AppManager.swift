//
//  AppManager.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/12/18.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

public class AppManager {
    
    public static var shared = AppManager()
    
    public func pickTerminalAlert() -> App? {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("alert.pick_terminal_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_terminal_description", comment: "Please select one of the following terminals as the default terminal to open.")
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.hyper.shortName).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.iTerm.shortName).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.terminal.shortName).refusesFirstResponder = true
        let modalResult = alert.runModal()
        switch modalResult {
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return SupportedApps.hyper.app
        case .alertThirdButtonReturn:
            return SupportedApps.iTerm.app
        default:
            return SupportedApps.terminal.app
        }
    }
    
    public func pickEditorAlert() -> App? {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("alert.pick_editor_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_editor_description", comment: "Please select one of the following editors as the default editor to open.")
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.sublime.shortName).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.atom.shortName).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.vscode.shortName).refusesFirstResponder = true
        let modalResult = alert.runModal()
        switch modalResult {
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return SupportedApps.sublime.app
        case .alertThirdButtonReturn:
            return SupportedApps.atom.app
        default:
            return SupportedApps.vscode.app
        }
    }
    
}
