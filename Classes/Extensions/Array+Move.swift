//  Array+Move.swift
//  KanvasEditor
//
//  Created by Daniela Riesgo on 21/09/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

import Foundation

extension Array {
    
    /// Moves an element inside the array.
    ///
    /// - parameter originIndex: Index at where the element is found before this function
    /// - parameter destinationIndex: Index at where the element is found afetr this function
    /// - warning: Indexes should be valid to use this function.
    mutating func move(from originIndex: Int, to destinationIndex: Int) {
        let element = remove(at: originIndex)
        insert(element, at: destinationIndex)
    }
    
}
