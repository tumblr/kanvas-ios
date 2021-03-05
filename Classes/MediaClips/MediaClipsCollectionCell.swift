//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

private struct MediaClipsCollectionCellConstants {
    static let animationDuration: TimeInterval = 0.1
    static let cellPadding: CGFloat = 2.9
    static let clipHeight: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellClipHeight
    static let clipWidth: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellClipWidth
    static let borderWidth: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellBorderWidth
    static let selectedBorderWidth: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellSelectedBorderWidth
    static let cornerRadius: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellCornerRadius
    static let font: UIFont = KanvasDesign.shared.mediaClipsCollectionCellFont
    static let labelHorizontalPadding: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellLabelHorizontalPadding
    static let labelVerticalPadding: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellLabelVerticalPadding
    static let labelHeight: CGFloat = 14
    static let clipAlpha: CGFloat = KanvasDesign.shared.mediaClipsCollectionCellClipAlpha

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
        view.layer.borderColor = KanvasColors.shared.mediaBorderColor.cgColor
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
        label.textAlignment = .left
        label.textColor = .white
        label.font = MediaClipsCollectionCellConstants.font
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clipImage.image = .none
        clipView.layer.borderWidth = MediaClipsCollectionCellConstants.borderWidth
    }

    override var isSelected: Bool {
        didSet {
            clipView.layer.borderWidth = isSelected ? MediaClipsCollectionCellConstants.selectedBorderWidth  : MediaClipsCollectionCellConstants.borderWidth
        }
    }

    /// updates the cell to the MediaClip properties
    ///
    /// - Parameter item: The MediaClip to display
    func bindTo(_ item: MediaClip) {
        let image = item.representativeFrame
        clipImage.image = image
        clipLabel.text = item.overlayText
    }

    // MARK: - Public interface

    /// shows or hides the cell
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        UIView.animate(withDuration: MediaClipsCollectionCellConstants.animationDuration) { [weak self] in
            self?.alpha = show ? 1 : 0
            self?.contentView.alpha = show ? 1 : 0
        }
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
            clipView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            clipView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: MediaClipsCollectionCellConstants.cellPadding),
            clipView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -MediaClipsCollectionCellConstants.cellPadding),
            clipView.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeAreaLayoutGuide.topAnchor),
            clipView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            clipView.heightAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.clipHeight),
            clipView.widthAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.clipWidth)
        ])
        setupLabelConstraints()
    }

    private func setupLabelConstraints() {
        clipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clipLabel.trailingAnchor.constraint(equalTo: clipView.trailingAnchor,
                                                constant: -MediaClipsCollectionCellConstants.labelHorizontalPadding),
            clipLabel.bottomAnchor.constraint(equalTo: clipView.bottomAnchor,
                                              constant: -MediaClipsCollectionCellConstants.labelVerticalPadding),
            clipLabel.leadingAnchor.constraint(equalTo: clipView.leadingAnchor,
                                               constant: MediaClipsCollectionCellConstants.labelHorizontalPadding),
            clipLabel.heightAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.labelHeight)
        ])
    }
}
