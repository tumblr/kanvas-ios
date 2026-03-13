//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for obtaining images.
protocol ThumbnailCollectionCellDelegate: AnyObject {
    
    /// Obtains a thumbnail for the background of the trimming tool
    ///
    /// - Parameter timestamp: the time of the requested image.
    func getThumbnail(at timestamp: TimeInterval) -> UIImage?
}

/// Constants for ThumbnailCollectionCell
private struct Constants {
    static let imageHeight: CGFloat = 63
    static let imageWidth: CGFloat = 50
    static let loadingViewBackgroundColor: UIColor = .clear
    static let loadingViewColor: UIColor = .lightGray
}

/// The cell in ThumbnailCollectionView to display
final class ThumbnailCollectionCell: UICollectionViewCell {
    
    static let cellHeight = Constants.imageHeight
    static let cellWidth = Constants.imageWidth
    
    weak var delegate: ThumbnailCollectionCellDelegate?
    private let mainView = UIImageView()
    private let loadingView = LoadingIndicatorView()
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
        setUpLoadingView()
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
            mainView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            mainView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    /// Sets up the loading spinner
    private func setUpLoadingView() {
        loadingView.add(into: mainView)
        loadingView.backgroundColor = Constants.loadingViewBackgroundColor
        loadingView.indicatorColor = Constants.loadingViewColor
    }
    
    // MARK: - Public interface
    
    /// Updates the cell with an image
    ///
    /// - Parameter timeInterval: The timestamp of the cell.
    func bindTo(_ timeInterval: TimeInterval) {
        loadingView.startLoading()
        let workItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return }
            let image = delegate.getThumbnail(at: timeInterval)
            strongSelf.loadingView.stopLoading()
            strongSelf.mainView.image = image
        }
        
        imageRequest = workItem
        DispatchQueue.main.async(execute: workItem)
    }
}
