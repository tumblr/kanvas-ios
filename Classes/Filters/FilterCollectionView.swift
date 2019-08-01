//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class FilterCollectionView: IgnoreTouchesView {
    
    let collectionView: HorizontalCollectionView
    
    init(cellWidth: CGFloat, cellHeight: CGFloat, ignoreTouches: Bool = false) {
        let layout = HorizontalCollectionLayout(cellWidth: cellWidth, minimumHeight: cellHeight)
        collectionView = HorizontalCollectionView(frame: .zero, collectionViewLayout: layout, ignoreTouches: ignoreTouches)
        collectionView.accessibilityIdentifier = "Filter Collection"
        
        super.init(frame: .zero)
        
        clipsToBounds = false
        setUpViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        collectionView.add(into: self)
        collectionView.clipsToBounds = false
    }
    
    // MARK: - Public interface
    
    /// Makes its cells shrink
    func shrink() {
        let cells = getVisibleCells()
        cells.forEach { $0.shrink() }
    }
    
    /// Makes its cells pop
    func pop() {
        let cells = getVisibleCells()
        cells.forEach { $0.pop() }
    }
    
    /// Obtains the visible cells from the collection view
    private func getVisibleCells() -> [FilterCollectionCell] {
        guard let cells = collectionView.visibleCells as? [FilterCollectionCell] else { return [] }
        return cells
    }
}
