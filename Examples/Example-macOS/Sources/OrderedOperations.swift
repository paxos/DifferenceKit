////
////  OderedOperations.swift
////  DifferenceKit
////
////  Created by Patrick Dinger on 3/24/22.
////  Copyright © 2022 Ryo Aoyama. All rights reserved.
////
//
//import Foundation
//
//struct OrderedOperation {
//    var from: Int
//    var to: Int
//}
//
//class OrderedOperations {
//    var operations: [OrderedOperation] = []
//
//    init(unorderedOperations: [MovedElement]) {
//        operations = unorderedOperations.map { OrderedOperation(from: $0.source.element, to: $0.target.element) }
//    }
//
//    func convert() {
//        for operation in operations {
//            // The "from" is a removal, lets adjust everything behind it
//            decrementAllHigherThan(operation.from)
//            incrementAllHigherThan(operation.to)
//        }
//    }
//
//    func incrementAllHigherThan(_ index: Int) {
//        for index in 0 ..< operations.count {
//            if operations[index].from > index {
//                operations[index].from += 1
//            }
//            if operations[index].to > index {
//                operations[index].to += 1
//            }
//        }
//    }
//
//    func decrementAllHigherThan(_ index: Int) {
//        for index in 0 ..< operations.count {
//            if operations[index].from > index {
//                operations[index].from -= 1
//            }
//            if operations[index].to > index {
//                operations[index].to -= 1
//            }
//        }
//    }
//}
