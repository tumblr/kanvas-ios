//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol StickerCollectionCellDelegate: AnyObject {
    /// Callback method for when tapping a cell
    ///
    /// - Parameters:
    ///   - id: the sticker id
    ///   - sticker: the sticker image
    ///   - size: image view size
    func didSelect(id: String, image: UIImage, with size: CGSize)
    
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
    static let loadingViewBackgroundColor: UIColor = .clear
    static let loadingViewColor: UIColor = .lightGray
}

/// The cell in StickerCollectionView to display an individual sticker
final class StickerCollectionCell: UICollectionViewCell {
    
    static let padding: CGFloat = Constants.padding
    
    private var stickerId: String?
    private let mainView = UIButton()
    private let stickerView = UIImageView()
    private let loadingView = LoadingIndicatorView()
    private var imageTask: KanvasCancelable?
    
    var imageLoader: KanvasStickerLoader?
    
    weak var delegate: StickerCollectionCellDelegate?
    
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
        stickerId = nil
        mainView.backgroundColor = Constants.unselectedColor
        stickerView.image = nil
        stickerView.backgroundColor = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setUpMainView()
        setUpStickerView()
        setUpLoadingView()
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
    
    /// Sets up the loading spinner
    private func setUpLoadingView() {
        loadingView.add(into: stickerView)
        loadingView.backgroundColor = Constants.loadingViewBackgroundColor
        loadingView.indicatorColor = Constants.loadingViewColor
    }
    
    // MARK: - Gestures
    
    @objc private func didPress() {
        guard let id = stickerId, let image = stickerView.image else { return }
        delegate?.didSelect(id: id, image: image, with: stickerView.bounds.size)
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
    /// - Parameters:
    ///   - sticker: The sticker to display
    ///   - type: The sticker type
    ///   - index: cell index in the collection
    func bindTo(_ sticker: Sticker, type: StickerType, index: Int) {
        guard let url = URL(string: sticker.imageUrl) else { return }
        stickerId = sticker.id
        loadingView.startLoading()
        
        let completion: (UIImage?, Error?) -> (Void) = { [weak self] image, _ in
            if let image = image {
                self?.delegate?.didLoadImage(index: index, type: type, image: image)
            }
            
            performUIUpdate {
                self?.loadingView.stopLoading()
            }
        }
        
        imageTask = imageLoader?.loadSticker(at: url, imageView: stickerView, completion: completion)
    }
}
