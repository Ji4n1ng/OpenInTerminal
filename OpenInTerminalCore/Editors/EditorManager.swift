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
    
    /// get default editor from UserDefaults or AlertBox
    ///
    /// If there is no default editor, then the user will pick a terminal in AlertBox.
    public func getDefaultEditor() -> EditorType? {
        
        if let defaultEditor = getUserDefaultEditor() {
            return defaultEditor
        }
        
        guard let selectedEditor = pickEditorAlert() else {
            return nil
        }
        
        Defaults[.defaultEditor] = selectedEditor.rawValue
        
        return selectedEditor
    }
    
    public func getVisible(_ editor: EditorType) -> VisibleType? {
        var visble: String?
        switch editor {
        case .vscode:
            visble = Defaults[.vscodeVisible]
        case .atom:
            visble = Defaults[.atomVisible]
        case .sublime:
            visble = Defaults[.sublimeVisible]
        }
        
        return visble.map(VisibleType.init(rawValue: )) ?? nil
    }
    
    public func setVisible(_ editor: EditorType, _ visible: VisibleType) {
        
        switch editor {
        case .vscode:
            Defaults[.vscodeVisible] = visible.rawValue
        case .atom:
            Defaults[.atomVisible] = visible.rawValue
        case .sublime:
            Defaults[.sublimeVisible] = visible.rawValue
        }
    }
    
    public func openEditor(_ editorType: EditorType) {
        do {
            let path = try FinderManager.shared.getFullPathToFrontFinderWindowOrSelectedFile()
            guard path != "" else { return }
            
            let editor = editorType.instance()
            
            try editor.open(path)
            
        } catch {
            log(error, .error)
        }
    }
    
    // MARK: private methods
    
    private func getUserDefaultEditor() -> EditorType? {
        return Defaults[.defaultEditor]
            .map(EditorType.init(rawValue: )) ?? nil
    }
    
    private func pickEditorAlert() -> EditorType? {
        
        let alert = NSAlert()
        
        alert.messageText = "Open In?"
        alert.informativeText = "Please select one of the following editors as the default editor to open."
        
        // Add button and avoid the focus ring
        alert.addButton(withTitle: "Cancel").refusesFirstResponder = true
        alert.addButton(withTitle: EditorType.sublime.abbreviation).refusesFirstResponder = true
        alert.addButton(withTitle: EditorType.atom.abbreviation).refusesFirstResponder = true
        alert.addButton(withTitle: EditorType.vscode.abbreviation).refusesFirstResponder = true
        
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
