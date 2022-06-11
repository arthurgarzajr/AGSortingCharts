//
//  SortMethod.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 24.2.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation

/// Set debug to true to print debug output where implemented
/// and perform debug tests not performed in release versions.
let debug = false

/**
 Structure defining the operation when sorting an Int array.
 There are two kinds of operations. You can either *swap* the values, indicated
 by the indexes *first* and *second*. Or you can *move* the *value* in *first* variable to the *index*
 specified by the *second* index value.
 currentIndex1 and currentIndex2 are indexes to the array the sorting method is currently "keeping focus on".
 These are drawn as small circles in the centerline of the numbers.
 */
struct SwappedItems {
   /// The swap operations
   enum Operation {
      /// Swap the values of first and second indexes in the array.
      case swap
      /// Move the *value* in the *first* to the place indicated by the *second* *index*.
      case moveValue
   }
   /// The operation to perform, default is swap.
   var operation: Operation = .swap
   /// The index to swap or move values from. Value less than zero means that no move should be performed.
   var first = -1
   /// The index to swap or move values to. Value less than zero means that no move should be performed.
   var second = -1
   /// The first "current" index method is referring to. Shown in animation view.
   var currentIndex1 = -1
   /// The second "current" index method is referring to. Shown in animation view.
   var currentIndex2 = -1
}

/**
 A common protocol for all sorting methods.
 
 Note that the array to be sorted is hosted in an external object, and provided
 to the sorting methods as a parameter to the `nextStep()` method. Each execution of
 the nextStep() executes one relevant step of the sorting algorithm, usually leading into
 values changing places in the array to be sorted. This can then be animated in the UI.
 
 Protocol implementations must also implement `realAlgorithm()`, executing the sorting method
 in a tight loop. This is not animated in the UI, but used in comparing the speed of the
 algorithms.
 
 Note that when giving an array to be sorted to various sorting methods, the
 array each of them starts with must contain the same numbers in the same order -- otherwise
 the comparisons are not fair.
 
 */
protocol SortMethod {

   /**
    Initializes the sortmethod to sort an array with specific number of elements.
    - Parameters:
      - arraySize: The size of the array to initialize.
    */
   init(arraySize: Int)

   /// The size of the array to sort.
   var size: Int { get }

   /**
    The name of the sorting method. Should return a short descriptive name, like "BubbleSort".
    */
   var name: String { get }

   /**
    A 2-3 sentence description of the sorting method.
    */
   var description: String { get }

   /**
    A collection of a description and a link to a website with more information about the sort method.
    */
   var webLinks: [(String, String)] { get }

   /**
    Restarts the sorting by resetting all loop counters, etc.
    */
   mutating func restart()

   /**
    Does the next step in the sort, moving or switching two values in the array.
    Caller will do the actual swapping of values in the array.
    
    This method is called repeatedly until it returns true. After each step, the UI is updated to
    visualize the process of sorting.
    
    Note that caller should have swappedItems as a local variable *within* a loop so that it is resetted before each
    call to nextStep.

    - Parameters:
     - array: The array containing the elements to sort.
     - swappedItems: The two items to swap or move, if any. Method sets the values and caller does the moving.

    - Returns: Returns true if the array is sorted. Caller should stop sorting (calling nextStep).
    */
   mutating func nextStep(array: [BarValue], swappedItems : inout SwappedItems) -> Bool

   /**
    Implementation of the sorting method without any steps, sorting the data in one go in a loop/loops.
    The caller should verify if the array is actually sorted properly by doing assert(Array.isSorted()) when
    this function returns.

    - Parameters:
      - array: The array to sort.
    */
   mutating func realAlgorithm(array: inout [BarValue])
}
