//
//  HeapSort.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 6.10.2021.
//  Copyright © 2021 Antti Juustila. All rights reserved.
//

import Foundation

/**
 Heapsort is an improved selection sort: like selection sort, heapsort divides its input into a sorted and an unsorted region, and it iteratively shrinks the unsorted region by extracting the largest element from it and inserting it into the sorted region.

 Unlike selection sort, heapsort does not waste time with a linear-time scan of the unsorted region; rather, heap sort maintains the unsorted region in a heap data structure (binary tree) to more quickly find the largest element in each step.

 Although somewhat slower in practice on most machines than a well-implemented quicksort, it has the advantage of a more favorable worst-case O(n log n) runtime. Heapsort is an in-place algorithm, but it is not a stable sort.

 See https://en.wikipedia.org/wiki/Heapsort
 */
struct HeapSort: SortMethod {
   /**
    Initializes the Heapsort with the size of the array to sort.
    - parameter arraySize The size of the array
    */
   init(arraySize: Int) {
      size = arraySize
   }

   /// The array size.
   var size: Int

   /// Name of the sorting method.
   var name: String {
      "HeapSort"
   }

   /// Description of the sorting method.
   var description: String {
      """
      Heapsort is an improved selection sort: like selection sort, heapsort divides its input into a sorted and an unsorted region, and it iteratively shrinks the unsorted region by extracting the largest element from it and inserting it into the sorted region.

      Unlike selection sort, heapsort does not waste time with a linear-time scan of the unsorted region; rather, heap sort maintains the unsorted region in a heap data structure (binary tree) to more quickly find the largest element in each step.

      Although somewhat slower in practice on most machines than a well-implemented quicksort, it has the advantage of a more favorable worst-case O(n log n) runtime. Heapsort is an in-place algorithm, but it is not a stable sort.
      """
   }

   /// Weblinks to read more information.
   var webLinks: [(String, String)] {
      [("Wikipedia on HeapSort", "https://en.wikipedia.org/wiki/Heapsort")]
   }

   /// Restarts the sorting method by giving intial values to member variables.
   mutating func restart() {
      state = .heapifying
      startIndex = parent(size - 1)
      endIndex = size - 1
      rootIndex = startIndex
      state = .siftingDown
   }

   /// Executes a step of the sorting.
   /// - parameter array The array that is sorted.
   /// - parameter swappedItems The structure to put the indexes to sort, sorting is done elsewhere.
   /// - returns Returns true if the sorting is done.
   mutating func nextStep(array: [BarValue], swappedItems: inout SwappedItems) -> Bool {

      if size < 2 {
         return true
      }
      
      switch state {
      case .finished:
         return true
      case .heapifying:
         if startIndex > 0 {
            state = .siftingDown
            stateBeforeSifting = .heapifying
            startIndex -= 1
            rootIndex = startIndex
            state = .siftingDown
            swappedItems.currentIndex1 = startIndex
            swappedItems.currentIndex2 = endIndex
         } else {
            endIndex = size - 1
            swappedItems.currentIndex2 = endIndex
            state = .mainWhileLoop
            // rootIndex = startIndex
         }
      case .mainWhileLoop:
         if endIndex > 0 {
            swappedItems.first = 0
            swappedItems.second = endIndex
            endIndex -= 1
            startIndex = 0
            swappedItems.currentIndex1 = startIndex
            swappedItems.currentIndex2 = endIndex
            rootIndex = startIndex
            state = .siftingDown
            stateBeforeSifting = .mainWhileLoop
         } else {
            state = .finished
         }
      case .siftingDown:
         // do sift down while loop and ...
         if leftChild(rootIndex) <= endIndex {
            let child = leftChild(rootIndex)
            var swap = rootIndex
            if array[swap] < array[child] {
               swap = child
            }
            if child + 1 <= endIndex && array[swap] < array[child+1] {
               swap = child + 1
            }
            if swap == rootIndex {
               state = stateBeforeSifting // Back to caller
            } else {
               swappedItems.first = rootIndex
               swappedItems.second = swap
               rootIndex = swap
            }
         } else {
            // after sifting is done do:
            state = stateBeforeSifting
         }
      }
      return state == .finished
   }

   private var startIndex: Int = 0
   private var endIndex: Int = 0
   private var rootIndex: Int = 0

   /// States of the step-by-step algorithm.
   private enum State {
      /// Is doing the heapifying before sifting down.
      case heapifying
      /// Is in the main while loop after heapify.
      case mainWhileLoop
      /// Is sifting down, either from heapify or from main while loop.
      case siftingDown
      /// Work is done.
      case finished
   }
   /// The state of the step-by-step algorithm.
   private var state: State = .heapifying
   /// To which state to return after sifting down.
   private var stateBeforeSifting: State = .heapifying

   /// The real algorithm without step-by-step execution.
   /// - parameter array The array to sort.
   mutating func realAlgorithm(array: inout [BarValue]) {
      if array.count < 2 {
         return
      }
      heapify(&array, array.count)
      var end = array.count - 1
      while end > 0 {
         let tmp = array[0]
         array[0] = array[end]
         array[end] = tmp
         end -= 1
         siftDown(&array, start: 0, end: end)
      }
   }

   /// Heapify
   /// - parameter array The array to heapify.
   /// - parameter count The count of elements in the array.
   private func heapify( _ array: inout [BarValue], _ count: Int) {
      var start = parent(count - 1)
      while start >= 0 {
         siftDown(&array, start: start, end: count - 1)
         start -= 1
      }
   }

   /// Sifts the values to their correct places in the heap.
   /// - parameter array The array to sort.
   /// - parameter start The starting index.
   /// - parameter end The ending index.
   private func siftDown(_ array: inout [BarValue], start: Int, end: Int) {
      var root = start
      while leftChild(root) <= end {
         let child = leftChild(root)
         var swap = root
         if array[swap] < array[child] {
            swap = child
         }
         if child + 1 <= end && array[swap] < array[child+1] {
            swap = child + 1
         }
         if swap == root {
            return
         } else {
            let tmp = array[root]
            array[root] = array[swap]
            array[swap] = tmp
            root = swap
         }
      }
   }

   /// Heap utility method to get the parent node of an index.
   /// - parameter index The index the parent of which is looked for.
   /// - returns The index of the parent node.
   private func parent(_ index: Int) -> Int {
      return Int(((Double(index) - 1.0)/2.0).rounded(.towardZero))
   }

   /// Heap utility method to get the left child node of an index.
   /// - parameter index The index the left child of which is looked for.
   /// - returns The index of the left child.
   private func leftChild(_ index: Int) -> Int {
      return 2 * index + 1
   }

   /// Heap utility method to get the right child node of an index.
   /// - parameter index The index the right child of which is looked for.
   /// - returns The index of the right child.
   private func rightChild(_ index: Int) -> Int {
      return 2 * index + 2
   }

}
