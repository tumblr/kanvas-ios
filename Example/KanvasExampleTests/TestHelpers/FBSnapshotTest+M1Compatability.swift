//
//  FBSnapshotTest+M1Compatability.swift
//  KanvasExampleTests
//
//  Created by Declan McKenna on 22/04/2022.
//  Copyright © 2022 Tumblr. All rights reserved.
//

import Foundation
import FBSnapshotTestCase
import UIKit

/// Set between 0 and 1
fileprivate let defaultArm64CompatiblePerPixelTolerance: CGFloat = 0.02
/// Set between 0 and 1
fileprivate let defaultArm64CompatibleOverallTolerance: CGFloat = 0.002

extension FBSnapshotTestCase {
    func FBSnapshotArchFriendlyVerifyViewController(_ viewController: UIViewController,
                                                    identifier: String? = nil,
                                                    perPixelTolerance: CGFloat = defaultArm64CompatiblePerPixelTolerance,
                                                    overallTolerance:CGFloat = defaultArm64CompatibleOverallTolerance) {
        FBSnapshotVerifyViewController(viewController,
                                       identifier: identifier,
                                       perPixelTolerance: perPixelTolerance,
                                       overallTolerance: overallTolerance)
    }
    
    func FBSnapshotArchFriendlyVerifyView(_ view: UIView,
                                          identifier: String? = nil,
                                          perPixelTolerance: CGFloat = defaultArm64CompatiblePerPixelTolerance,
                                          overallTolerance:CGFloat = defaultArm64CompatibleOverallTolerance) {
        FBSnapshotVerifyView(view,
                             identifier: identifier,
                             perPixelTolerance: perPixelTolerance,
                             overallTolerance: overallTolerance)
    }
}
