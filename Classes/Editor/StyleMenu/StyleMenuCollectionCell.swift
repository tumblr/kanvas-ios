//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol StyleMenuCollectionCellDelegate: class {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: StyleMenuCollectionCell, recognizer: UITapGestureRecognizer)
}

private struct Constants {
    static let circleDiameter: CGFloat = 48
    static let labelHeight: CGFloat = 24
    static let circleMargin: CGFloat = 4
    
    static let animationDuration: TimeInterval = 0.25
    static let labelFont: UIFont = .boldSystemFont(ofSize: 16)
    static let labelTextColor: UIColor = .white
    static let backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    
    static var height: CGFloat {
        return circleDiameter + 2 * circleMargin
    }
    
    static var width: CGFloat {
        return circleDiameter
    }
}

/// The cell in StyleMenuCollectionView to display an individual option
final class StyleMenuCollectionCell: UICollectionViewCell, KanvasEditionMenuCollectionCell {
    
    static let height = Constants.height
    static let width = Constants.width
    
    let circleView: UIImageView = UIImageView()
    private let label: UILabel = CustomLabel()
    
    weak var delegate: StyleMenuCollectionCellDelegate?
        
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
    ///  - option: The style menu to display
    ///  - enabled: Whether the option is on or off.
    func bindTo(_ option: EditionOption, enabled: Bool) {
        label.text = option.text
        circleView.image = KanvasCameraImages.editionOptionNewTypes(option, enabled: enabled)
    }
    
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        circleView.image = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setupCircleView()
        setupLabel()
    }
    
    private func setupCircleView() {
        contentView.addSubview(circleView)
        circleView.accessibilityIdentifier = "Style Menu Cell Circle View"
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.clipsToBounds = true
        circleView.layer.cornerRadius = Constants.circleDiameter / 2
        circleView.layer.masksToBounds = true
        circleView.backgroundColor = Constants.backgroundColor
        circleView.contentMode = .center
        
        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleDiameter)
        ])
    }
    
    private func setupLabel() {
        contentView.addSubview(label)
        label.accessibilityIdentifier = "Style Menu Cell Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.labelFont
        label.textColor = Constants.labelTextColor
        label.backgroundColor = Constants.backgroundColor
        label.layer.cornerRadius = Constants.labelHeight / 2
        label.layer.masksToBounds = true
        
        let leadingMargin = Constants.circleDiameter + Constants.circleMargin
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: leadingMargin),
            label.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
        ])
    }
    
    // MARK: - Gesture recognizers
    
    private func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        contentView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
}

private class CustomLabel: UILabel {
    
    private let inset: CGFloat = 12
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        super.drawText(in: rect.inset(by: insets))
    }
        
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset * 2, height: size.height)
    }
}
