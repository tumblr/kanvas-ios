//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol FilterCollectionInnerCellDelegate: AnyObject {
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

/// Constants for the cell view
private struct Constants {
    // Animation times
    static let animationDuration: TimeInterval = 0.2
    static let pressAnimationDuration: TimeInterval = 0.3
    static let releaseAnimationDuration: TimeInterval = 0.2
    static let poppingBounceDuration: TimeInterval = 0.6
    
    // Scales for each cell state
    static let selectedScale: CGFloat = 0.78
    static let unselectedScale: CGFloat = 1
    static let pressedScale: CGFloat = 0.7
}

final class FilterCollectionInnerCell: UICollectionViewCell {
    
    private var dimensions: FilterCollectionCellDimensions
    weak var delegate: FilterCollectionInnerCellDelegate?
    
    private weak var mainView: UIImageView?
    private let circleView: UIImageView = UIImageView()
    private let iconView: UIImageView = UIImageView()
    
    private let tapRecognizer: UITapGestureRecognizer?
    private let longPressRecognizer: UILongPressGestureRecognizer?
    
    init(dimensions: FilterCollectionCellDimensions,
         tapRecognizer: UITapGestureRecognizer? = UITapGestureRecognizer(),
         longPressRecognizer: UILongPressGestureRecognizer? = UILongPressGestureRecognizer()) {
        self.dimensions = dimensions
        self.tapRecognizer = tapRecognizer
        self.longPressRecognizer = longPressRecognizer
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
        iconView.image = KanvasImages.filterTypes[item.type] ?? nil
        iconView.backgroundColor = KanvasColors.shared.filterColors[item.type]
    }
    
    /// shows or hides the cell
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.contentView.alpha = show ? 1 : 0
        }
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        iconView.backgroundColor = nil
        iconView.transform = .identity
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setUpMainView()
        setUpIconView()
        setUpCircleBorder()
    }
    
    /// Sets up a container for the white circle and the filter icon
    private func setUpMainView() {
        let imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.accessibilityIdentifier = "Filter Inner Cell Main View"
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: dimensions.circleDiameter),
            imageView.widthAnchor.constraint(equalToConstant: dimensions.circleDiameter)
        ])
        
        mainView = imageView
    }
    
    /// Sets up the filter icon
    private func setUpIconView() {
        guard let mainView = mainView else { return }
        iconView.add(into: mainView)
        iconView.accessibilityIdentifier = "Filter Inner Cell Icon View"
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.masksToBounds = true
        iconView.layer.cornerRadius = dimensions.circleDiameter / 2
    }
    
    /// Sets up view that contains the circular border
    private func setUpCircleBorder() {
        guard let mainView = mainView else { return }
        circleView.add(into: mainView)
        circleView.accessibilityIdentifier = "Filter Inner Cell Circle Border"
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.contentMode = .scaleAspectFill
        circleView.clipsToBounds = true
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = dimensions.circleDiameter / 2
        circleView.layer.borderWidth = KanvasDesign.shared.filterCollectionInnerCellBorderWidth * (dimensions.circleDiameter/dimensions.circleMaxDiameter)
        circleView.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - Animations
    
    /// Changes the scale of the main view
    ///
    /// - Parameter scale: the new scale for the circle, 1.0 is the standard size
    private func setMainScale(_ scale: CGFloat) {
        mainView?.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    /// Changes the scale of the filter icon
    ///
    /// - Parameter scale: the new scale for the icon, 1.0 is the standard size
    private func setIconScale(_ scale: CGFloat) {
        iconView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    /// Animates the icon to 'selected' size
    private func setIconSelected() {
        UIView.animate(withDuration: Constants.releaseAnimationDuration) {
            self.setIconScale(Constants.selectedScale)
        }
    }
    
    /// Animates the icon back to 'unselected' size
    private func setIconUnselected() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.setIconScale(Constants.unselectedScale)
        }
    }
    
    /// Animates the icon to 'pressed' size
    private func setIconPressed() {
        UIView.animate(withDuration: Constants.pressAnimationDuration) {
            self.setIconScale(Constants.pressedScale)
        }
    }
    
    // MARK: - Public interface
    
    /// Sets the circle with standard size
    func setStandardSize() {
        setMainScale(1)
    }
    
    /// Changes the size of the filter icon, depending on whether the
    /// icon is selected or not
    ///
    /// - Parameter selected: whether the cell is selected or not
    func setSelected(_ selected: Bool) {
        if selected {
            setIconSelected()
        }
        else {
            setIconUnselected()
        }
    }
    
    /// Changes the size of the filter icon to 'pressed' size
    func press() {
        setIconPressed()
    }
    
    /// Changes the circle size according to a percentage.
    ///
    /// - Parameter percent: 0.0 is the standard size, while 1.0 is the biggest size
    func setSize(percent: CGFloat) {
        let maxIncrement = (dimensions.circleMaxDiameter - dimensions.circleDiameter) / dimensions.circleMaxDiameter
        let scale = 1 + percent * maxIncrement
        setMainScale(scale)
    }
    
    /// Shrinks the cell until it is hidden
    func shrink() {
        mainView?.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    /// Increases the size of the cell until it reaches its regular size, with a bouncing effect
    func pop() {
        let regularSize: CGFloat = 1
        let increment: CGFloat = 0.1
        
        UIView.animateKeyframes(withDuration: Constants.poppingBounceDuration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4 / Constants.poppingBounceDuration, animations: {
                self.mainView?.transform = CGAffineTransform(scaleX: regularSize + increment, y: regularSize + increment)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4 / Constants.poppingBounceDuration, relativeDuration: 0.2 / Constants.poppingBounceDuration, animations: {
                self.mainView?.transform = CGAffineTransform(scaleX: regularSize, y: regularSize)
            })
        }, completion: nil)
    }
    
    // MARK: - Gesture recognizers
    
    private func setUpRecognizers() {
        if let tapRecognizer = tapRecognizer {
            contentView.addGestureRecognizer(tapRecognizer)
            tapRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
        }
        
        if let longPressRecognizer = longPressRecognizer {
            contentView.addGestureRecognizer(longPressRecognizer)
            longPressRecognizer.addTarget(self, action: #selector(handleLongPress(recognizer:)))
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
    
    @objc private func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPress(cell: self, recognizer: recognizer)
    }
}
