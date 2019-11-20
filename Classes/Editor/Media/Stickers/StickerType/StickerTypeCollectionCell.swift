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
    func didTap(cell: StickerTypeCollectionCell)
}

/// Constants for StickerTypeCollectionCell
private struct Constants {
    static let imageHeight: CGFloat = 60
    static let imageWidth: CGFloat = 60
    static let bottomPadding: CGFloat = 30
    static let selectedColor: UIColor = UIColor(hex: "#001935").withAlphaComponent(0.2)
    static let pressingColor: UIColor = UIColor(hex: "#001935").withAlphaComponent(0.05)
    static let unselectedColor: UIColor = .white
}

/// The cell in StickerTypeCollectionView to display an individual sticker
final class StickerTypeCollectionCell: UICollectionViewCell {
    
    static let totalHeight = Constants.imageHeight + Constants.bottomPadding
    static let totalWidth = Constants.imageWidth
    
    private var imageTask: URLSessionTask?
    
    private let mainView = UIButton()
    private let stickerView = UIImageView()
    
    weak var delegate: StickerTypeCollectionCellDelegate?
    
    override var isSelected: Bool {
        willSet {
            mainView.backgroundColor = newValue ? Constants.selectedColor : Constants.unselectedColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        stickerView.image = nil
        stickerView.backgroundColor = nil
        mainView.backgroundColor = Constants.unselectedColor
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setUpMainView()
        setUpStickerView()
    }
    
    /// Sets up the container that changes its color depending on whether the cell is selected or not
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
        
        mainView.addTarget(self, action: #selector(didPress), for: .touchUpInside)
        mainView.addTarget(self, action: #selector(didStartPressing), for: .touchDown)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchUpOutside)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchCancel)
        mainView.addTarget(self, action: #selector(didStopPressing), for: .touchDragExit)
    }

    /// Sets up the view that contains the sticker
    private func setUpStickerView() {
        mainView.addSubview(stickerView)
        stickerView.accessibilityIdentifier = "Sticker Type Collection Cell Sticker View"
        stickerView.translatesAutoresizingMaskIntoConstraints = false
        stickerView.contentMode = .scaleAspectFill
        stickerView.clipsToBounds = false
        stickerView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            stickerView.topAnchor.constraint(equalTo: mainView.topAnchor),
            stickerView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            stickerView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),
            stickerView.widthAnchor.constraint(equalToConstant: Constants.imageWidth)
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
    
    // MARK: - Public interface
    
    /// Updates the cell according to the sticker properties
    ///
    /// - Parameter sticker: The sticker type to display
    /// - Parameter cache: A cache to save the the image after loading
    func bindTo(_ stickerType: StickerType, cache: NSCache<NSString, UIImage>) {
        if let image = cache.object(forKey: NSString(string: stickerType.imageUrl)) {
            stickerView.image = image
        }
        else {
            imageTask = stickerView.load(from: stickerType.imageUrl) { url, image in
                cache.setObject(image, forKey: NSString(string: url.absoluteString))
            }
        }
    }
}
