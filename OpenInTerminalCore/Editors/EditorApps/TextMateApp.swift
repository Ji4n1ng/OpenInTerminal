//
//  TextMateApp.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/8/5.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

final class TextMateApp: Editor {
    
    func open(_ path: String) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        let source = """
        do shell script "open -a TextMate \(url.path.specialCharEscaped)"
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            throw OITError.cannotAccessApp(EditorType.textMate.rawValue)
        }
    }
    
}
