//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for tapping a cell.
protocol PlaybackCollectionCellDelegate: class {
    
    /// Called when a cell is tapped
    ///
    /// - Parameter cell: the tapped cell
    func didTap(cell: PlaybackCollectionCell)
}

/// Constants for PlaybackCollectionCell
private struct Constants {
    static let height: CGFloat = 36
    static let width: CGFloat = 100
    static let cornerRadius: CGFloat = 18
    static let backgroundColorActive: UIColor = .white
    static let backgroundColorInactive: UIColor = .clear
    static let fontColorActive: UIColor = .black
    static let fontColorInactive: UIColor = .white
    static let font: UIFont = .guavaMedium()
}

/// The cell in PlaybackController
final class PlaybackCollectionCell: UICollectionViewCell {
    
    static let height: CGFloat = Constants.height
    static var width: CGFloat = Constants.width
    weak var delegate: PlaybackCollectionCellDelegate?
    private let button = UIButton()
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                button.backgroundColor = Constants.backgroundColorActive
                button.setTitleColor(Constants.fontColorActive, for: .normal)
            }
            else {
                button.backgroundColor = Constants.backgroundColorInactive
                button.setTitleColor(Constants.fontColorInactive, for: .normal)
            }
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        button.isSelected = false
        button.setTitle(nil, for: .normal)
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setupLabel()
    }
    
    private func setupLabel() {
        contentView.addSubview(button)
        button.accessibilityIdentifier = "Playback Collection Cell Label"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.cornerRadius
        button.titleLabel?.font = Constants.font
        button.setTitleColor(Constants.fontColorInactive, for: .normal)
        button.backgroundColor = Constants.backgroundColorInactive
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: PlaybackCollectionCell.width),
            button.heightAnchor.constraint(equalToConstant: PlaybackCollectionCell.height),
        ])
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func buttonTapped() {
        delegate?.didTap(cell: self)
    }
    
    // MARK: - Public interface
    
    /// Adds the name of an option to a cell.
    ///
    /// - Parameter option: the option to take the name from.
    func bindTo(_ option: PlaybackOption) {
        button.setTitle(option.text, for: .normal)
    }
}
