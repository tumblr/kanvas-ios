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

/// Controller for handling the playback menu.
final class PlaybackController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PlaybackViewDelegate {
    
    weak var delegate: PlaybackControllerDelegate?
    
    private lazy var playbackView: PlaybackView = {
        let view = PlaybackView()
        view.delegate = self
        return view
    }()
    
    private var options: [PlaybackOption]
    
    private var selectedIndexPath: IndexPath {
        willSet {
            guard let cell = playbackView.collectionView.cellForItem(at: newValue) as? PlaybackCollectionCell else { return }
            cell.setSelected(true)
        }
        didSet {
            guard let cell = playbackView.collectionView.cellForItem(at: oldValue) as? PlaybackCollectionCell else { return }
            cell.setSelected(false)
        }
    }
    
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
        playbackView.selectionViewWidth = cellWidth
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
        
        cell.bindTo(option)
        
        if indexPath == selectedIndexPath {
            cell.setSelected(true, animated: false)
        }
        
        return cell
    }
    
    // MARK: - PlaybackViewDelegate
    
    func didTapCell(at indexPath: IndexPath) {
        didSelect(indexPath)
    }
    
    func didSwipeLeft() {
        let newIndexPath = selectedIndexPath.previous()
        didSelect(newIndexPath)
    }
    
    func didSwipeRight() {
        let newIndexPath = selectedIndexPath.next()
        didSelect(newIndexPath)
    }
    
    private func didSelect(_ indexPath: IndexPath) {
        guard let cell = playbackView.collectionView.cellForItem(at: indexPath) as? PlaybackCollectionCell,
            let option = options.object(at: indexPath.item),
            selectedIndexPath != indexPath else { return }
        
        selectedIndexPath = indexPath
        playbackView.select(cell: cell)
        
        delegate?.didSelect(option: option)
    }
    
    // MARK: - Private utilities
    
    private func calculateCellWidth() -> CGFloat {
        return playbackView.bounds.width / CGFloat(options.count)
    }
}
