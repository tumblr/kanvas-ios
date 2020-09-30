//
// Created by Tony Cheng on 4/17/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

import UIKit

extension CGRect {

    /// convenience method for setting and getting the center
    var center: CGPoint {
        get {
            return CGPoint(x: midX,
                           y: midY)
        }
        set {
            origin.x = newValue.x - (width / 2)
            origin.y = newValue.y - (height / 2)
        }
    }

}
