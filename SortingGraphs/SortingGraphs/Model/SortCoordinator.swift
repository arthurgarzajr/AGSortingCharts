//
//  SortCoordinator.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 24.2.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation
import UIKit
/**
 Records the timing of sort methods executed in a tight loop. The results are shown
 in the UI after animating the results.
 */
struct TimingResult: Hashable, Comparable {
   /// The name of the sorting algorithm.
   let methodName: String
   /// The amount of seconds the algorithm took to sort the array.
   let timing: Double
   /// Timing as string
   var timingAsString: String {
      String(format: "%.5f", timing) + "s"
   }

   static func < (lhs: TimingResult, rhs: TimingResult) -> Bool {
      lhs.timing < rhs.timing
   }
}

/**
 SortCoordinator coordinates, as the name implies, sorting of arrays using different sorting methods.
 It is an `ObservableObject`, being observerd by a `View` that holds the coordinator as an `@ObservedObject`
 to show the state of the sorting in the UI.
 
 SortCoordinator:
  - holds the array to be sorted, giving it to each sort method by calling SortMethod.nextStep().
  - times the sorting process using a `Timer`
  - publishes the array to the Views so that when the array is updated, view is redrawn.
  - collects the timing results using `SortMethod.realAlgorithm(...)`, to show to the user the time the algoritms
 take to sort the array without any animations.
 
 SortCoordinator is to be used so that the client (a SwiftUI View):
 
 1. creates the SortCoordinator object
 1. calls `execute()` when user is tapping some element in the UI
 1. reacts to the events in the SortCoordinator when the array within changes, by updating the UI
 1. calls `stop()` if user wants to stop the sorting by tapping in the View.
 
 For details, see the properties and methods in this class as well as the `SortMethod` protocol which all the sorting methods implement.
 
 */

class BarValue: Identifiable, Comparable {
    var value: Int
    var index: Int
    var color: UIColor
    
    var id: Int {
        return index
    }
    
    init(value: Int, index: Int, color: UIColor = UIColor.gray) {
        self.value = value
        self.index = index
        self.color = color
    }
    
    static func < (lhs: BarValue, rhs: BarValue) -> Bool {
        lhs.value < rhs.value
    }
    
    static func == (lhs: BarValue, rhs: BarValue) -> Bool {
        lhs.value == rhs.value
    }
}

class SortCoordinator: ObservableObject {

   /** The data to be sorted is generated to `originalArray` first, then copied to
    the array member. This is to make sure that all sorting methods start from exactly the
    same data. This produces comparable performance metrics, since how the data is organized
    in the array influences the sorting methods' performance.
   */
   var originalArray: [BarValue]!

   /// The array that is actually used in the sorting. This is also displayed in the UI, the reason why it is @Published.
   @Published var array: [BarValue]!
   /// The (current) sorting methods used. Value changes when execution moves from one method to another.
   @Published var description = String("Start sorting")
   /// This table will include the real time performance metrics of the sorting methods after the measuring phase.
   @Published var performanceTable = [TimingResult]()

   @Published var methodActingOnIndex1: Int = -1
   @Published var methodActingOnIndex2: Int = -1
   @Published var usePositiveNumbers: Bool = true
   
   private let waitingForNextSortMethod = 1.0
    private let waitingForNextSortStep = 0.0000001
//    private let waitingForNextSortStep = 0.1

   @Published var countOfNumbers = 50

   /// The currently executing sorthing method reference.
   private var currentMethod: SortMethod?
   /// A timer is used to control the execution of the sorting.
   private var timer: Timer?
   /// Holds the current interval used in the timing.
   private var timerInterval = 1.5
   /// Is true, if sorting is ongoing, otherwise false.
   private var executing = false

   /// Which of the sorting methods in the sortingMethod array is currently executed.
   private var currentMethodIndex = 0
   /// All the supported sorting methods are placed in the array before starting the execution.
   private var sortingMethods = [SortMethod]()

   /// The different states of the execution of the sort coordinator.
   enum State {
      /// Starting phase, where preparation for the execution is done
      case atStart
      /// The animating phase, where sorting methods are executed one by one, step by step, by calling the nextStep() method.
      case animating
      /// After animation, all sorting methods are executed using the realAlgorithm() method to time the "actual" perfomance of the methods.
      case measuring
      /// End phase, where the exection is finished.
      case atEnd
   }
   /// The state variable, holding the execution state.
   private(set) var state = State.atStart

   init() {
      prepare(count: countOfNumbers)
   }
   /**
    Gets the count of supported sorting methods
    - returns: The count of implemented sorting methods
    */
   func getCountOfSupportedMethods() -> Int {
      return sortingMethods.count
   }

   /**
    Gets the name of the currently executing sorting method.
    - returns: The name of the currently executing sorting method.
    */
   func getName() -> String {
      return currentMethod!.name
   }

   func prepareOriginalArray(with count: Int) {
      countOfNumbers = count
      originalArray = [BarValue]()
          
      for i in 1..<count {
          let barValue = BarValue(value: i, index: i)
          originalArray.append(barValue)
      }
       
      originalArray.shuffle()
      array = originalArray
   }
   /**
    Prepares the coordinator for sorting.
    - parameter count: The number of elements to hold in the array to be sorted.
    */
   func prepare(count: Int) {
      countOfNumbers = count
      prepareOriginalArray(with: countOfNumbers)
      sortingMethods.removeAll()
      sortingMethods.append(BubbleSort(arraySize: array.count))
      sortingMethods.append(ShellSort(arraySize: array.count))
      sortingMethods.append(HeapSort(arraySize: array.count))
      currentMethodIndex = 0
      currentMethod = sortingMethods[currentMethodIndex]
      description = "\(currentMethod!.name)"
   }

   /**
    Gets a description for the sorting method by method name
    - parameter methodName: The name of the sorting method.
    - returns: The description for the sorting method.
    */
   func getDescription(for methodName: String) -> String {
      for method in sortingMethods where method.name == methodName {
         return method.description
      }
      return ""
   }

   /**
    Gets the sorting method by the method's name.
    - parameter methodName: The name of the sorting method.
    - returns: The sorting method protocol referring to the method struct, nil if not found.
    */
   func getMethod(for methodName: String) -> SortMethod? {
      for method in sortingMethods where method.name == methodName {
         return method
      }
      return nil
   }

   /**
    Executes the different sorting methods, using a repeating timer within a closure.
    
    See also `nextStep()` and `nextMethod()` as well as `stop()`, which all contribute to the state manamement of
    the coordinator.
    
    See the State enum values, coordinating the execution of the sorting in different phases.
    */
   func execute() {
      self.timerInterval = self.waitingForNextSortStep
      timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [self] _ in
         switch state {
         case .atStart:
            if debug { print("Engine atStart") }
            state = .animating
            prepareOriginalArray(with: countOfNumbers)
            currentMethod!.restart()
            description = "\(self.currentMethod!.name)"
            executing = true

         case .animating:
            // If nextStep returns true, array is sorted and it is time to switch to the next supported method, if any.
            if nextStep() {
               nextMethod()
            }

         case .measuring:
            if debug { print("Engine measuring") }
            // Measure the time performance of each of the methods, without animation and loops.
            // 1. Take timestamp
            let now = Date()
            // 2. Do sorting with real algo
            currentMethod?.realAlgorithm(array: &array)
            // 3. Take timestamp
            // 4. Calculate duration
            let duration = Date().timeIntervalSince(now)
            // 5. Add to performanceTable
            let result = TimingResult(methodName: currentMethod!.name, timing: duration)
            performanceTable.append(result)
            performanceTable.sort()
            if debug { print(performanceTable) }
            nextMethod()

         case .atEnd:
            if debug { print("Engine atEnd") }
            state = .atStart
         }
      }

   }

   /**
    Is the coordinator executing or not
    - returns: True if the coordinator is executing the sorting methods.
    */
   func isExecuting() -> Bool {
      return executing
   }

   /**
    Stops the execution of the sorthing phase, advances to the next phase, if any.
    */
   func stop() {
      if let clock = timer {
         clock.invalidate()
      }
      if debug { print("in stop") }
      currentMethodIndex = 0
      currentMethod = self.sortingMethods[self.currentMethodIndex]
      description = "Finished"

      switch state {
      case .atStart:
         if debug { print("in stop, state is atStart") }

      case .animating:
          break

      case .measuring:
          break

      default:
         state = .atStart
      }
   }

   /**
    Executes the next step of any sorting method when animating the methods.
    - returns: Returns true if the sort method finished sorting and the array is now sorted.
    */
   private func nextStep() -> Bool {
      var returnValue = false
      var swappedItems = SwappedItems()
      returnValue = currentMethod!.nextStep(array: array, swappedItems: &swappedItems)
      self.array.handleSortOperation(operation: swappedItems)
      if swappedItems.currentIndex1 >= 0 {
         methodActingOnIndex1 = swappedItems.currentIndex1
      }
      if swappedItems.currentIndex2 >= 0 {
         methodActingOnIndex2 = swappedItems.currentIndex2
      }
       // Fix the indices
       for (index, value) in array.enumerated() {
            value.index = index
       }
      return returnValue
   }

   func nextMethod() {
      if let clock = timer {
         clock.invalidate()
      }
      if debug { print("in nextMethod") }
      currentMethodIndex += 1
      if self.currentMethodIndex < self.sortingMethods.count {
         currentMethod = sortingMethods[self.currentMethodIndex]
         currentMethod?.restart()
        let method = currentMethod?.name ?? "No method selected"
        description = "\(method)"
         timer = Timer.scheduledTimer(withTimeInterval: waitingForNextSortMethod, repeats: false) { [self] _ in
            array = originalArray
            description = "\(self.currentMethod?.name ?? "")"
            execute()
         }
      } else {
         stop()
      }
   }

}
