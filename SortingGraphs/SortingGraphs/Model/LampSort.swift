//
//  LampSort.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 26.2.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation

/**
 LampSort implements the non-recursive version of QuickSort.
 
 The algorithm uses two stacks to keep lower and higher indexes between which sorting
 happens, and sorts these ranges. See the animation in action on how this method behaves.
 
 For more information, see e.g. https://medium.com/concerning-pharo/lampsort-a-non-recursive-quicksort-implementation-4d4891b217bd
 */
struct LampSort: SortMethod {

   let size: Int

   /// Holds the indexes to the lower indexes of areas to sort.
   private var lows = Stack<Int>()
   /// Holds the indexes to the higher indes values to sort.
   private var highs = Stack<Int>()

   private var low: Int = 0
   private var high: Int = 0
   private var span: Int = 0
   private var innerForLoopIndex = -1
   private var pivotIndex = -1
   private var pivot = 0

   /// The state variable used in step by step sorting.
   private enum State {
      /// The outer loop' first steps to execute.
      case outerLoopFirstPart
      /// The inner loop area to execute.
      case innerForLoop
      // The inner loop second part to execute.
      case outerLoopSecondPart
      /// Algorithm is done sorting.
      case finished
   }
   private var state = State.outerLoopFirstPart

   /// The name of the sort method.
   var name: String {
      "LampSort"
   }

   /// Short description for the sort method.
   var description: String {
      """
      Recursion is not fundamental to the Quick sort algorithm. Lamp sort is an implementation without recursion.

      This implementation uses two stacks to control the areas to be sorted in different passes.

      The fundamental step of the sort is the partition operation. Given an interval [start, stop] over the data array, partitioning picks a pivot, any element inside the interval. Then split the interval in two: one containing the elements smaller than the pivot and one containing the elements larger than the pivot.

      After this, continue on subintervals. Intervals with zero or one element are sorted. The third step utilizes stacks adding the complete interval to the stacks. In partitioning, take an interval, split it and add the 2 sub intervals. Empty intervals with one value get removed. Eventually the stacks will be empty, sorting done.
      """
   }

   var webLinks: [(String, String)] {
      [("Bertrand Meyer blog", "https://bertrandmeyer.com/2014/12/07/lampsort/"), ("Leslie Lamport video", "https://channel9.msdn.com/Events/Build/2014/3-642"), ("Sven VC Medium article", "https://medium.com/concerning-pharo/lampsort-a-non-recursive-quicksort-implementation-4d4891b217bd")]
   }

   /// Initializes the sorting method.
   init(arraySize: Int) {
      size = arraySize
      restart()
   }

   /// Restarts the method by resetting all members to initial state.
   mutating func restart() {
      while !lows.isEmpty {
         _ = lows.pop()
      }
      while !highs.isEmpty {
         _ = highs.pop()
      }
      low = 0
      high = 0
      span = 0
      innerForLoopIndex = -1
      pivotIndex = -1
      lows.push(0)
      highs.push(size-1)
      state = .outerLoopFirstPart
   }

   /**
    Peforms a step in Lampsort. Caller will do the actual moving/swapping of values in the array.
    - parameter array: The array containing the elements to sort.
    - parameter swappedItems: The object which will have the indexes to swap after step has been executed.
    - returns: Returns true if after this step, the array has been sorted.
    */
   mutating func nextStep(array: [BarValue], swappedItems: inout SwappedItems) -> Bool {

      if size < 2 || (state == .outerLoopFirstPart && lows.isEmpty) {
         state = .finished
         return true
      }

      switch state {
      case .outerLoopFirstPart:
         low = lows.pop()!
         high = highs.pop()!
         span = high - low

         precondition((low >= 0) && (low < size))
         precondition((high >= 0) && (high < size))
         precondition(low <= high)

         if span >= 2 {
            pivotIndex = low
             pivot = array[high].value
            innerForLoopIndex = low
            state = .innerForLoop
            swappedItems.currentIndex1 = pivotIndex
            swappedItems.currentIndex2 =  innerForLoopIndex
         } else if span == 1 && low != high && array[low] > array[high] {
            swappedItems.first = low
            swappedItems.second = high
         }

      case .innerForLoop:
          if array[innerForLoopIndex].value < pivot {
            if pivotIndex != innerForLoopIndex {
               swappedItems.first = pivotIndex
               swappedItems.second = innerForLoopIndex
            }
            pivotIndex += 1
            swappedItems.currentIndex1 = pivotIndex
         }
         innerForLoopIndex += 1
         swappedItems.currentIndex2 =  innerForLoopIndex
         if innerForLoopIndex == high {
            state = .outerLoopSecondPart
         }

      case .outerLoopSecondPart:
         swappedItems.first = pivotIndex
         swappedItems.second = high

         // Create the next two intervals.
         lows.push(low)
         highs.push(max(low, pivotIndex - 1))
         lows.push(min(pivotIndex + 1, high))
         highs.push(high)
         state = .outerLoopFirstPart

      case .finished:
         return true
      }
      return false
   }

   /**
    Executes the "real" Lampsort algoritm in one go using loops.
    - parameter array: The array to sort.
    */
   mutating func realAlgorithm(array: inout [BarValue]) {
      var low: Int
      var high: Int
      var span: Int
      let size = array.count

      if size < 2 { return }

      lows.push(0)
      highs.push(size-1)
      var swappedItems = SwappedItems()

      repeat {
         low = lows.pop()!
         high = highs.pop()!

         span = high - low

         assert((low >= 0) && (low < size))
         assert((high >= 0) && (high < size))
         assert(low <= high)

         if span >= 2 {
            pivotIndex = low
            let pivot = array[high]

            for index in low..<high where array[index] < pivot {
               if pivotIndex != index {
                  swappedItems.first = pivotIndex
                  swappedItems.second = index
                  array.swapAt(swappedItems.first, swappedItems.second)
               }
               pivotIndex += 1
            }

            // Swap the pivot at hi in at the right index.
            if pivotIndex != high {
               swappedItems.first = pivotIndex
               swappedItems.second = high
               array.swapAt(swappedItems.first, swappedItems.second)
            }
            // Create the next two intervals.
            lows.push(low)
            highs.push(max(low, pivotIndex - 1))
            lows.push(min(pivotIndex + 1, high))
            highs.push(high)

         } else if span == 1 {
            if low != high && array[low] > array[high] {
               swappedItems.first = low
               swappedItems.second = high
               array.swapAt(swappedItems.first, swappedItems.second)
            }
         }
      } while !lows.isEmpty
   }

}
