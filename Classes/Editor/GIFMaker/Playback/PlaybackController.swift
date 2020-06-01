//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting an option.
protocol PlaybackControllerDelegate: class {
    /// Called when a playback option is selected
    ///
    /// - Parameter option: the selected option.
    func didSelect(option: PlaybackOption)
}

/// Constants for PlaybackController
private struct Constants {
    static let initialIndexPath: IndexPath = IndexPath(item: 0, section: 0)
}

/// Controller for handling the playback options.
final class PlaybackController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PlaybackCollectionCellDelegate {
    
    weak var delegate: PlaybackControllerDelegate?
    private let playbackView = PlaybackView()
    
    private var options: [PlaybackOption]
    private var selectedIndexPath: IndexPath
    
    // MARK: - Initializers
    
    init() {
        options = [.loop, .rebound, .reverse]
        selectedIndexPath = Constants.initialIndexPath
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
        view = playbackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playbackView.collectionView.register(cell: PlaybackCollectionCell.self)
        playbackView.collectionView.delegate = self
        playbackView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let cellWidth = calculateCellWidth()
        PlaybackCollectionCell.width = cellWidth
        playbackView.cellWidth = cellWidth
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaybackCollectionCell.identifier, for: indexPath) as? PlaybackCollectionCell, let option = options.object(at: indexPath.item) else { return UICollectionViewCell() }
        
        cell.delegate = self
        cell.bindTo(option)
        
        if indexPath == selectedIndexPath {
            cell.isSelected = true
        }
        
        return cell
    }
    
    // MARK: - PlaybackCollectionCellDelegate
    
    func didTap(cell: PlaybackCollectionCell) {
        guard let indexPath = playbackView.collectionView.indexPath(for: cell),
            let selectedCell = playbackView.collectionView.cellForItem(at: selectedIndexPath),
            let option = options.object(at: indexPath.item),
            selectedIndexPath != indexPath else { return }
        
        selectedCell.isSelected = false
        cell.isSelected = true
        selectedIndexPath = indexPath
        
        delegate?.didSelect(option: option)
    }
    
    // MARK: - Private utilities
    
    private func calculateCellWidth() -> CGFloat {
        return playbackView.bounds.width / CGFloat(options.count)
    }
}
