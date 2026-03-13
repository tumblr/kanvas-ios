//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol DrawerTabBarCellDelegate: AnyObject {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: DrawerTabBarCell, recognizer: UITapGestureRecognizer)
}

/// Constants for DrawerTabBarCell
private struct Constants {
    static let labelHeight: CGFloat = 16
    static let spacing: CGFloat = 4.0
    static let bottomLineHeight: CGFloat = 2.0
    static let height: CGFloat = labelHeight + spacing + bottomLineHeight
    static let width: CGFloat = 80
    static let selectedFont: UIFont = KanvasFonts.shared.drawer.textSelectedFont
    static let unselectedFont: UIFont = KanvasFonts.shared.drawer.textUnselectedFont
    static let mainColor: UIColor = .black
}

/// The cell in DrawerTabBarController to display an individual tab
final class DrawerTabBarCell: UICollectionViewCell {
    
    static let height = Constants.height
    static let width = Constants.width
    
    private let label = UILabel()
    private let bottomLine = UIView()
    
    weak var delegate: DrawerTabBarCellDelegate?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
        setupRecognizers()
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        bottomLine.alpha = 0
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setupBottomLine()
        setupLabel()
    }
    
    /// Sets up the line shown below the label when the tab is selected
    private func setupBottomLine() {
        contentView.addSubview(bottomLine)
        bottomLine.accessibilityIdentifier = "Drawer Tab Bar Cell Bottom Line"
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.clipsToBounds = true
        bottomLine.layer.masksToBounds = true
        bottomLine.backgroundColor = Constants.mainColor
        
        NSLayoutConstraint.activate([
            bottomLine.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: Constants.bottomLineHeight),
            bottomLine.widthAnchor.constraint(equalToConstant: Constants.width)
        ])
        
        bottomLine.alpha = 0
    }
    
    /// Sets up the label with the tab text
    private func setupLabel() {
        contentView.addSubview(label)
        label.accessibilityIdentifier = "Drawer Tab Bar Cell Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.contentMode = .scaleAspectFill
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = Constants.unselectedFont
        label.textColor = Constants.mainColor
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.spacing),
            label.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            label.widthAnchor.constraint(equalToConstant: Constants.width)
        ])
    }
    
    // MARK: - Gesture recognizers
    
    private func setupRecognizers() {
        let tapRecognizer = UITapGestureRecognizer()
        contentView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didTap(cell: self, recognizer: recognizer)
    }
    
    // MARK: - Public interface
    
    /// Updates the cell according to the tab bar option properties
    ///
    /// - Parameter option: The option to display
    func bindTo(_ option: DrawerTabBarOption) {
        label.text = option.description
    }
    
    /// Updates the cell style depending on whether it selected or not
    ///
    /// - Parameter selected: true if it is selected, false if not.
    func setSelected(_ selected: Bool) {
        if selected {
            label.font = Constants.selectedFont
            bottomLine.alpha = 1
        }
        else {
            label.font = Constants.unselectedFont
            bottomLine.alpha = 0
        }
    }
}
