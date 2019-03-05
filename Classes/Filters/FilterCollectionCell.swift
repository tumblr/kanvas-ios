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
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = FilterCollectionCellConstants.circleDiameter / 2
        imageView.layer.borderWidth = 3 * (FilterCollectionCellConstants.circleDiameter/FilterCollectionCellConstants.circleMaxDiameter)
        imageView.layer.borderColor = UIColor.white.cgColor
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
}
