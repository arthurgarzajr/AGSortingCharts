//
//  NumberCollection.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 19.2.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation

/**
 Declare an extension to Int array to be able to easily prepare an array either
 - with integers from a specified range and count of numbers, or
 - with sequence of integers from 1 to count of numbers.
 
 - Author:
   Antti Juustila
 - Copyright:
   © 2020 Antti Juustila, all rights reserved.
 */
extension Array where Element == BarValue {

   /**
    Prepare an array with a count of random numbers from a specified range.
    - parameter range: The range of values the array is holding, e.g. -10..-10.
    - parameter count: The count of numbers to generate to the array, randomly.
    */
//   mutating func prepare(range: ClosedRange<Int>, count: Int) {
//      precondition(!range.isEmpty)
//      removeAll()
//      reserveCapacity(count)
//      for _ in 0..<count {
//         append(Int.random(in: range))
//      }
//   }

   /**
    Prepare an array from a specified range sequentially.
    - parameter range: The range of values the array is holding, e.g. -10..-10.
    */
//   mutating func prepare(range: ClosedRange<Int>) {
//      precondition(!range.isEmpty)
//      removeAll()
//      reserveCapacity(range.count)
//      for number in range {
//         append(number)
//      }
//   }

   /**
    Prepare an array of numbers from 1 to `count` sequentially.
    - parameter count: The count of numbers to generate.
    */
//   mutating func prepare(count: Int) {
//      removeAll()
//      reserveCapacity(count)
//      for number in 1...count {
//         append(number)
//      }
//   }

   /**
    Does the sort operation to the array, depending on the operation parameter.
    If operation is .moveValue, moves the value in the "first" item to index in the second item.
    If operation is .swap, swaps the values indicated by the indexes in first and second.
    - parameter operation: The indexes in the array to operate on, depending on the operation type.
    */
   mutating func handleSortOperation(operation: SwappedItems) {
      if operation.operation == .moveValue {
         if operation.second >= 0 && operation.second < count {
             self[operation.second].value = operation.first
         }
      } else {
         if operation.first >= 0 && operation.second >= 0 && operation.first < count && operation.second < count {
            swapAt(operation.first, operation.second)
         }
      }
   }

   /**
    Utility function to test if an array is sorted.
    - returns Returns true if the array is sorted, otherwise false.
    */
   func isSorted() -> Bool {
      var index = 0
      for number in self {
         if index < self.count - 1 {
            if number > self[index+1] {
               return false
            }
         }
         index += 1
      }
      return true
   }

   /**
    Utility function used in testing to check if arrays contain the same elements
    in the same order.
    - parameter other The other array to compare with this one
    - returns Returns true if arrays are the same.
    */
   func containsSameElements(as other: [Element]) -> Bool {
      return self.count == other.count && self.sorted() == other.sorted()
   }

}
