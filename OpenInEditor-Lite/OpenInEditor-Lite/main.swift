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
    
    guard let editorType = EditorManager.shared.getOrPickDefaultEditor() else {
        throw OITLError.cannotGetEditor
    }
    
    EditorManager.shared.openEditor(editorType)
    
} catch {
    logw(error.localizedDescription)
}
