//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol StickerTypeCollectionCellDelegate: class {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    ///   - recognizer: the tap gesture recognizer
    func didTap(cell: StickerTypeCollectionCell, recognizer: UITapGestureRecognizer)
}

private struct Constants {
    static let imageHeight: CGFloat = 60
    static let imageWidth: CGFloat = 60
    static let bottomPadding: CGFloat = 30
    static let selectedColor: UIColor = UIColor(hex: "#001935").withAlphaComponent(0.2)
    static let unselectedColor: UIColor = .white
}

/// The cell in StickerCollectionView to display an individual sticker
final class StickerTypeCollectionCell: UICollectionViewCell {
    
    static let totalHeight = Constants.imageHeight + Constants.bottomPadding
    static let totalWidth = Constants.imageWidth
    
    private let mainView = UIView()
    private let stickerView = UIImageView()
    
    weak var delegate: StickerTypeCollectionCellDelegate?
        
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
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        mainView.backgroundColor = Constants.unselectedColor
        stickerView.image = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setUpMainView()
        setUpStickerView()
    }
    
    private func setUpMainView() {
        contentView.addSubview(mainView)
        mainView.accessibilityIdentifier = "Sticker Type Collection Cell Main View"
        mainView.backgroundColor = Constants.unselectedColor
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.clipsToBounds = true
        mainView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            mainView.heightAnchor.constraint(equalToConstant: Constants.imageHeight + Constants.bottomPadding),
            mainView.widthAnchor.constraint(equalToConstant: Constants.imageWidth)
        ])
    }

    
    private func setUpStickerView() {
        mainView.addSubview(stickerView)
        stickerView.accessibilityIdentifier = "Sticker Type Collection Cell Sticker View"
        stickerView.translatesAutoresizingMaskIntoConstraints = false
        stickerView.contentMode = .scaleAspectFill
        stickerView.clipsToBounds = true
        stickerView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            stickerView.topAnchor.constraint(equalTo: mainView.topAnchor),
            stickerView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            stickerView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),
            stickerView.widthAnchor.constraint(equalToConstant: Constants.imageWidth)
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
    
    /// Updates the cell according to the sticker properties
    ///
    /// - Parameter sticker: The sticker to display
    func bindTo(_ sticker: Sticker) {
        stickerView.image = KanvasCameraImages.filterTypes[.wavePool]!
    }
    
    func setSelected(_ selected: Bool) {
        mainView.backgroundColor = selected ? Constants.selectedColor : Constants.unselectedColor
    }
}
