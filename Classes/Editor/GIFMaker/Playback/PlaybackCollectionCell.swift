//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for PlaybackCollectionCell
private struct Constants {
    static let animationDuration: TimeInterval = 0.1
    static let height: CGFloat = 36
    static let width: CGFloat = 100
    static let cornerRadius: CGFloat = 18
    static let backgroundColor: UIColor = .clear
    static let fontColorActive: UIColor = .black
    static let fontColorInactive: UIColor = .white
    static let font: UIFont = .guavaMedium()
}

/// The cell in PlaybackController
final class PlaybackCollectionCell: UICollectionViewCell {
    
    static let height: CGFloat = Constants.height
    static var width: CGFloat = Constants.width
    private let label = UILabel()
    
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
        setSelected(false, animated: false)
        label.text = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setupLabel()
    }
    
    private func setupLabel() {
        contentView.addSubview(label)
        label.accessibilityIdentifier = "Playback Collection Cell Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = Constants.cornerRadius
        label.layer.masksToBounds = true
        label.font = Constants.font
        label.textColor = Constants.fontColorInactive
        label.backgroundColor = Constants.backgroundColor
        label.textAlignment = .center
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: PlaybackCollectionCell.width),
            label.heightAnchor.constraint(equalToConstant: PlaybackCollectionCell.height),
        ])
    }
    
    // MARK: - Public interface
    
    /// Adds the name of an option to a cell.
    ///
    /// - Parameter option: the option to take the name from.
    func bindTo(_ option: PlaybackOption) {
        label.text = option.description
    }
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        let action: () -> Void = { [weak self] in
            self?.label.textColor = selected ? Constants.fontColorActive : Constants.fontColorInactive
        }
        
        if animated {
            UIView.transition(with: self, duration: Constants.animationDuration,
                              options: .transitionCrossDissolve, animations: action)
        }
        else {
            action()
        }
    }
}
