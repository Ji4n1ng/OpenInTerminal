//
//  main.swift
//  OpenInEditor-Lite
//
//  Created by Jianing Wang on 2019/6/25.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import OpenInTerminalCore

do {

    if let editorType = DefaultsManager.shared.defaultEditor {
        EditorManager.shared.openEditor(editorType)
    } else {
        guard let selectedEditor = EditorManager.shared.pickEditorAlert() else {
            throw OITLError.cannotGetEditor
        }
        DefaultsManager.shared.defaultEditor = selectedEditor
        EditorManager.shared.openEditor(selectedEditor)
    }
    
} catch {
    logw(error.localizedDescription)
}
