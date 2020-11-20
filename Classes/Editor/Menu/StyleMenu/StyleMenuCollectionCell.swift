//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell.
protocol StyleMenuCollectionCellDelegate: class {
    
    /// Callback method when tapping a cell.
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
    static let labelInset: CGFloat = 12
    static let labelTextColorOff: UIColor = .white
    static let labelTextColorOn: UIColor = .black
    static let backgroundColorOff: UIColor = UIColor.black.withAlphaComponent(0.6)
    static let backgroundColorOn: UIColor = UIColor.white.withAlphaComponent(0.6)
    
    
    static var height: CGFloat {
        return circleDiameter + 2 * circleMargin
    }
    
    static var width: CGFloat {
        return circleDiameter
    }
}

/// The cell in StyleMenuCollectionView to display an individual option.
final class StyleMenuCollectionCell: UICollectionViewCell, KanvasEditorMenuCollectionCell {
    
    static let height = Constants.height
    static let width = Constants.width
    
    let iconView: UIImageView
    private let label: UILabel
    
    weak var delegate: StyleMenuCollectionCellDelegate?
        
    override init(frame: CGRect) {
        iconView = UIImageView()
        label = RoundedLabel()
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
    ///  - option: The style menu to display
    ///  - enabled: Whether the option is on or off.
    func bindTo(_ option: EditionOption, enabled: Bool) {
        let backgroundColor = enabled ? Constants.backgroundColorOn : Constants.backgroundColorOff
        let textColor = enabled ? Constants.labelTextColorOn : Constants.labelTextColorOff
        label.text = option.text
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        iconView.image = KanvasCameraImages.styleOptionTypes(option, enabled: enabled)
        iconView.backgroundColor = backgroundColor
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        iconView.image = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setupIconView()
        setupLabel()
    }
    
    private func setupIconView() {
        contentView.addSubview(iconView)
        iconView.accessibilityIdentifier = "Style Menu Cell Icon View"
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = Constants.circleDiameter / 2
        iconView.layer.masksToBounds = true
        iconView.contentMode = .center
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter),
            iconView.widthAnchor.constraint(equalToConstant: Constants.circleDiameter)
        ])
    }
    
    private func setupLabel() {
        contentView.addSubview(label)
        label.accessibilityIdentifier = "Style Menu Cell Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        
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

/// Custom label with horizontal inset and rounded corners.
private class RoundedLabel: UILabel {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        font = Constants.labelFont
        layer.cornerRadius = Constants.labelHeight / 2
        layer.masksToBounds = true
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: Constants.labelInset, bottom: 0, right: Constants.labelInset)
        super.drawText(in: rect.inset(by: insets))
    }
        
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + Constants.labelInset * 2, height: size.height)
    }
}
