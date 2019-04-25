//
//  AlacrittyApp.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/25.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

final class AlacrittyApp : Openable {
    
    func open(_ path: String, _ newOption: NewOptionType) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        let source = """
        do shell script "open -na alacritty --args --working-directory  \(url.path.alacrittyEscaped)"
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            log(error, .error)
            throw OITError.cannotAccessHyper
        }
    }
    
}


fileprivate extension String {
    
    // FIXME: if path contains "\" or """, application will crash.
    // Special symbols have been tested, except for backslashes and double quotes.
    var alacrittyEscaped: String {
        
        var result = ""
        let set: [Character] = [" ", "(", ")", "&", "|", ";",
                                "\"", "'", "<", ">", "`"]
        
        for char in self {
            if set.contains(char) {
                result += "\\\\"
            }
            result.append(char)
        }
        
        return result
    }
}
