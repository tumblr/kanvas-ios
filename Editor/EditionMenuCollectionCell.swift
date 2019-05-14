//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct EditionMenuCollectionCellConstants {
    static let circleDiameter: CGFloat = 49
    static let padding: CGFloat = 5
    
    static var height: CGFloat {
        return circleDiameter
    }
    
    static var width: CGFloat {
        return circleDiameter + 2 * padding
    }
}

/// The cell in EditionMenuCollectionView to display an individual option
final class EditionMenuCollectionCell: UICollectionViewCell {
    
    static let height = EditionMenuCollectionCellConstants.height
    static let width = EditionMenuCollectionCellConstants.width
    
    private weak var circleView: UIImageView?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    /// Updates the cell to the EditionMenu properties
    ///
    /// - Parameter item: The EditionMenu to display
    func bindTo(_ option: EditionOption) {
        circleView?.image = option.image
    }
    
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        circleView?.image = nil
        circleView?.backgroundColor = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        let imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.accessibilityIdentifier = "Edition Menu Cell View"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: EditionMenuCollectionCellConstants.circleDiameter),
            imageView.widthAnchor.constraint(equalToConstant: EditionMenuCollectionCellConstants.circleDiameter)
            ])
        
        circleView = imageView
    }
}
