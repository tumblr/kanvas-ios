//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FilterSmallCollectionViewPrivateConstants {
    static var bufferSize: CGFloat = 10
    static var height: CGFloat = FilterSmallCollectionCellConstants.minimumHeight + FilterSmallCollectionViewPrivateConstants.bufferSize
}

struct FilterSmallCollectionViewConstants {
    static let height = FilterSmallCollectionViewPrivateConstants.height
}

/// Collection view for the FilterSmallCollectionController
final class FilterSmallCollectionView: FilterCollectionView {
    
    override internal var height: CGFloat {
        return FilterSmallCollectionViewConstants.height
    }
    
    override internal var cellWidth: CGFloat {
        return FilterSmallCollectionCellConstants.width
    }
    
    override internal var cellMinimumHeight: CGFloat {
        return FilterSmallCollectionCellConstants.minimumHeight
    }
    
    override internal func create(layout: UICollectionViewFlowLayout) -> UICollectionView {
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
}
