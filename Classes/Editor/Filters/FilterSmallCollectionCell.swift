//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol FilterSmallCollectionCellDelegate {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: FilterSmallCollectionCell, recognizer: UITapGestureRecognizer)
    
    /// Callback method when long pressing a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was long-pressed
    ///   - recognizer: the long-press gesture recognizer
    func didLongPress(cell: FilterSmallCollectionCell, recognizer: UILongPressGestureRecognizer)
}

private struct FilterSmallCollectionCellPrivateConstants {
    static let animationDuration: TimeInterval = 0.2
    static let circleDiameter: CGFloat = 50
    static let circleMaxDiameter: CGFloat = 55
    static let padding: CGFloat = 6
    
    static var minimumHeight: CGFloat = circleMaxDiameter
    static var width: CGFloat = circleMaxDiameter + 2 * padding
}

struct FilterSmallCollectionCellConstants {
    static let minimumHeight: CGFloat = FilterSmallCollectionCellPrivateConstants.minimumHeight
    static let width: CGFloat = FilterSmallCollectionCellPrivateConstants.width
    static let cellPadding = FilterSmallCollectionCellPrivateConstants.padding
}

/// The cell in FilterSmallCollectionView to display an individual filter
final class FilterSmallCollectionCell: FilterCollectionCell {
    
    override var circleDiameter: CGFloat {
        return FilterSmallCollectionCellPrivateConstants.circleDiameter
    }
    
    override var circleMaxDiameter: CGFloat {
        return FilterSmallCollectionCellPrivateConstants.circleMaxDiameter
    }
    
    override var animationDuration: TimeInterval {
        return FilterSmallCollectionCellPrivateConstants.animationDuration
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        circleDiameter =
//        circleMaxDiameter =
//        animationDuration = FilterSmallCollectionCellPrivateConstants.animationDuration
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        circleDiameter = FilterSmallCollectionCellPrivateConstants.circleDiameter
//        circleMaxDiameter = FilterSmallCollectionCellPrivateConstants.circleMaxDiameter
//        animationDuration = FilterSmallCollectionCellPrivateConstants.animationDuration
//    }
}
