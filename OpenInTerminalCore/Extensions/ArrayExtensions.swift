//
//  ArrayExtensions.swift
//  OpenInTerminalCore
//
//  Created by Jianing Wang on 2020/4/6.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation

public extension Array {
    
    mutating func move(from start: Index, to end: Index) {
        guard (0..<count) ~= start, (0...count) ~= end else { return }
        if start == end { return }
        let targetIndex = start < end ? end - 1 : end
        insert(remove(at: start), at: targetIndex)
    }
    
    mutating func move(with indexes: IndexSet, to toIndex: Index) {
        let movingData = indexes.map{ self[$0] }
        let targetIndex = toIndex - indexes.filter{ $0 < toIndex }.count
        for (i, e) in indexes.enumerated() {
            remove(at: e - i)
        }
        insert(contentsOf: movingData, at: targetIndex)
    }
}

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
