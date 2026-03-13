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
    static let circleSize: CGFloat = 12
    static let lineSpace: CGFloat = 2
    static let lineHeight: CGFloat = 4
    static let lineCornerRadius: CGFloat = 2
    static let inactiveColor: UIColor = .white
    static let activeColor: UIColor = KanvasColors.shared.sliderActiveColor
}

/// The cell inside the discrete slider.
final class DiscreteSliderCollectionCell: UICollectionViewCell {
    
    static let cellHeight = Constants.imageHeight
    static let cellWidth = Constants.imageWidth
    
    private let leftLine: UIView
    private let rightLine: UIView
    private let circle: UIImageView
    private var value: Float = 0
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        leftLine = UIView()
        rightLine = UIView()
        circle = UIImageView()
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
        setupCircle()
    }
    
    private func setupLeftLine() {
        leftLine.accessibilityIdentifier = "Discrete Slider Collection Cell Left Line"
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.layer.cornerRadius = Constants.lineCornerRadius
        leftLine.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        leftLine.backgroundColor = Constants.inactiveColor
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
        rightLine.backgroundColor = Constants.inactiveColor
        addSubview(rightLine)
        
        NSLayoutConstraint.activate([
            rightLine.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: Constants.lineSpace),
            rightLine.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            rightLine.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
        ])
    }
    
    private func setupCircle() {
        circle.accessibilityIdentifier = "Discrete Slider Collection Cell Circle"
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.image = KanvasImages.circleImage?.withRenderingMode(.alwaysTemplate)
        circle.tintColor = Constants.activeColor
        addSubview(circle)
        
        NSLayoutConstraint.activate([
            circle.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            circle.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circle.heightAnchor.constraint(equalToConstant: Constants.circleSize),
        ])
    }
    
    // MARK: - Public interface
    
    /// Binds the cell to a specific value.
    ///
    /// - Parameter value: the new value.
    func bindTo(_ value: Float) {
        self.value = value
    }
    
    /// Sets the style of the cell according to its position in the collection.
    ///
    /// - Parameters:
    ///  - isCenter: Whether the cell is the center of the range.
    ///  - isFirst: Whether the cell is the first of the collection.
    ///  - isLast: Whether the cell is the last of the collection.
    func setStyle(isCenter: Bool, isFirst: Bool, isLast: Bool) {
        circle.alpha = isCenter ? 1 : 0
        leftLine.alpha = isFirst ? 0 : 1
        rightLine.alpha = isLast ? 0 : 1
    }
    
    /// Changes the colors of the lines in the cell.
    ///
    /// - Parameters:
    ///  - leftLineActive: Whether the left line should be coloured or not.
    ///  - rightLineActive: Whether the right line should be coloured or not.
    func setProgress(leftLineActive: Bool, rightLineActive: Bool) {
        leftLine.backgroundColor = leftLineActive ? Constants.activeColor : Constants.inactiveColor
        rightLine.backgroundColor = rightLineActive ? Constants.activeColor : Constants.inactiveColor
    }
}
