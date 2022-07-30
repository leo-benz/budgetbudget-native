    //
    //  Hierarchy.swift
    //  BudgetBudget
    //
    //  Created by Leo Benz on 18.07.22.
    //

import Foundation

    /// Protocol representing an element of a hierarchical structure
protocol HierarchyElement<Element>: Decodable, AnyObject {
    associatedtype Element

        /// The indentation level of this element
    var indentation: Int { get }

        /// The children of this element, `nil` if there are no children
    var children: [Element]? { get }

        /// Appending the given child to the list of children
        ///
        /// Parameter:
        ///  - child: The child to append
    func append(child: Element)
}
    /// A data structure of recursive hiearachy elements of the same type with multiple root elements
struct Hierarchy<T: HierarchyElement<T>>: Decodable {
    let rootElements: [T]
    var flatElements: [T] = []

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var currentIndent = -1
        var rootElements: [T] = []
        var tempElements: [T] = []
        
        while !container.isAtEnd {
            let element = try container.decode(T.self)
            flatElements.append(element)
            if element.indentation == 0 {
                rootElements.append(element)
            }
            if element.indentation > currentIndent {
                tempElements.last?.append(child: element)
                tempElements.append(element)
                currentIndent += 1
            } else {
                if element.indentation < currentIndent {
                    let change = abs(element.indentation - currentIndent)
                    tempElements.removeLast(change)
                    currentIndent -= change
                }
                tempElements.removeLast()
                tempElements.last?.append(child: element)
                tempElements.append(element)
            }
        }
        
        self.rootElements = rootElements
    }
}
