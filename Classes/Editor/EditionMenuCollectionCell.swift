//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol EditionMenuCollectionCellDelegate: class {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: EditionMenuCollectionCell, recognizer: UITapGestureRecognizer)
}

private struct EditionMenuCollectionCellConstants {
    static let circleDiameter: CGFloat = 50
    static let padding: CGFloat = 8
    
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
    
    private let circleView = UIImageView()
    
    weak var delegate: EditionMenuCollectionCellDelegate?
        
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
    
    /// Updates the cell according to EditionOption properties
    ///
    /// - Parameter item: The EditionMenu to display
    func bindTo(_ option: EditionOption) {
        circleView.image = KanvasCameraImages.editionOptionTypes[option] ?? nil
    }
    
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        circleView.image = nil
        circleView.backgroundColor = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        contentView.addSubview(circleView)
        circleView.accessibilityIdentifier = "Edition Menu Cell View"
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.contentMode = .scaleAspectFill
        circleView.clipsToBounds = true
        circleView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            circleView.heightAnchor.constraint(equalToConstant: EditionMenuCollectionCellConstants.circleDiameter),
            circleView.widthAnchor.constraint(equalToConstant: EditionMenuCollectionCellConstants.circleDiameter)
        ])
        
    }
    
    // MARK: - Gesture recognizers
    
    private func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer()
        contentView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
}
