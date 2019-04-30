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
    
    /// get default editor from UserDefaults
    public func getDefaultEditor() -> EditorType? {
        return Defaults[.defaultEditor]
            .map(EditorType.init(rawValue: )) ?? nil
    }
    
    /// get default editor from UserDefaults or AlertBox
    public func getOrPickDefaultEditor() -> EditorType? {
        
        if let defaultEditor = getDefaultEditor() {
            return defaultEditor
        }
        
        guard let selectedEditor = pickEditorAlert() else {
            return nil
        }
        
        setDefaultEditor(selectedEditor)
        
        return selectedEditor
    }
    
    public func setDefaultEditor(_ editor: EditorType) {
        Defaults[.defaultEditor] = editor.rawValue
    }
    
    public func removeDefaultEditor() {
        Defaults.removeObject(forKey: Constants.Key.defaultEditor)
    }
    
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
    
    // MARK: private methods
    
    private func pickEditorAlert() -> EditorType? {
        
        let alert = NSAlert()
        
        alert.messageText = "Open In?"
        alert.informativeText = "Please select one of the following editors as the default editor to open."
        
        // Add button and avoid the focus ring
        alert.addButton(withTitle: "Cancel").refusesFirstResponder = true
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
