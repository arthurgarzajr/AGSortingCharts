//
//  BubbleSort.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 24.2.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation

/**
 Implementation of the Bubble sort algorithm.
 
 Bubble sort performs poorly in real world use and is used primarily as an educational tool. Note that using very large
 arrays slows down the sorting using BubbleSort considerably.
 
 See https://en.wikipedia.org/wiki/Bubble_sort
 */
struct BubbleSort: SortMethod {

   /// Name of the BubbleSort is "BubbleSort".
   var name: String {
      "BubbleSort"
   }

   /// A short description of the Bubblesort.
   var description: String {
      """
      Bubble sort is a simple sorting algorithm that repeatedly steps through the list, compares adjacent elements and swaps them if they are in the wrong order.
      
      The pass through the list is repeated until the list is sorted. Bubble sort performs poorly in real world use and is used primarily as an educational tool.
      
      Do not use large arrays unless you really have time to wait and see how the sorting goes.

      Click on the animation to abort the sort and move to next sort.
      """
   }

   var webLinks: [(String, String)] {
      [("Wikipedia on BubbleSort", "https://en.wikipedia.org/wiki/Bubble_sort")]
   }

   /// Implements the size property declared in the `SortMethod` protocol. This is the size of the array to sort.
   let size: Int

   /// A variable to address the sortable (not yet sorted) size of the array.
   private var sortSize: Int = 0

   /// A variable to keep track where sorting has advanced to.
   private var newSize: Int = 0

   /// Loop index variable for sorting the array.
   private var innerIndex: Int = 1

   /// Initializes the BubbleSort.
   init(arraySize: Int) {
      size = arraySize
      sortSize = size
   }

   /// Restarts the bubble sort, resets the member variables.
   mutating func restart() {
      innerIndex = 1
      sortSize = size
   }

   /** Implements the SortMethod protocol with bubble sort method.
    Note that the algorithm modifies the array size member variable, and that will eventually
    cause the method returning true. Until that, false is always returned at the end of the method.
    See protocol documentation for details of the method.
    */
   mutating func nextStep(array: [BarValue], swappedItems : inout SwappedItems) -> Bool {
       if sortSize <= 1 {
           array[0].color = .blue
           return true
       }
       
       if array[innerIndex-1] > array[innerIndex] {
           swappedItems.first = innerIndex-1
           swappedItems.second = innerIndex
           newSize = innerIndex
           swappedItems.currentIndex2 = newSize
           array[innerIndex - 1].color = .blue
           array[innerIndex].color = .gray
       } else {
           array[innerIndex].color = .blue
           array[innerIndex-1].color = .gray
       }
       
       if innerIndex >= sortSize - 1 {
           var startIndex = newSize + 1
           while startIndex < array.count {
               array[startIndex].color = .blue
               startIndex += 1
           }
           sortSize = newSize
           
           swappedItems.currentIndex2 = newSize
           innerIndex = 1
           swappedItems.currentIndex1 = innerIndex
           newSize = 0
       } else {
           innerIndex += 1
           swappedItems.currentIndex1 = innerIndex
       }
       return false
   }

   /**
    Implementation of the BubbleSort in two tight loops.
    - parameter: array The array to sort.
    */
   mutating func realAlgorithm(array: inout [BarValue]) {
      sortSize = array.count
      repeat {
         newSize = 0
         for index in 1...sortSize-1 where array[index-1] > array[index] {
            array.swapAt(index-1, index)
            newSize = index
         }
         sortSize = newSize
      } while sortSize > 1
   }
}
