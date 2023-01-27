//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

public protocol KanvasQuickBlogSelectorCoordinating {

    func present(presentingView: UIView, fromPoint: CGPoint)

    func dismiss()

    func touchDidMoveToPoint(_ location: CGPoint)

    func avatarView(frame: CGRect) -> UIView?

}
