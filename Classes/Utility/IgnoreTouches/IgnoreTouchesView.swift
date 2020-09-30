//
//  IgnoreTouchesView.swift
//  KanvasEditor
//
//  Created by Daniela Riesgo on 06/07/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

import Foundation
import UIKit

/// View that transmit touches in the following way:
/// * if the touch was in a subview, the subview responds;
/// * if the touch was in an "empty" space, the touch moves on
/// in the hierarchy of views to some other (parent or brother, or brother's subview)
/// that may respond to that touch.
/// This class is meant to be subclassed.
class IgnoreTouchesView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
    
}
