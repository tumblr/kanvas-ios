//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class HorizontalCollectionLayout: UICollectionViewFlowLayout {
    
    init(cellWidth: CGFloat, minimumHeight: CGFloat) {
        super.init()
        configure(cellWidth: cellWidth, minimumHeight: minimumHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(cellWidth: CGFloat, minimumHeight: CGFloat) {
        scrollDirection = .horizontal
        itemSize = UICollectionViewFlowLayout.automaticSize
        estimatedItemSize = CGSize(width: cellWidth, height: minimumHeight)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
