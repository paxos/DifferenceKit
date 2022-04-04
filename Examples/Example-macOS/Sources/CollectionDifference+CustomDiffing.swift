//
//  CollectionDifference+CustomDiffing.swift
//  ghNotifier
//
//  Created by Patrick Dinger on 4/4/22.
//  Copyright © 2022 Patrick Dinger. All rights reserved.
//

import Foundation

public extension CollectionDifference where ChangeElement: Hashable
{
    typealias Steps = [CollectionDifference<ChangeElement>.ChangeStep]
    
    enum ChangeStep
    {
        case insert(_ element: ChangeElement, at: Int)
        case remove(_ element: ChangeElement, at: Int)
        case move(_ element: ChangeElement, from: Int, to: Int)
    }
    
    internal var maxOffset: Int { Swift.max(removals.last?.offset ?? 0, insertions.last?.offset ?? 0) }
    
    var steps: Steps
    {
        guard !isEmpty else { return [] }
        
        // A mapping to modify insertion indexees
        let mapSize = maxOffset + count
        var insertionMap = Array(0 ... mapSize)
        
        // Items that may have been completed early relative to the Changes
        var completeRemovals = Set<Int>()
        var completeInsertions = Set<Int>()
        
        var steps = Steps()
        
        inferringMoves().forEach
        { change in
            switch change
            {
            case let .remove(offset, element, associatedWith):
                if associatedWith != nil
                {
                    // Delayed removals can make step changes in insert locations
                    insertionMap.remove(at: offset)
                }
                else
                {
                    steps.append(.remove(element, at: offset))
                    completeRemovals.insert(offset)
                }

            case let .insert(offset, element, associatedWith):
                if let associatedWith = associatedWith
                {
                    let from = associatedWith
                        - completeRemovals.filter { $0 < associatedWith }.count
                        + completeInsertions.filter { $0 < associatedWith }.count
                    
                    // Late removals re-adjust the insertion map by reducing higher indexes
                    insertionMap.indices.forEach
                    {
                        if insertionMap[$0] >= associatedWith { insertionMap[$0] -= 1 }
                    }
                    
                    let to = insertionMap[offset]
                    
                    steps.append(.move(element, from: from, to: to))
                    
                    completeRemovals.insert(associatedWith)
                    completeInsertions.insert(to)
                }
                else
                {
                    let to = insertionMap[offset]
                    steps.append(.insert(element, at: to))
                    completeInsertions.insert(to)
                }
            }
        }

        return steps
    }
}

extension CollectionDifference.Change
{
    var offset: Int
    {
        switch self
        {
        case let .insert(offset, _, _): return offset
        case let .remove(offset, _, _): return offset
        }
    }
}
