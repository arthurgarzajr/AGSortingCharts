//
//  Stack.swift
//  SortSpectacle
//
//  Created by Antti Juustila on 26.2.2020.
//  Copyright © 2020 Antti Juustila. All rights reserved.
//

import Foundation

/**
 An interface for stack data structure needed by e.g. LampSort.
 
 Based on an example from Stackoverflow.
 
 See https://stackoverflow.com/questions/31462272/stack-implementation-in-swift
 */
protocol Stackable {
   /// Type of elements to put into a stack.
   associatedtype Element
   /// To peek if stack has an element to pop.
   func peek() -> Element?
   /// Push new element on top of the stack.
   mutating func push(_ element: Element)
   /// Pop an element from the top of the stack.
   @discardableResult mutating func pop() -> Element?
}

/// An extension of Stackable to check if it is empty.
extension Stackable {
   var isEmpty: Bool { peek() == nil }
}

/// A Stack data structure, implementing Stackable protocol.
struct Stack<Element>: Stackable where Element: Equatable {
   /// Uses an array to store the elements of the stack.
   private var storage = [Element]()
   /// Peek to check if there are elements in the underlying data structure.
   func peek() -> Element? { storage.first }
   /// Pushes an element into the data structure.
   mutating func push(_ element: Element) { storage.append(element)  }
   /// Gets the topmost element from the storage.
   mutating func pop() -> Element? { storage.popLast() }
}

/// Stacks are equal if their arrays are equal.
extension Stack: Equatable {
   static func == (lhs: Stack<Element>, rhs: Stack<Element>) -> Bool { lhs.storage == rhs.storage }
}

/// Helps to print out the stack contents.
extension Stack: CustomStringConvertible {
   var description: String { "\(storage)" }
}

/// Helper to initialize the stack from an array literal.
extension Stack: ExpressibleByArrayLiteral {
   init(arrayLiteral elements: Self.Element...) { storage = elements }
}
