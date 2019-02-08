//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import TumblrTheme
import UIKit

private struct FilterCollectionCellConstants {
    static let cellPadding: CGFloat = 2
    static let circleHeight: CGFloat = 80
    static let circleWidth: CGFloat = 56
    
    static var minimumHeight: CGFloat {
        return circleHeight
    }
    
    static var width: CGFloat {
        return circleWidth + 2 * cellPadding
    }
}

final class FilterCollectionCell: UICollectionViewCell {
    
    static let minimumHeight = FilterCollectionCellConstants.minimumHeight
    static let width = FilterCollectionCellConstants.width
    
    private let circleView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = KanvasCameraImages.closeImage
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
}


// MARK: - Layout
extension FilterCollectionCell {
    
    private func setUpView() {
        circleView.accessibilityIdentifier = "Filter Cell View"
        circleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.safeLayoutGuide.centerXAnchor),
            circleView.leadingAnchor.constraint(equalTo: contentView.safeLayoutGuide.leadingAnchor,
                                                constant: FilterCollectionCellConstants.cellPadding),
            circleView.trailingAnchor.constraint(equalTo: contentView.safeLayoutGuide.trailingAnchor,
                                                 constant: -FilterCollectionCellConstants.cellPadding),
            circleView.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeLayoutGuide.topAnchor),
            circleView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeLayoutGuide.bottomAnchor),
            circleView.heightAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleHeight),
            circleView.widthAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleWidth)
        ])
    }
}
