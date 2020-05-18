//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let defaultCollectionSize: Int = 10
}

/// Controller for handling the thumbnail collection in the trim menu.
final class ThumbnailCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static let defaultCollectionSize: Int = Constants.defaultCollectionSize
    
    private lazy var thumbnailCollectionView = ThumbnailCollectionView()
    
    private var thumbnails: [UIImage]
    private var cellWidth: CGFloat
    
    // MARK: - Initializers
    
    init() {
        thumbnails = []
        cellWidth = 0
        super.init(nibName: .none, bundle: .none)
    }
    
    init(thumbnails: [UIImage], cellWidth: CGFloat) {
        self.thumbnails = thumbnails
        self.cellWidth = cellWidth
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = thumbnailCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thumbnailCollectionView.collectionView.register(cell: ThumbnailCollectionCell.self)
        thumbnailCollectionView.collectionView.delegate = self
        thumbnailCollectionView.collectionView.dataSource = self
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionCell.identifier, for: indexPath)
        if let cell = cell as? ThumbnailCollectionCell, let thumbnail = thumbnails.object(at: indexPath.item) {
            cell.bindTo(thumbnail)
        }
        return cell
    }
    
    // MARK: - Public interface
    
    /// Sets the thumbnails at the background of the trim tool
    ///
    /// - Parameter thumbnails: images to be shown
    func setThumbnails(_ thumbnails: [UIImage]) {
        let newCellWidth = thumbnailCollectionView.bounds.width / CGFloat(thumbnails.count)
        ThumbnailCollectionCell.cellWidth = newCellWidth
        thumbnailCollectionView.cellWidth = newCellWidth
        self.thumbnails = thumbnails
        thumbnailCollectionView.collectionView.reloadData()
    }
}
