//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct MediaClipsEditorViewConstants {
    static let trashSize: CGFloat = 50
    static let padding: CGFloat = 25
    static let trashAnimationDuration: TimeInterval = 0.2

    static var height: CGFloat = padding + MediaClipsCollectionView.height + padding + trashSize
}

protocol MediaClipsEditorViewDelegate: class {
    /// Callback for when trash button is selected
    func trashButtonWasPressed()
}

/// View for media clips editor
final class MediaClipsEditorView: IgnoreTouchesView {
    
    static let height = MediaClipsEditorViewConstants.height

    let collectionContainer: IgnoreTouchesView
    let trashButton: UIButton

    weak var delegate: MediaClipsEditorViewDelegate?

    init() {
        collectionContainer = IgnoreTouchesView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Media Clips Collection Container"
        collectionContainer.clipsToBounds = false

        trashButton = UIButton()
        trashButton.accessibilityIdentifier = "Media Clips Trash Button"
        trashButton.setImage(KanvasCameraImages.deleteImage, for: .normal)
        super.init(frame: .zero)

        clipsToBounds = false
        setUpViews()
        trashButton.addTarget(self, action: #selector(trashPressed), for: .touchUpInside)
        hideTrash()
    }

    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// method to animate and fade the trash button in
    func showTrash() {
        UIView.animate(withDuration: MediaClipsEditorViewConstants.trashAnimationDuration) {
            self.trashButton.alpha = 1
        }
    }

    /// method to animate and fade the trash button out
    func hideTrash() {
        UIView.animate(withDuration: MediaClipsEditorViewConstants.trashAnimationDuration) {
            self.trashButton.alpha = 0
        }
    }

}

// MARK: - UI Layout
private extension MediaClipsEditorView {

    func setUpViews() {
        setUpCollection()
        setUpTrash()
    }

    func setUpCollection() {
        addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor),
            collectionContainer.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -MediaClipsEditorViewConstants.padding),
            collectionContainer.heightAnchor.constraint(equalToConstant: MediaClipsCollectionView.height)
        ])
    }

    func setUpTrash() {
        addSubview(trashButton)
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trashButton.bottomAnchor.constraint(equalTo: collectionContainer.topAnchor, constant: -MediaClipsEditorViewConstants.padding),
            trashButton.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            trashButton.widthAnchor.constraint(equalTo: trashButton.heightAnchor),
            trashButton.heightAnchor.constraint(equalToConstant: MediaClipsEditorViewConstants.trashSize)
        ])
    }

}

// MARK: - Button handling
extension MediaClipsEditorView {

    @objc func trashPressed() {
        delegate?.trashButtonWasPressed()
    }

}
