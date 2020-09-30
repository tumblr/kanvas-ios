//
//  Array+Object.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 18/06/2019.
//

import Foundation

extension Array {
    
    /// Returns the object located at the specified index.
    /// If the index is beyond the end of the array, nil is returned.
    ///
    /// - Parameter index: an index within the bounds of the array
    func object(at index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
