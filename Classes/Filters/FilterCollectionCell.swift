//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterCollectionCellConstants {
    static let animationDuration: TimeInterval = 0.1
    static let cellPadding: CGFloat = 12
    static let circleDiameter: CGFloat = 72
    static let circleMaxDiameter: CGFloat = 92
    
    static var minimumHeight: CGFloat {
        return circleMaxDiameter
    }
    
    static var width: CGFloat {
        return circleMaxDiameter + 2 * cellPadding
    }
}

/// The cell in FilterCollectionView to display an individual filter
final class FilterCollectionCell: UICollectionViewCell {
    
    static let minimumHeight = FilterCollectionCellConstants.minimumHeight
    static let width = FilterCollectionCellConstants.width
    private var cellHeightConstraint: NSLayoutConstraint?
    private var cellWidthConstraint: NSLayoutConstraint?
    
    private let circleView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    /// Updates the cell to the Filter properties
    ///
    /// - Parameter item: The Filter to display
    func bindTo(_ item: Filter) {
        circleView.tintColor = item.representativeColor
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        circleView.tintColor = .none
    }
    
    /// Changes the circle size depending on whether the cell is selected
    ///
    /// - Parameter selected: true to fill the shutter button, false to make the circle standard size
    func setSelected(_ selected: Bool) {
        if selected {
            changeSize(size: FilterCollectionCellConstants.circleMaxDiameter)
        }
        else {
            changeSize(size: FilterCollectionCellConstants.circleDiameter)
        }
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        contentView.addSubview(circleView)
        circleView.accessibilityIdentifier = "Filter Cell View"
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = circleView.heightAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleDiameter)
        let widthConstraint = circleView.widthAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleDiameter)
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            circleView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: FilterCollectionCellConstants.cellPadding),
            circleView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -FilterCollectionCellConstants.cellPadding),
            circleView.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeAreaLayoutGuide.topAnchor),
            circleView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            heightConstraint,
            widthConstraint
        ])
        
        cellHeightConstraint = heightConstraint
        cellWidthConstraint = widthConstraint
    }
    
    // MARK: - Animations
    
    /// Changes the circle size with an animation
    ///
    /// - Parameter size: the new size for the circle
    private func changeSize(size: CGFloat) {
        UIView.animate(withDuration: FilterCollectionCellConstants.animationDuration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cellWidthConstraint?.constant = size
            strongSelf.cellHeightConstraint?.constant = size
            strongSelf.setNeedsLayout()
            strongSelf.layoutIfNeeded()
        }
    }
}
