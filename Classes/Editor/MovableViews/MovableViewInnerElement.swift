//
//  MovableViewInnerElement.swift
//  FBSnapshotTestCase
//
//  Created by Gabriel Mazzei on 06/05/2020.
//

import Foundation

/// Protocol for the view inside MovableView
protocol MovableViewInnerElement: UIView {
    
    /// Checks whether the hit is done inside the shape of the view
    ///
    /// - Parameter point: location where the view was touched
    /// - Returns: true if the touch was inside, false if not
    func hitInsideShape(point: CGPoint) -> Bool
}
