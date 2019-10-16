//
//  iTermApp.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/11.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

final class iTermApp: Terminal {
    
    func open(_ path: String, _ newOption: NewOptionType) throws {
        
        guard let url = URL(string: path) else {
            throw OITError.wrongUrl
        }
        
        let source = """
        do shell script "open -a iTerm \(url.path.specialCharEscaped)"
        """
        
        let script = NSAppleScript(source: source)!
        
        var error: NSDictionary?
        
        script.executeAndReturnError(&error)
        
        if error != nil {
            throw OITError.cannotAccessApp(TerminalType.iTerm.rawValue)
        }
    }
    
}

extension String {
    
    // FIXME: if path contains "\" or """, application will crash.
    // Special symbols have been tested, except for backslashes and double quotes.
    var specialCharEscaped: String {
        
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
