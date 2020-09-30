//
//  UIGestureRecognizer+Active.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 30/09/2019.
//

import Foundation

/// Extension that checks if a gesture recognizer is currently active/inactive
extension UIGestureRecognizer {
    
    private static let activeStates: [UIGestureRecognizer.State] = [.began, .changed, .recognized]
    private static let inactiveStates: [UIGestureRecognizer.State] = [.ended, .possible, .failed, .cancelled]
    
    var isActive: Bool {
        return UIGestureRecognizer.activeStates.contains(state)
    }
    
    var isInactive: Bool {
        return UIGestureRecognizer.inactiveStates.contains(state)
    }
}
