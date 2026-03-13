//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol FilterCollectionCellDelegate: AnyObject {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: FilterCollectionCell, recognizer: UITapGestureRecognizer)
    
    /// Callback method when long pressing a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was long-pressed
    ///   - recognizer: the long-press gesture recognizer
    func didLongPress(cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer)
}

protocol FilterCollectionCell: UICollectionViewCell {
    func setStandardSize()
    func setSize(percent: CGFloat)
    func show(_ show: Bool)
    func bindTo(_ item: FilterItem)
    func setSelected(_ selected: Bool)
    func press()
    func shrink()
    func pop()
}
