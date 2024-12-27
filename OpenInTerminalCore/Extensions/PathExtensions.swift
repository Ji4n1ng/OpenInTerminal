//
//  PathExtensions.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 11/22/24.
//  Copyright © 2024 Jianing Wang. All rights reserved.
//

import Foundation

// MARK: - Escape

public extension String {
    
    /// Handle space in name.
    /// `count`: number of escape characters.
    func nameSpaceEscaped(_ count: Int = 1) -> String {
        let escapeChar = String(repeating: "\\", count: count)
        let escapeSpace = escapeChar + " "
        let replaced = self.replacingOccurrences(of: " ", with: escapeSpace)
        return replaced
    }
    
    /// Handle special char in path.
    /// `count`: number of escape characters.
    func specialCharEscaped(_ count: Int = 1) -> String {
        let escapeChar = String(repeating: "\\", count: count)
        var result = ""
        let set: [Character] = [" ", "(", ")", "&", "|", ";",
                                "\"", "'", "<", ">", "`"]
        for char in self {
            if set.contains(char) {
                result += escapeChar
            }
            result.append(char)
        }
        return result
    }
    
    // FIXME: if path contains "\" or """, application will crash.
    // Special symbols have been tested, excluding backslashes and double quotes.
    func terminalPathEscaped() -> String {
        var result = ""
        let set = CharacterSet.alphanumerics
        for char in self.unicodeScalars {
            if set.contains(char) || char == "/" {
                result.unicodeScalars.append(char)
            } else {
                result += "\\\\"
                result.unicodeScalars.append(char)
            }
        }
        return result
    }
}

// MARK: - URL

public extension URL {
    
    /// Get the directory part of the URL by removing the last part if it's a file.
    mutating func getDirectory() {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                self = self.deletingLastPathComponent()
            }
        }
    }
    
}
