//
//  IndexPath+Order.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 21/06/2019.
//

import Foundation
import UIKit

/// Obtains the next and previous index paths within the current section
extension IndexPath {
    
    func previous() -> IndexPath {
        return IndexPath(item: item - 1, section: section)
    }
    
    func next() -> IndexPath {
        return IndexPath(item: item + 1, section: section)
    }
}
