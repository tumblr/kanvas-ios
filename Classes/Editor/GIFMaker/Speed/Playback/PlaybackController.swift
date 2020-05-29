//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting an option.
protocol PlaybackControllerDelegate: class {
    func didSelect(option: PlaybackOption)
}

/// Controller for handling the playback options.
final class PlaybackController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PlaybackCollectionCellDelegate {
    
    weak var delegate: PlaybackControllerDelegate?
    private let playbackView = PlaybackView()
    
    private var options: [PlaybackOption]
    
    // MARK: - Initializers
    
    init() {
        options = [.loop, .rebound, .reverse]
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
        PlaybackCollectionCell.width = calculateCellWidth()
        playbackView.cellWidth = calculateCellWidth()
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaybackCollectionCell.identifier, for: indexPath)
        if let cell = cell as? PlaybackCollectionCell, let option = options.object(at: indexPath.item) {
            cell.delegate = self
            cell.bindTo(option)
        }
        return cell
    }
    
    // MARK: - PlaybackCollectionCellDelegate
    
    func didTap(cell: PlaybackCollectionCell) {
        guard let indexPath = playbackView.collectionView.indexPath(for: cell),
            let option = options.object(at: indexPath.item) else { return }
        
        delegate?.didSelect(option: option)
    }
    
    // MARK: - Private utilities
    
    private func calculateCellWidth() -> CGFloat {
        return playbackView.bounds.width / CGFloat(options.count)
    }
}
