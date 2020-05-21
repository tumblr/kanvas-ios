//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for obtaining images.
protocol ThumbnailCollectionCellDelegate: class {
    
    /// Obtains a thumbnail for the background of the trimming tool
    ///
    /// - Parameter index: the index of the requested image.
    func getThumbnail(at index: Int) -> UIImage?
}

/// Constants for ThumbnailCollectionCell
private struct Constants {
    static let imageHeight: CGFloat = TrimView.height
    static let imageWidth: CGFloat = 50
}

/// The cell in ThumbnailCollectionView to display
final class ThumbnailCollectionCell: UICollectionViewCell {
    
    static let cellHeight = Constants.imageHeight
    static let cellWidth = Constants.imageWidth
    
    weak var delegate: ThumbnailCollectionCellDelegate?
    private let mainView = UIImageView()
    private var imageRequest: DispatchWorkItem?
    
    // MARK: - Initializers
    
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
        imageRequest?.cancel()
        mainView.image = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        setUpMainView()
    }
    
    private func setUpMainView() {
        contentView.addSubview(mainView)
        mainView.accessibilityIdentifier = "Thumbnail Collection Cell Main View"
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.contentMode = .scaleAspectFill
        mainView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),
            mainView.widthAnchor.constraint(equalToConstant: Constants.imageWidth)
        ])
    }
    
    
    // MARK: - Public interface
    
    /// Updates the cell with an image
    ///
    /// - Parameter image: The image to display
    func bindTo(_ index: Int) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            guard let image = delegate.getThumbnail(at: index) else { return }
            strongSelf.mainView.image = image
        }
        
        imageRequest = workItem
        DispatchQueue.main.async(execute: workItem)
    }
}
