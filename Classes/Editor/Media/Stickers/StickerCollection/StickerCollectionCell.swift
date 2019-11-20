//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol StickerCollectionCellDelegate: class {
    /// Callback method when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    func didTap(cell: StickerCollectionCell)
}

/// Constants for StickerCollectionCell
private struct Constants {
    static let height: CGFloat = 80
    static let width: CGFloat = 80
    static let pressingColor: UIColor = UIColor(hex: "#001935").withAlphaComponent(0.05)
    static let unselectedColor: UIColor = .white
}

/// The cell in StickerCollectionView to display an individual sticker
final class StickerCollectionCell: UICollectionViewCell {
    
    static let height = Constants.height
    static let width = Constants.width
    
    private let mainView = UIButton()
    private let stickerView = UIImageView()
    private var imageTask: URLSessionTask?
    
    weak var delegate: StickerCollectionCellDelegate?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    /// Updates the cell according to the sticker properties
    ///
    /// - Parameter sticker: The sticker to display
    func bindTo(_ sticker: Sticker, cache: NSCache<NSString, UIImage>) {
        if let image = cache.object(forKey: NSString(string: sticker.imageUrl)) {
            stickerView.image = image
        }
        else {
            imageTask = stickerView.load(from: sticker.imageUrl) { url, image in
                cache.setObject(image, forKey: NSString(string: url.absoluteString))
            }
        }
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        mainView.backgroundColor = Constants.unselectedColor
        stickerView.image = nil
        stickerView.backgroundColor = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setUpMainView()
        setUpStickerView()
    }
    
    private func setUpMainView() {
        contentView.addSubview(mainView)
        mainView.accessibilityIdentifier = "Sticker Collection Cell Main View"
        mainView.backgroundColor = Constants.unselectedColor
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.clipsToBounds = true
        mainView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            mainView.heightAnchor.constraint(equalToConstant: Constants.height),
            mainView.widthAnchor.constraint(equalToConstant: Constants.width)
        ])
        
        mainView.addTarget(self, action: #selector(didPress), for: .touchUpInside)
        mainView.addTarget(self, action: #selector(didStartPressing), for: .touchDown)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchUpInside)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchUpOutside)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchCancel)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchDragExit)
    }
    
    private func setUpStickerView() {
        mainView.addSubview(stickerView)
        stickerView.accessibilityIdentifier = "Sticker Collection Cell View"
        stickerView.translatesAutoresizingMaskIntoConstraints = false
        stickerView.contentMode = .scaleAspectFit
        stickerView.clipsToBounds = false
        stickerView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            stickerView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            stickerView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor),
            stickerView.heightAnchor.constraint(equalTo: mainView.heightAnchor),
            stickerView.widthAnchor.constraint(equalTo: mainView.widthAnchor)
        ])
    }
    
        // MARK: - Gestures
    
    @objc private func didPress() {
        delegate?.didTap(cell: self)
    }
    
    @objc private func didStartPressing() {
        if !isSelected {
            mainView.backgroundColor = Constants.pressingColor
        }
    }
    
    @objc private func didStopPressing() {
        if !isSelected {
            mainView.backgroundColor = Constants.unselectedColor
        }
    }
}
