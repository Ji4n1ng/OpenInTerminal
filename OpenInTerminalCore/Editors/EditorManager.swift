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
    
    public func getVisble(editor: EditorType) -> VisibleType? {
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
    
}
