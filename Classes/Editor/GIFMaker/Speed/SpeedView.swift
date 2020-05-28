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
    static let height: CGFloat = 36
    static let labelWidth: CGFloat = 48
    static let labelBackgroundColor = UIColor.black.withAlphaComponent(0.65)
    static let labelCornerRadius: CGFloat = 8
    static let labelFont: UIFont = .guavaMedium()
    static let labelFontColor: UIColor = .white
}

/// A UIView for the speed controls view
final class SpeedView: UIView {
    
    static let height: CGFloat = Constants.height
    
    private let speedLabel: UILabel
    let slider: UIView
    
    // MARK: - Initializers
    
    init() {
        slider = UIView()
        speedLabel = UILabel()
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setupSliderContainer()
        setupSpeedLabel()
    }
    
    /// Sets up the container for the speed slider
    private func setupSliderContainer() {
        slider.accessibilityIdentifier = "Speed Menu Slider Container"
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.labelWidth),
            slider.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            slider.heightAnchor.constraint(equalToConstant: SpeedView.height),
        ])
    }
    
    private func setupSpeedLabel() {
        speedLabel.accessibilityIdentifier = "Speed Menu Slider Container"
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.backgroundColor = Constants.labelBackgroundColor
        speedLabel.layer.cornerRadius = Constants.labelCornerRadius
        speedLabel.layer.masksToBounds = true
        speedLabel.font = Constants.labelFont
        speedLabel.textColor = Constants.labelFontColor
        speedLabel.textAlignment = .center
        addSubview(speedLabel)
        
        NSLayoutConstraint.activate([
            speedLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            speedLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            speedLabel.widthAnchor.constraint(equalToConstant: Constants.labelWidth),
            speedLabel.heightAnchor.constraint(equalToConstant: SpeedView.height),
        ])
    }
    
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
    
    func setLabelText(_ text: String) {
        speedLabel.text = text
    }
}
