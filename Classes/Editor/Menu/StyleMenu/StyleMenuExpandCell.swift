//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell.
protocol StyleMenuExpandCellDelegate: class {
    
    /// Callback method when tapping a cell.
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: StyleMenuExpandCell, recognizer: UITapGestureRecognizer)
}

private struct Constants {
    static let circleDiameter: CGFloat = 48
    static let circleMargin: CGFloat = 4
    
    static let animationDuration: TimeInterval = 0.25
    static let labelTextColor: UIColor = .white
    static let backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.4)
    static let downAngle: CGFloat = 0
    static let upAngle: CGFloat = .pi * 0.999 // Trick to make it rotate always to the left
    
    static var height: CGFloat {
        return circleDiameter + 2 * circleMargin
    }
}

/// The cell in StyleMenuView to display an individual option.
final class StyleMenuExpandCell: UIView {
    
    static let height = Constants.height
    
    let iconView: UIImageView
    private let label: UILabel
    
    weak var delegate: StyleMenuExpandCellDelegate?
        
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
    
    // MARK: - Layout
    
    private func setUpView() {
        setupIconView()
        setupLabel()
        close()
    }
    
    private func setupIconView() {
        addSubview(iconView)
        iconView.accessibilityIdentifier = "Style Menu Cell Icon View"
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
        label.accessibilityIdentifier = "Style Menu Cell Label"
        label.textColor = Constants.labelTextColor
        label.backgroundColor = Constants.backgroundColor
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
    
    // MARK: - Public interface
    
    func open() {
        label.text = NSLocalizedString("EditorClose", comment: "Label for the 'Close' option in the editor tools")
        iconView.transform = CGAffineTransform(rotationAngle: Constants.upAngle)
        sizeToFit()
    }
    
    func close() {
        label.text = NSLocalizedString("EditorMore", comment: "Label for the 'More' option in the editor tools")
        iconView.transform = CGAffineTransform(rotationAngle: Constants.downAngle)
        sizeToFit()
    }
}
