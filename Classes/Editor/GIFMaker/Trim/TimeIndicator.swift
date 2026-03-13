//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for TimeIndicator
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let cornerRadius: CGFloat = 18
    static let backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.4)
    static let font: UIFont = KanvasFonts.shared.timeIndicatorFont
    static let fontColor: UIColor = .white
    static let width: CGFloat = 68
    static let height: CGFloat = 36
}

/// Time bubble above the trimmer handles.
final class TimeIndicator: UILabel {
    
    static let height: CGFloat = Constants.height
    static let width: CGFloat = Constants.width
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    /// Sets up the style of the view.
    private func setupView() {
        accessibilityIdentifier = "GIF Maker Time Indicator"
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        backgroundColor = Constants.backgroundColor
        font = Constants.font
        textColor = Constants.fontColor
        textAlignment = .center
    }
    
    // MARK: - Public interface
    
    /// shows or hides the view
    ///
    /// - Parameter show: true to show, false to hide.
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.alpha = show ? 1 : 0
        }
    }
}
