//
//  ShellSort.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 18.3.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation

/**
 Implements the Shell sort algorithm. Shell sort is an in-place comparison sort. 
 
 Sorting is done one "gap" at a time. A gap can be thought of as a number of interleaved lists,
 each individually sorted.
 
 In this implementation, gap is taken to be the middle point of the array to sort.
 
 Note that this method uses the `SwappedItem` `Operation.move` rather than `Operation.swap` -- it moves the value in the
 first number to the index specified in the second number in SwappedItems. Using .swap operation is more common in the
 current implementations, as .move is used currently only by ShellSort.
 
 See https://en.wikipedia.org/wiki/Shellsort
 */
struct ShellSort: SortMethod {

   /// The size of the array to sort.
   let size: Int

   /// The name of the sort method.
   var name: String {
      "ShellSort"
   }

   /// The description of the Shellsort method.
   var description: String {
      """
      Shell sort is an in-place comparison sort.
      
      The method starts by sorting pairs of elements far apart from each other, then progressively reducing the gap between elements to be compared.
      
      Donald Shell published the first version of this sort in 1959.
      """
   }

   var webLinks: [(String, String)] {
      [("Wikipedia on ShellSort", "https://en.wikipedia.org/wiki/Shellsort"), ("Rosetta code on ShellSort", "https://rosettacode.org/wiki/Sorting_algorithms/Shell_sort")]
   }

   /// Inner loop index counter.
   private var innerIndex: Int = 0
   // Outer loop index counter.
   private var outerIndex: Int = 0

   /// The gap, divides the sorted array to sublist(s) to be sorted one at a time.
   private var gap = 0
   /// The value to move in the array.
   private var movableValue = 0

   /** State handling for ShellSort step by step sorting.
    
    The various loops in the `realAlgorithm()` implementation are "opened up" to `nextStep(...)` implementation
    using state variable. Depending on the state (which loop and which part of the loop) is executed, state
    is changed. See comments in `realAlgorithm(...)` for details.
   */
   private enum State {
      /// Sorting is executing the beginning part of second inner loop.
      case inLevel2LoopStart
      /// Sorting is executing the level 3 loop.
      case inLevel3Loop
      /// Sorting is executing second inner loop after the level 3 loop.
      case inLevel2LoopEnd
      /// Sorting is updating the gap variable (first level loop).
      case gapUpdate
   }
   /// The state variable holding the current state of the sorting.
   private var state: State = .inLevel2LoopStart

   /**
    Initializes the sorter to handle arrays of specific size.
    - parameter arraySize: The size of the array that is sorted.
    */
   init(arraySize: Int) {
      size = arraySize
      restart()
   }

   /// Restarts the sorter to start from beginning.
   mutating func restart() {
      gap = size / 2
      outerIndex = gap
      innerIndex = outerIndex
      state = .inLevel2LoopStart
      movableValue = 0
   }

   /**
    Performs a step in the sorting of the array. Caller will do the actual swapping of values in the array.
    See `State` and `realAlgorithm()` for explanations for the states.
    
    - parameter array: The array containing the elements to be sorted
    - parameter swappedItems: Will hold the indexes to swap if any.
    - returns: Returns true if the array is sorted.
    */
   mutating func nextStep(array: [BarValue], swappedItems : inout SwappedItems) -> Bool {

      // When gap is zero, the whole array should have been sorted.
      if gap == 0 {
         return true
      }

      switch state {
      case .gapUpdate:
         gap /= 2
         if gap == 0 {
            return true
         }
         outerIndex = gap
         swappedItems.currentIndex1 = outerIndex
         state = .inLevel2LoopStart

      case .inLevel2LoopStart:
          movableValue = array[outerIndex].value
         innerIndex = outerIndex
         swappedItems.currentIndex2 = innerIndex
         state = .inLevel3Loop

      case .inLevel3Loop:
          if innerIndex >= gap && array[innerIndex-gap].value > movableValue {
              swappedItems.first = array[innerIndex-gap].value
            swappedItems.second = innerIndex
            swappedItems.operation = .moveValue
            innerIndex -= gap
            swappedItems.currentIndex2 = innerIndex
         } else {
            state = .inLevel2LoopEnd
         }

      case .inLevel2LoopEnd:
         swappedItems.first = movableValue
         swappedItems.second = innerIndex
         swappedItems.operation = .moveValue
         outerIndex += 1
         swappedItems.currentIndex1 = outerIndex
         if outerIndex >= size {
            state = .gapUpdate
         } else {
            state = .inLevel2LoopStart
         }
      }
      return false
   }

   /**
    The tight loop implementation of Shell sort, sorting the array at one go.
    - parameter array: The array containing the elements to sort.
    */
   mutating func realAlgorithm(array: inout [BarValue]) {
      var gap = array.count / 2
      // This is the level 1 "gap update" loop, see nextStep()
      // where loop names are "opened up" as states.
      repeat {
         // For is the level 2 loop, which as a "start" part (before the level 3 loop)
         // and the "end" part (after the level 3 loop).
         for index2 in gap..<array.count {
            let temp = array[index2]
            var index3 = index2

            // This is the level 3 loop
            while index3 >= gap && array[index3-gap] > temp {
               array[index3] = array[index3-gap]
               index3 -= gap
            }
            array[index3] = temp
         }
         gap /= 2
      } while gap > 0
   }
}
