//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for obtaining images.
protocol DiscreteSliderCollectionCellDelegate: class {

}

/// Constants for DiscreteSliderCollectionCell
private struct Constants {
    static let imageHeight: CGFloat = SpeedView.height
    static let imageWidth: CGFloat = 50
}

/// The cell in DiscreteSliderCollectionView to display
final class DiscreteSliderCollectionCell: UICollectionViewCell {
    
    static let cellHeight = Constants.imageHeight
    static let cellWidth = Constants.imageWidth
    
    weak var delegate: DiscreteSliderCollectionCellDelegate?
    
    private var value: Float = 0
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Public interface
    
    /// Updates the cell with an image
    ///
    /// - Parameter image: The image to display
    func bindTo(_ value: Float) {
        self.value = value
    }
}
