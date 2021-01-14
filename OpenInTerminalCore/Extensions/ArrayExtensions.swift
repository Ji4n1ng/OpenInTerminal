//
//  ArrayExtensions.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/4/6.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

public extension Array where Element == String {
    
    func sortedIgnoreCase() -> [String] {
        return sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
    }
    
    mutating func sortIgnoreCase() {
        sort { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
    }
    
}

public extension Array where Element == App {
    
    func sortedIgnoreCase() -> [App] {
        return sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending }
    }
    
    mutating func sortIgnoreCase() {
        sort { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending }
    }
    
}


public extension Array where Element: Equatable {
    
    mutating func remove(element: Element) {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }
}
