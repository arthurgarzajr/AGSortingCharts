//
//  NativeSwiftSort.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 7.6.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation

/**
 Native Swift sort in Foundation library is Tim sort.

 This class here uses it just in the end of the demo, sorting a large array without animation.

 One could take the source code for the library implementation and restructure it so that it can be
 executed step by step as the other sort methods implemented here. Then this could also be animated. This is left as an exercise to the reader.
 */
struct NativeSwiftSort: SortMethod {
      
   init(arraySize: Int) {
      size = arraySize
   }
   
   let size: Int
   
   var name: String {
      "Native Swift Timsort"
   }
   
   var description: String {
      """
      The sorting method implemented in Swift, Timsort.

      Timsort is a hybrid stable sorting algorithm, derived from merge sort and insertion sort, designed to perform well on many kinds of real-world data.

      It was implemented by Tim Peters in 2002 for use in the Python programming language. The algorithm finds subsequences of the data that are already ordered (runs) and uses them to sort the remainder more efficiently.

      This method is not animated in the app. This would require reimplementing the method so that it can be executed in steps.
      """
   }

   var webLinks: [(String, String)] {
      [("Wikipedia on TimSort", "https://en.wikipedia.org/wiki/Timsort")]
   }

   /**
    Step by step execution not implemented.
    */
   mutating func restart() {
      // Nada
   }
   
   /**
    Step by step execution not implemented.
    */
   mutating func nextStep(array: [BarValue], swappedItems: inout SwappedItems) -> Bool {
      return true
   }
   /**
    Just call the usual sort implementation of the library array struct.
    */
   mutating func realAlgorithm(array: inout [BarValue]) {
      array.sort()
   }

}
