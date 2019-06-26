//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct EditorFilterCollectionCellDimensions: FilterCollectionCellDimensions {
    var circleDiameter: CGFloat = 50
    var circleMaxDiameter: CGFloat = 55
    var padding: CGFloat = 6
    var minimumHeight: CGFloat { return circleMaxDiameter }
    var width: CGFloat { return circleMaxDiameter + 2 * padding }
}

/// The cell in FilterCollectionView to display an individual filter
final class EditorFilterCollectionCell: UICollectionViewCell, FilterCollectionCell, FilterCollectionInnerCellDelegate {
    
    private static let dimensions = EditorFilterCollectionCellDimensions()
    static let minimumHeight = dimensions.minimumHeight
    static let width = dimensions.width
    static let cellPadding = dimensions.padding
    
    private let innerCell: FilterCollectionInnerCell
    weak var delegate: FilterCollectionCellDelegate?
    
    override init(frame: CGRect) {
        innerCell = FilterCollectionInnerCell(dimensions: EditorFilterCollectionCell.dimensions)
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        innerCell = FilterCollectionInnerCell(dimensions: EditorFilterCollectionCell.dimensions)
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        innerCell.delegate = self
        innerCell.add(into: self)
    }
    
    func didTap(cell: FilterCollectionInnerCell, recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
    
    func didLongPress(cell: FilterCollectionInnerCell, recognizer: UILongPressGestureRecognizer) {
        
    }
    
    /// Updates the cell to the FilterItem properties
    ///
    /// - Parameter item: The FilterItem to display
    func bindTo(_ item: FilterItem) {
        innerCell.bindTo(item)
    }
    
    /// shows or hides the cell
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        innerCell.show(show)
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        innerCell.prepareForReuse()
    }
    
    // MARK: - Animations
    
    /// Sets the circle with standard size
    func setStandardSize() {
        innerCell.setStandardSize()
    }
    
    /// Changes the circle size according to a percentage.
    ///
    /// - Parameter percent: 0.0 is the standard size, while 1.0 is the biggest size
    func setSize(percent: CGFloat) {
        innerCell.setSize(percent: percent)
    }
}
