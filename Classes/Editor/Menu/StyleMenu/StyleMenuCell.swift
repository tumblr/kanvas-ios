//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell.
protocol StyleMenuCellDelegate: class {
    
    /// Callback method when tapping a cell.
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: StyleMenuCell, recognizer: UITapGestureRecognizer)
}

private struct Constants {
    static let circleDiameter: CGFloat = 48
    static let circleMargin: CGFloat = 4
    
    static let animationDuration: TimeInterval = 0.25
    static let labelTextColorOff: UIColor = .white
    static let labelTextColorOn: UIColor = .black
    static let backgroundColorOff: UIColor = UIColor.black.withAlphaComponent(0.4)
    static let backgroundColorOn: UIColor = UIColor.white
    
    static var height: CGFloat {
        return circleDiameter + 2 * circleMargin
    }
}

/// The cell in StyleMenuView to display an individual option.
final class StyleMenuCell: UIView, KanvasEditorMenuCollectionCell {
    
    static let height = Constants.height
    
    let iconView: UIImageView
    private let label: UILabel
    
    weak var delegate: StyleMenuCellDelegate?
        
    init() {
        iconView = UIImageView()
        label = StyleMenuRoundedLabel()
        super.init(frame: .zero)
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
        sizeToFit()
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setupIconView()
        setupLabel()
    }
    
    private func setupIconView() {
        addSubview(iconView)
        iconView.accessibilityIdentifier = "Style Menu Cell Icon View"
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = Constants.circleDiameter / 2
        iconView.layer.masksToBounds = true
        iconView.contentMode = .center
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter),
            iconView.widthAnchor.constraint(equalToConstant: Constants.circleDiameter)
        ])
    }
    
    private func setupLabel() {
        addSubview(label)
        label.accessibilityIdentifier = "Style Menu Cell Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingMargin = Constants.circleDiameter + Constants.circleMargin
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: leadingMargin),
            label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: StyleMenuRoundedLabel.height),
        ])
    }
    
    // MARK: - Gesture recognizers
    
    private func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
}