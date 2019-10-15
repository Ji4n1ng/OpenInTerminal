//
//  EditorManager.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public class EditorManager {
    
    public static let shared: EditorManager = EditorManager()
    
    // MARK: public methods
    
    public func openEditor(_ editorType: EditorType) {
        do {
            var path = try FinderManager.shared.getFullPathToFrontFinderWindowOrSelectedFile()
            if path == "" {
                // No Finder window and no file selected.
                let homePath = NSHomeDirectory()
                guard let homeUrl = URL(string: homePath) else { return }
                path = homeUrl.appendingPathComponent("Desktop").path
            }
            
            let editor = editorType.instance()
            
            try editor.open(path)
            
        } catch {
            logw(error.localizedDescription)
        }
    }
    
    public func pickEditorAlert() -> EditorType? {
        
        let alert = NSAlert()
        
        alert.messageText = NSLocalizedString("alert.pick_editor_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_editor_description", comment: "Please select one of the following editors as the default editor to open.")
        
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: EditorType.sublime.rawValue).refusesFirstResponder = true
        alert.addButton(withTitle: EditorType.atom.rawValue).refusesFirstResponder = true
        alert.addButton(withTitle: EditorType.vscode.rawValue).refusesFirstResponder = true
        
        let modalResult = alert.runModal()
        
        switch modalResult {
            
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return .sublime
        case .alertThirdButtonReturn:
            return .atom
        default:
            return .vscode
        }
    }
}
