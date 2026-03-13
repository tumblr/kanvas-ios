//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol EditionMenuCollectionCellDelegate: AnyObject {
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
    static let vectorIconHeight = Self.circleDiameter * 0.5
    
    static let animationDuration: TimeInterval = 0.25
    
    static var height: CGFloat {
        return circleDiameter
    }
    
    static var width: CGFloat {
        return circleDiameter + 2 * padding
    }
}

/// The cell in EditionMenuCollectionView to display an individual option
final class EditionMenuCollectionCell: UICollectionViewCell, KanvasEditorMenuCollectionCell {
    
    static let height = Constants.height
    static let width = Constants.width
    private var iconViewHeightConstraint: NSLayoutConstraint?
    
    let iconView: UIImageView
    
    private lazy var shadeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = Constants.vectorIconHeight
        return view
    }()
    
    weak var delegate: EditionMenuCollectionCellDelegate?
        
    override init(frame: CGRect) {
        iconView = UIImageView()
        super.init(frame: frame)
        setUpView()
        setUpRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates the cell according to EditionOption properties
    ///
    /// - Parameters
    ///  - option: The edition menu to display
    ///  - enabled: Whether the option is on or off.
    func bindTo(_ option: EditionOption, enabled: Bool) {
        if option == .cropRotate {
            iconView.image = KanvasImages.editionOptionTypes(option, enabled: enabled)?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = .white
            iconViewHeightConstraint?.constant = Constants.vectorIconHeight
            shadeView.isHidden = false
        }
        else {
            iconView.image = KanvasImages.editionOptionTypes(option, enabled: enabled)
            shadeView.isHidden = true
        }
    }
    
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        iconView.backgroundColor = nil
        shadeView.isHidden = true
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        contentView.addSubview(shadeView)
        contentView.addSubview(iconView)
        iconView.accessibilityIdentifier = "Edition Menu Cell Icon View"
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.masksToBounds = true
        iconViewHeightConstraint = iconView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter)
        iconViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            shadeView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            shadeView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            shadeView.widthAnchor.constraint(equalToConstant: Constants.circleDiameter),
            shadeView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter),
            iconView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor)
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
