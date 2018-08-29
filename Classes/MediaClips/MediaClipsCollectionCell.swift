//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import UIKit

private struct MediaClipsCollectionCellConstants {
    static let CellPadding: CGFloat = 2
    static let ClipHeight: CGFloat = 80
    static let ClipWidth: CGFloat = 56
    static let BorderWidth: CGFloat = 2
    static let CornerRadius: CGFloat = 8
    static let FontSize: CGFloat = 12
    static let LabelPadding: CGFloat = 6
    static let LabelHeight: CGFloat = 14
    static let ClipAlpha: CGFloat = 0.5

    static var MinimumHeight: CGFloat {
        return ClipHeight
    }

    static var Width: CGFloat {
        return ClipWidth + 2 * CellPadding
    }
}

/// The cell in MediaClipsCollectionView to display an individual clip
final class MediaClipsCollectionCell: UICollectionViewCell {
    
    static let minimumHeight = MediaClipsCollectionCellConstants.MinimumHeight
    static let width = MediaClipsCollectionCellConstants.Width

    private let clipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = MediaClipsCollectionCellConstants.CornerRadius
        view.layer.borderColor = KanvasCameraColors.MediaBorderColor.cgColor
        view.layer.borderWidth = MediaClipsCollectionCellConstants.BorderWidth
        return view
    }()
    private let clipImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.alpha = MediaClipsCollectionCellConstants.ClipAlpha
        return view
    }()
    private let clipLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .right
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: MediaClipsCollectionCellConstants.FontSize)
        label.adjustsFontSizeToFitWidth = true
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
        setSelected(false)
    }

    /// updates the cell to the MediaClip properties
    ///
    /// - Parameter item: The MediaClip to display
    func bindTo(_ item: MediaClip) {
        clipImage.image = item.representativeFrame
        clipLabel.text = item.overlayText
    }

    /// Updates the cell to display the corrent state
    ///
    /// - Parameter selected: whether the cell is selected or unselected
    func setSelected(_ selected: Bool) {
        clipView.layer.borderColor = selected ? KanvasCameraColors.MediaSelectedBorderColor.cgColor : KanvasCameraColors.MediaBorderColor.cgColor
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
            clipView.leadingAnchor.constraint(equalTo: contentView.safeLayoutGuide.leadingAnchor, constant: MediaClipsCollectionCellConstants.CellPadding),
            clipView.trailingAnchor.constraint(equalTo: contentView.safeLayoutGuide.trailingAnchor, constant: -MediaClipsCollectionCellConstants.CellPadding),
            clipView.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeLayoutGuide.topAnchor),
            clipView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeLayoutGuide.bottomAnchor),
            clipView.heightAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.ClipHeight),
            clipView.widthAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.ClipWidth)
        ])
        setupLabelConstraints()
    }

    private func setupLabelConstraints() {
        clipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clipLabel.trailingAnchor.constraint(equalTo: clipView.trailingAnchor, constant: -MediaClipsCollectionCellConstants.LabelPadding),
            clipLabel.topAnchor.constraint(equalTo: clipView.topAnchor, constant: MediaClipsCollectionCellConstants.LabelPadding),
            clipLabel.leadingAnchor.constraint(equalTo: clipView.leadingAnchor, constant: MediaClipsCollectionCellConstants.LabelPadding),
            clipLabel.heightAnchor.constraint(equalToConstant: MediaClipsCollectionCellConstants.LabelHeight)
        ])
    }

}
