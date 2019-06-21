//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol FilterCollectionInnerCellDelegate {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: FilterCollectionInnerCell, recognizer: UITapGestureRecognizer)
    
    /// Callback method when long pressing a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was long-pressed
    ///   - recognizer: the long-press gesture recognizer
    func didLongPress(cell: FilterCollectionInnerCell, recognizer: UILongPressGestureRecognizer)
}

protocol FilterCollectionCellDimensions {
    var circleDiameter: CGFloat { get }
    var circleMaxDiameter: CGFloat { get }
    var padding: CGFloat { get }
    var minimumHeight: CGFloat { get }
    var width: CGFloat { get }
}

final class FilterCollectionInnerCell: UICollectionViewCell {
    
    private static var animationDuration: TimeInterval = 0.2
    
    private var dimensions: FilterCollectionCellDimensions
    var delegate: FilterCollectionInnerCellDelegate?
    
    private weak var circleView: UIImageView?
    
    init(dimensions: FilterCollectionCellDimensions) {
        self.dimensions = dimensions
        super.init(frame: .zero)
        setUpView()
        setUpRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates the cell to the FilterItem properties
    ///
    /// - Parameter item: The FilterItem to display
    func bindTo(_ item: FilterItem) {
        guard item.type != .passthrough else { return }
        circleView?.image = KanvasCameraImages.filterTypes[item.type] ?? nil
        circleView?.backgroundColor = KanvasCameraColors.filterTypes[item.type] ?? nil
    }
    
    /// shows or hides the cell
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        UIView.animate(withDuration: FilterCollectionInnerCell.animationDuration) { [weak self] in
            self?.contentView.alpha = show ? 1 : 0
        }
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
        imageView.accessibilityIdentifier = "Filter Inner Cell View"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = dimensions.circleDiameter / 2
        imageView.layer.borderWidth = 3 * (dimensions.circleDiameter/dimensions.circleMaxDiameter)
        imageView.layer.borderColor = UIColor.white.cgColor
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: dimensions.circleDiameter),
            imageView.widthAnchor.constraint(equalToConstant: dimensions.circleDiameter)
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
        let maxIncrement = (dimensions.circleMaxDiameter - dimensions.circleDiameter) / dimensions.circleMaxDiameter
        let scale = 1 + percent * maxIncrement
        setScale(scale)
    }
    
    // MARK: - Gesture recognizers
    
    private func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer()
        let longPressRecognizer = UILongPressGestureRecognizer()
        contentView.addGestureRecognizer(tapRecognizer)
        contentView.addGestureRecognizer(longPressRecognizer)
        tapRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
        longPressRecognizer.addTarget(self, action: #selector(handleLongPress(recognizer:)))
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
    
    @objc private func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPress(cell: self, recognizer: recognizer)
    }
}
