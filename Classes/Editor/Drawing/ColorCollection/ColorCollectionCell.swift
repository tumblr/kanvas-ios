//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol ColorCollectionCellDelegate: class {
    /// Callback method when selecting a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was selected
    func didSelect(cell: ColorCollectionCell)
}

private struct ColorCollectionCellConstants {
    static let circleDiameter: CGFloat = CircularImageView.size
    static let padding: CGFloat = CircularImageView.padding
    
    static var height: CGFloat {
        return circleDiameter
    }
    
    static var width: CGFloat {
        return circleDiameter + 2 * padding
    }
}

/// The cell in ColorCollectionView to display an individual color
final class ColorCollectionCell: UICollectionViewCell {
    
    static let height = ColorCollectionCellConstants.height
    static let width = ColorCollectionCellConstants.width
    
    private weak var circleView: CircularImageView?
    
    weak var delegate: ColorCollectionCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
        setUpRecognizers()
    }
    
    /// Updates the cell according to a color
    ///
    /// - Parameter color: The UIColor to display
    func bindTo(_ color: UIColor) {
        circleView?.backgroundColor = color
    }
    
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        circleView?.image = nil
        circleView?.backgroundColor = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        let imageView = CircularImageView()
        contentView.addSubview(imageView)
        imageView.accessibilityIdentifier = "Color Cell View"
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: ColorCollectionCellConstants.circleDiameter),
            imageView.widthAnchor.constraint(equalToConstant: ColorCollectionCellConstants.circleDiameter)
        ])
        
        circleView = imageView
    }
    
    
    // MARK: - Gesture recognizers
    
    func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didSelect(cell: self)
    }
}
