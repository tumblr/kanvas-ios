//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol StickerCollectionCellDelegate: class {
    /// Callback method for when tapping a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was tapped
    func didSelect(cell: StickerCollectionCell)
    
    /// Callback method for when an image has finished loading
    ///
    /// - Parameters:
    ///   - index: cell index in the collection
    ///   - type: the sticker type
    ///   - image: the image just loaded
    func didLoadImage(index: Int, type: StickerType, image: UIImage)
}

/// Constants for StickerCollectionCell
private struct Constants {
    static let padding: CGFloat = 6
    static let pressingColor: UIColor = UIColor(hex: "#001935").withAlphaComponent(0.05)
    static let unselectedColor: UIColor = .white
}

/// The cell in StickerCollectionView to display an individual sticker
final class StickerCollectionCell: UICollectionViewCell {
    
    static let padding: CGFloat = Constants.padding
    
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
    /// - Parameters:
    ///   - sticker: The sticker to display
    ///   - type: The sticker type
    ///   - cache: A cache to save the image
    ///   - index: cell index in the collection
    func bindTo(_ sticker: Sticker, type: StickerType, cache: NSCache<NSString, UIImage>, index: Int) {
        if let image = cache.object(forKey: NSString(string: sticker.imageUrl)) {
            stickerView.image = image
            delegate?.didLoadImage(index: index, type: type, image: image)
        }
        else {
            imageTask = stickerView.load(from: sticker.imageUrl) { [weak self] url, image in
                cache.setObject(image, forKey: NSString(string: url.absoluteString))
                self?.delegate?.didLoadImage(index: index, type: type, image: image)
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
    
    /// Sets up the container that changes its color depending on whether the cell is selected or not
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
            mainView.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor),
            mainView.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor)
        ])
        
        mainView.addTarget(self, action: #selector(didPress), for: .touchUpInside)
        mainView.addTarget(self, action: #selector(didStartPressing), for: .touchDown)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchUpInside)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchUpOutside)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchCancel)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchDragExit)
    }
    
    /// Sets up the view that contains the sticker
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
            stickerView.heightAnchor.constraint(equalTo: mainView.heightAnchor, constant: -Constants.padding * 2),
            stickerView.widthAnchor.constraint(equalTo: mainView.widthAnchor, constant: -Constants.padding * 2)
        ])
    }
    
        // MARK: - Gestures
    
    @objc private func didPress() {
        delegate?.didSelect(cell: self)
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
