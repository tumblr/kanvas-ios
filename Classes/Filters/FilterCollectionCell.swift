//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterCollectionCellConstants {
    static let cellPadding: CGFloat = 12
    static let circleHeight: CGFloat = 80
    static let circleWidth: CGFloat = 80
    
    static var minimumHeight: CGFloat {
        return circleHeight
    }
    
    static var width: CGFloat {
        return circleWidth + 2 * cellPadding
    }
}

/// The cell in FilterCollectionView to display an individual filter
final class FilterCollectionCell: UICollectionViewCell {
    
    static let minimumHeight = FilterCollectionCellConstants.minimumHeight
    static let width = FilterCollectionCellConstants.width
    
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
}


// MARK: - Layout
extension FilterCollectionCell {
    
    private func setUpView() {
        contentView.addSubview(circleView)
        circleView.accessibilityIdentifier = "Filter Cell View"
        circleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            circleView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                                                constant: FilterCollectionCellConstants.cellPadding),
            circleView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -FilterCollectionCellConstants.cellPadding),
            circleView.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeAreaLayoutGuide.topAnchor),
            circleView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            circleView.heightAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleHeight),
            circleView.widthAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleWidth)
        ])
    }
}
