//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol FilterCollectionCellDelegate {
    /// Callback method when tapping a cell
    ///
    /// - Parameter cell: the cell that was tapped
    func didTap(cell: FilterCollectionCell)
}

private struct FilterCollectionCellConstants {
    static let animationDuration: TimeInterval = 0.1
    static let circleDiameter: CGFloat = 72
    static let circleMaxDiameter: CGFloat = 96.1
    
    static var minimumHeight: CGFloat {
        return circleMaxDiameter
    }
    
    static var width: CGFloat {
        return circleMaxDiameter
    }
}

/// The cell in FilterCollectionView to display an individual filter
final class FilterCollectionCell: UICollectionViewCell {
    
    static let minimumHeight = FilterCollectionCellConstants.minimumHeight
    static let width = FilterCollectionCellConstants.width
    
    private weak var circleView: UIImageView?
    
    var delegate: FilterCollectionCellDelegate?
    
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
    
    /// Updates the cell to the FilterItem properties
    ///
    /// - Parameter item: The FilterItem to display
    func bindTo(_ item: FilterItem) {
        guard item.type != .passthrough else { return }
        circleView?.image = KanvasCameraImages.filterTypes[item.type] ?? nil
        circleView?.backgroundColor = KanvasCameraColors.filterTypes[item.type] ?? nil
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
        imageView.accessibilityIdentifier = "Filter Cell View"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = FilterCollectionCellConstants.circleDiameter / 2
        imageView.layer.borderWidth = 3 * (FilterCollectionCellConstants.circleDiameter/FilterCollectionCellConstants.circleMaxDiameter)
        imageView.layer.borderColor = UIColor.white.cgColor

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleDiameter),
            imageView.widthAnchor.constraint(equalToConstant: FilterCollectionCellConstants.circleDiameter)
        ])
        
        circleView = imageView
    }
    
    // MARK: - Animations
    
    /// Changes the circle scale
    ///
    /// - Parameter scale: the new scale for the circle, 1.0 is the standard size
    private func setScale(_ scale: CGFloat) {
        circleView?.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    /// Sets the circle with standard size
    func setStandardSize() {
        setScale(1)
    }
    
    /// Changes the circle size according to a percentage.
    ///
    /// - Parameter percent: 0.0 is the standard size, while 1.0 is the biggest size
    func setSize(percent: CGFloat) {
        let maxIncrement = (FilterCollectionCellConstants.circleMaxDiameter - FilterCollectionCellConstants.circleDiameter) / FilterCollectionCellConstants.circleMaxDiameter
        let scale = 1 + percent * maxIncrement
        setScale(scale)
    }
    
    // MARK: - Gesture recognizers
    
    private func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer()
        contentView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self)
    }
}
