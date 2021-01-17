//
//  ScriptGenerator.swift
//  OpenInTerminal
//
//  Created by Jianing Wang on 2019/10/15.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import OpenInTerminalCore

/// Install AppleScripts to $HOME/Library/Application Scripts/wang.jianing.app.OpenInTerminalFinderExtension
func checkScripts() throws {
    guard var scriptFolderPath = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
        throw OITMError.cannotAccessPath("$HOME/Library/Application Scripts/wang.jianing.app.OpenInTerminal")
    }
    scriptFolderPath.deleteLastPathComponent()
    let finderExScriptPath = scriptFolderPath.appendingPathComponent(Constants.Id.FinderExtension)
    if !FileManager.default.fileExists(atPath: finderExScriptPath.path) {
        try FileManager.default.createDirectory(atPath: finderExScriptPath.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }
    
    func writeScriptIfNeeded(at path: URL, with script: String) throws {
        if FileManager.default.fileExists(atPath: path.path) {
            // check if the existing file's content is the same as `script`
            let existingScript = try String(contentsOf: path, encoding: String.Encoding.utf8)
            if existingScript == script {
                // don't need to write again
                return
            }
        }
        try script.write(to: path, atomically: true, encoding: String.Encoding.utf8)
    }
    
    // write general script
    let generalScriptName = ScriptManager.shared.getGeneralScriptName()
    let generalScriptPath = finderExScriptPath
        .appendingPathComponent(generalScriptName)
        .appendingPathExtension("scpt")
    let generalScript = ScriptManager.shared.getGeneralScript()
    try writeScriptIfNeeded(at: generalScriptPath, with: generalScript)
    
    // write terminal new tab script
    let tabScriptName = ScriptManager.shared.getTerminalNewTabScriptName()
    let tabScriptPath = finderExScriptPath
        .appendingPathComponent(tabScriptName)
        .appendingPathExtension("scpt")
    let tabScript = ScriptManager.shared.getTerminalNewTabAppleScript()
    try writeScriptIfNeeded(at: tabScriptPath, with: tabScript)
    
}
