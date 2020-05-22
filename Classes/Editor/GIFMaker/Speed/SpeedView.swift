//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for SpeedView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let height: CGFloat = 71
}

/// A UIView for the speed controls view
final class SpeedView: UIView {
    
    static let height: CGFloat = Constants.height
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        
    }
        
    // MARK: - Gesture recognizers
    
    
    // MARK: - Public interface
    
    /// shows or hides the view
    ///
    /// - Parameters
    ///  - show: true to show, false to hide.
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.alpha = show ? 1 : 0
        }
    }
}
