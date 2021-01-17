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
    
    if let editorName = DefaultsManager.shared.liteDefaultEditor {
        let editor = App(name: editorName, type: .editor)
        try editor.openOutsideSandbox()
    } else {
        guard let selectedEditor = AppManager.shared.pickEditorAlert() else {
            throw OITLError.cannotGetEditor
        }
        DefaultsManager.shared.liteDefaultTerminal = selectedEditor.name
        try selectedEditor.openOutsideSandbox()
    }
    
} catch {
    logw(error.localizedDescription)
}
