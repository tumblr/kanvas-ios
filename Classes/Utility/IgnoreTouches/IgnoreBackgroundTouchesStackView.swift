//
//  IgnoreTouchesStackView.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 17/01/2020.
//

import Foundation
import UIKit

/// StackView that transmits touches in the following way:
/// * if the touch was in a subview, the subview responds;
/// * if the touch was in an "empty" space, the touch moves on
/// in the hierarchy of views to some other (parent or brother, or brother's subview)
/// that may respond to that touch.
class IgnoreBackgroundTouchesStackView: UIStackView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }

}
