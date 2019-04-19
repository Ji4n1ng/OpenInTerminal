//
//  log.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/10.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public enum LogType: String {
    case ln = "✏️"
    case warn = "⚠️"
    case error = "❗️"
    case date = "🕒"
    case url = "🌏"
    case json = "💡"
    case fuck = "🖕"
}

public func log<T>(_ message: T,
            _ type: LogType = .ln,
            file: String = #file,
            method: String = #function,
            line: Int    = #line) {
    #if DEBUG
    print("\(type.rawValue) \((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}
