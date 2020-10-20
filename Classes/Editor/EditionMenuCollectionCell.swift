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

private struct Constants {
    static let circleDiameter: CGFloat = 50
    static let padding: CGFloat = 8
    
    static let animationDuration: TimeInterval = 0.25
    
    static var height: CGFloat {
        return circleDiameter
    }
    
    static var width: CGFloat {
        return circleDiameter + 2 * padding
    }
}

/// The cell in EditionMenuCollectionView to display an individual option
final class EditionMenuCollectionCell: UICollectionViewCell, KanvasEditionMenuCollectionCell {
    
    static let height = Constants.height
    static let width = Constants.width
    
    let circleView = UIImageView()
    
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
    /// - Parameters
    ///  - option: The edition menu to display
    ///  - enabled: Whether the option is on or off.
    func bindTo(_ option: EditionOption, enabled: Bool) {
        circleView.image = KanvasCameraImages.editionOptionTypes(option, enabled: enabled)
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
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleDiameter)
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
    
    // MARK: - Public interface
    
    /// Changes the image with an animation
    ///
    /// - Parameter image: the new image for the button
    func setImage(_ image: UIImage?) {
        let animation: (() -> Void) = { [weak self] in
            self?.circleView.image = image
        }
        
        UIView.transition(with: circleView,
                          duration: Constants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: animation,
                          completion: nil)
    }
}
