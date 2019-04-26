//
//  EditorProtocol.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2019/4/27.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public protocol Editor {
    
    func open(_ path: String) throws
    
}
