//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterCollectionCellConstants {
    static let animationDuration: TimeInterval = 0.1
    static let circleDiameter: CGFloat = 72
    static let circleMaxDiameter: CGFloat = 92
    
    static var minimumHeight: CGFloat {
        return circleMaxDiameter
    }
    
    static var width: CGFloat {
        return circleMaxDiameter
    }
}

/// The cell in FilterCollectionView to display an individual filter
final class FilterCollectionCell: UICollectionViewCell {
    
    static let minimumHeight = FilterCollectionCellConstants.minimumHeight
    static let width = FilterCollectionCellConstants.width
    private var cellHeightConstraint: NSLayoutConstraint?
    private var cellWidthConstraint: NSLayoutConstraint?
    
    private let circleView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    /// Updates the cell to the FilterItem properties
    ///
    /// - Parameter item: The FilterItem to display
    func bindTo(_ item: FilterItem) {
        guard item.type != .passthrough else { return }
        circleView.image = KanvasCameraImages.filterTypes[item.type] ?? nil
        circleView.backgroundColor = KanvasCameraColors.filterTypes[item.type] ?? nil
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        circleView.image = nil
        circleView.backgroundColor = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        contentView.addSubview(circleView)
        circleView.accessibilityIdentifier = "Filter Cell View"
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.contentMode = .scaleAspectFill
        circleView.clipsToBounds = true
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = FilterCollectionCellConstants.circleDiameter / 2
        circleView.layer.borderWidth = 3 * (FilterCollectionCellConstants.circleDiameter/FilterCollectionCellConstants.circleMaxDiameter)
        circleView.layer.borderColor = UIColor.white.cgColor
        
        let heightConstraint = circleView.heightAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleDiameter)
        let widthConstraint = circleView.widthAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleDiameter)
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            heightConstraint,
            widthConstraint
        ])
        
        cellHeightConstraint = heightConstraint
        cellWidthConstraint = widthConstraint
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Animations
    
    /// Changes the circle size
    ///
    /// - Parameter size: the new size for the circle
    private func changeSize(size: CGFloat) {
        cellWidthConstraint?.constant = size
        cellHeightConstraint?.constant = size
        setNeedsLayout()
        layoutIfNeeded()
        circleView.layer.cornerRadius = circleView.frame.height / 2
    }
    
    /// Sets the circle with smallest size (standard size)
    func setStandardSize() {
        changeSize(size: FilterCollectionCellConstants.circleDiameter)
    }
    
    /// Changes the circle size according to a percentage
    ///
    /// - Parameter percent: 0.0 is the smallest size (standard size), while 1.0 is the biggest size
    func setSize(_ percent: CGFloat) {
        let safePercent = (0...1).clamp(percent)
        let size = (FilterCollectionCellConstants.circleMaxDiameter - FilterCollectionCellConstants.circleDiameter) * safePercent + FilterCollectionCellConstants.circleDiameter
        changeSize(size: size)
    }
}
