//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for DiscreteSliderCollectionCell
private struct Constants {
    static let imageHeight: CGFloat = SpeedView.height
    static let imageWidth: CGFloat = 50
    static let lineSpace: CGFloat = 2
    static let lineHeight: CGFloat = 4
    static let lineInactiveColor: UIColor = .white
    static let lineActiveColor: UIColor = .tumblrBrightBlue
    static let lineCornerRadius: CGFloat = 2
}

/// The cell inside the discrete slider.
final class DiscreteSliderCollectionCell: UICollectionViewCell {
    
    static let cellHeight = Constants.imageHeight
    static let cellWidth = Constants.imageWidth
    
    private let leftLine: UIView
    private let rightLine: UIView
    private var value: Float = 0
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        leftLine = UIView()
        rightLine = UIView()
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setupLeftLine()
        setupRightLine()
    }
    
    private func setupLeftLine() {
        leftLine.accessibilityIdentifier = "Discrete Slider Collection Cell Left Line"
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.layer.cornerRadius = Constants.lineCornerRadius
        leftLine.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        leftLine.backgroundColor = Constants.lineInactiveColor
        addSubview(leftLine)
        
        NSLayoutConstraint.activate([
            leftLine.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            leftLine.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: -Constants.lineSpace),
            leftLine.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
        ])
    }
    
    private func setupRightLine() {
        rightLine.accessibilityIdentifier = "Discrete Slider Collection Cell Right Line"
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.layer.cornerRadius = Constants.lineCornerRadius
        rightLine.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        rightLine.backgroundColor = Constants.lineInactiveColor
        addSubview(rightLine)
        
        NSLayoutConstraint.activate([
            rightLine.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: Constants.lineSpace),
            rightLine.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            rightLine.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
        ])
    }
    
    // MARK: - Public interface
    
    /// Binds the cell to a specific value.
    ///
    /// - Parameter value: the new value.
    func bindTo(_ value: Float) {
        self.value = value
    }
    
    func setPosition(isStart: Bool, isEnd: Bool) {
        leftLine.alpha = isStart ? 0 : 1
        rightLine.alpha = isEnd ? 0 : 1
    }
    
    func setProgress(leftActive: Bool, rightActive: Bool) {
        leftLine.backgroundColor = leftActive ? Constants.lineActiveColor : Constants.lineInactiveColor
        rightLine.backgroundColor = rightActive ? Constants.lineActiveColor : Constants.lineInactiveColor
    }
}
