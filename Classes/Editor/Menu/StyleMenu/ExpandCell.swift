//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell.
protocol ExpandCellDelegate: class {
    
    /// Callback method when tapping a cell.
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: ExpandCell, recognizer: UITapGestureRecognizer)
}

private struct Constants {
    static let circleDiameter: CGFloat = 48
    static let labelHeight: CGFloat = 24
    static let circleMargin: CGFloat = 4
    
    static let animationDuration: TimeInterval = 0.25
    static let labelFont: UIFont = .boldSystemFont(ofSize: 16)
    static let labelInset: CGFloat = 12
    static let labelTextColor: UIColor = .white
    static let backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.4)
    static let downAngle: CGFloat = 0
    static let upAngle: CGFloat = .pi * 0.999 // Trick to make it rotate counter clockwise
    
    static var height: CGFloat {
        return circleDiameter + 2 * circleMargin
    }
    
    static var width: CGFloat {
        return circleDiameter
    }
}

/// The cell in StyleMenuView to display an individual option.
final class ExpandCell: UIView {
    
    static let height = Constants.height
    static let width = Constants.width
    
    let iconView: UIImageView
    private let label: UILabel
    
    weak var delegate: ExpandCellDelegate?
        
    init() {
        iconView = UIImageView()
        label = RoundedLabel()
        super.init(frame: .zero)
        setUpView()
        setUpRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setupIconView()
        setupLabel()
        close()
    }
    
    private func setupIconView() {
        addSubview(iconView)
        iconView.accessibilityIdentifier = "Vertical Menu Cell Icon View"
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = Constants.circleDiameter / 2
        iconView.layer.masksToBounds = true
        iconView.contentMode = .center
        iconView.image = KanvasCameraImages.chevron
        iconView.backgroundColor = Constants.backgroundColor
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter),
            iconView.widthAnchor.constraint(equalToConstant: Constants.circleDiameter)
        ])
    }
    
    private func setupLabel() {
        addSubview(label)
        label.accessibilityIdentifier = "Vertical Menu Cell Label"
        label.textColor = Constants.labelTextColor
        label.backgroundColor = Constants.backgroundColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        
        let leadingMargin = Constants.circleDiameter + Constants.circleMargin
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: leadingMargin),
            label.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
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
    
    // MARK: - Public interface
    
    func open() {
        label.text = NSLocalizedString("EditorClose", comment: "Label for the 'Close' option in the editor tools")
        iconView.transform = CGAffineTransform(rotationAngle: Constants.upAngle)
    }
    
    func close() {
        label.text = NSLocalizedString("EditorMore", comment: "Label for the 'More' option in the editor tools")
        iconView.transform = CGAffineTransform(rotationAngle: Constants.downAngle)
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
