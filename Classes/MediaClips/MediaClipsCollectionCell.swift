//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import TumblrTheme
import UIKit

/// Delegate for touch events on this cell
protocol MediaClipsCollectionCellDelegate {
    /// Callback method for dragging the cell
    ///
    /// - Parameter newDragState: The new state of the drag event
    func didChangeState(newDragState: UICollectionViewCell.DragState)
    
    /// Callback method for swiping the cell
    ///
    /// - Parameter cell: The currently swiped cell
    func didSwipeUp(cell: UICollectionViewCell)
}
private struct MediaClipsCollectionCellConstants {
    static let cellPadding: CGFloat = 2
    static let clipHeight: CGFloat = 80
    static let clipWidth: CGFloat = 56
    static let borderWidth: CGFloat = 2
    static let cornerRadius: CGFloat = 8
    static let font: UIFont = .imbe85()
    static let labelPadding: CGFloat = 6
    static let labelHeight: CGFloat = 14
    static let clipAlpha: CGFloat = 0.5

    static var minimumHeight: CGFloat {
        return clipHeight
    }

    static var width: CGFloat {
        return clipWidth + 2 * cellPadding
    }
}

/// The cell in MediaClipsCollectionView to display an individual clip
final class MediaClipsCollectionCell: UICollectionViewCell {
    
    static let minimumHeight = MediaClipsCollectionCellConstants.minimumHeight
    static let width = MediaClipsCollectionCellConstants.width

    private let clipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = MediaClipsCollectionCellConstants.cornerRadius
        view.layer.borderColor = KanvasCameraColors.mediaBorderColor.cgColor
        view.layer.borderWidth = MediaClipsCollectionCellConstants.borderWidth
        return view
    }()
    private let clipImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.alpha = MediaClipsCollectionCellConstants.clipAlpha
        return view
    }()
    private let clipLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .right
        label.textColor = .white
        label.font = MediaClipsCollectionCellConstants.font
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    /// The touch delegate to be injected
    var touchDelegate: MediaClipsCollectionCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setupGestures()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
        setupGestures()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clipImage.image = .none
    }

    /// updates the cell to the MediaClip properties
    ///
    /// - Parameter item: The MediaClip to display
    func bindTo(_ item: MediaClip) {
        clipImage.image = item.representativeFrame
        clipLabel.text = item.overlayText
    }
}

// MARK: - Layout
extension MediaClipsCollectionCell {

    private func setUpView() {
        clipView.accessibilityIdentifier = "Media Clips Cell View"
        clipImage.accessibilityIdentifier = "Media Clips Cell ImageView"
        clipLabel.accessibilityIdentifier = "Media Clips Cell Duration"
        clipImage.add(into: clipView)
        clipView.addSubview(clipLabel)
        contentView.addSubview(clipView)
        clipView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clipView.centerXAnchor.constraint(equalTo: contentView.safeLayoutGuide.centerXAnchor),
            clipView.leadingAnchor.constraint(equalTo: contentView.safeLayoutGuide.leadingAnchor, constant: MediaClipsCollectionCellConstants.cellPadding),
            clipView.trailingAnchor.constraint(equalTo: contentView.safeLayoutGuide.trailingAnchor, constant: -MediaClipsCollectionCellConstants.cellPadding),
            clipView.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeLayoutGuide.topAnchor),
            clipView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeLayoutGuide.bottomAnchor),
            clipView.heightAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.clipHeight),
            clipView.widthAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.clipWidth)
        ])
        setupLabelConstraints()
    }

    private func setupLabelConstraints() {
        clipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clipLabel.trailingAnchor.constraint(equalTo: clipView.trailingAnchor, constant: -MediaClipsCollectionCellConstants.labelPadding),
            clipLabel.topAnchor.constraint(equalTo: clipView.topAnchor, constant: MediaClipsCollectionCellConstants.labelPadding),
            clipLabel.leadingAnchor.constraint(equalTo: clipView.leadingAnchor, constant: MediaClipsCollectionCellConstants.labelPadding),
            clipLabel.heightAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.labelHeight)
        ])
    }

    private func setupGestures() {
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gesture:)))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
    }
    
    /// This overrides the original function to to notify the drag delegate of the changed state
    ///
    /// - Parameter dragState: can be .lifting, .dragging, .none
    override func dragStateDidChange(_ dragState: UICollectionViewCell.DragState) {
        super.dragStateDidChange(dragState)
        touchDelegate?.didChangeState(newDragState: dragState)
    }
    
    // MARK: - gestures
    @objc private func swiped(gesture: UISwipeGestureRecognizer) {
        touchDelegate?.didSwipeUp(cell: self)
    }
}
