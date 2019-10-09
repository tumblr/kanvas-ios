//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct EditorFilterCollectionCellDimensions: FilterCollectionCellDimensions {
    let circleDiameter: CGFloat = 50
    let circleMaxDiameter: CGFloat = 55
    let padding: CGFloat = 6
    var minimumHeight: CGFloat { return circleMaxDiameter }
    var width: CGFloat { return circleMaxDiameter + 2 * padding }
}

/// The cell in FilterCollectionView to display an individual filter
final class EditorFilterCollectionCell: UICollectionViewCell, UIGestureRecognizerDelegate, FilterCollectionCell, FilterCollectionInnerCellDelegate {
    
    private static let dimensions = EditorFilterCollectionCellDimensions()
    static let minimumHeight = dimensions.minimumHeight
    static let width = dimensions.width
    static let cellPadding = dimensions.padding
    
    private let innerCell: FilterCollectionInnerCell
    weak var delegate: FilterCollectionCellDelegate?
    
    private let longPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0.0
        return recognizer
    }()
    
    override init(frame: CGRect) {
        innerCell = FilterCollectionInnerCell(dimensions: EditorFilterCollectionCell.dimensions,
                                              tapRecognizer: nil,
                                              longPressRecognizer: longPressRecognizer)
        super.init(frame: frame)
        setUpView()
        setUpRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        innerCell = FilterCollectionInnerCell(dimensions: EditorFilterCollectionCell.dimensions,
                                              tapRecognizer: nil,
                                              longPressRecognizer: longPressRecognizer)
        super.init(coder: aDecoder)
        setUpView()
        setUpRecognizers()
    }
    
    private func setUpView() {
        innerCell.delegate = self
        innerCell.add(into: self)
    }
    
    private func setUpRecognizers() {
        longPressRecognizer.delegate = self
    }
    
    // MARK: - FilterCollectionCell
    
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
    
    /// Selects/deselects the cell
    ///
    /// - Parameter selected: whether the cell is selected or not
    func setSelected(_ selected: Bool) {
        innerCell.setSelected(selected)
    }
    
    /// Shrinks the cell until it is hidden
    func shrink() {
        innerCell.shrink()
    }
    
    /// Increases the size of the cell until it reaches its regular size
    func pop() {
        innerCell.pop()
    }
    
    /// Animates the cell for press gesture
    func press() {
        innerCell.press()
    }
    
    // MARK: - FilterCollectionInnerCellDelegate
    
    func didTap(cell: FilterCollectionInnerCell, recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
    
    func didLongPress(cell: FilterCollectionInnerCell, recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPress(cell: self, recognizer: recognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
