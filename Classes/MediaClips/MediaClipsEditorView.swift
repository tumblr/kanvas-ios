//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct MediaClipsEditorViewConstants {
    static let TrashSize: CGFloat = 50
    static let Padding: CGFloat = 25
    static let TrashAnimationDuration: TimeInterval = 0.2

    static var Height: CGFloat = Padding + MediaClipsCollectionView.height + Padding + TrashSize
}

protocol MediaClipsEditorViewDelegate: class {
    /// Callback for when trash button is selected
    func trashButtonWasPressed()
}

/// View for media clips editor
final class MediaClipsEditorView: UIView {
    
    static let height = MediaClipsEditorViewConstants.Height

    let collectionContainer: UIView
    let trashButton: UIButton

    weak var delegate: MediaClipsEditorViewDelegate?

    init() {
        collectionContainer = UIView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Media Clips Collection Container"

        trashButton = UIButton()
        trashButton.accessibilityIdentifier = "Media Clips Trash Button"
        trashButton.setImage(KanvasCameraImages.DeleteImage, for: .normal)    //TODO: Settings
        super.init(frame: .zero)

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
        UIView.animate(withDuration: MediaClipsEditorViewConstants.TrashAnimationDuration) {
            self.trashButton.alpha = 1
        }
    }

    /// method to animate and fade the trash button out
    func hideTrash() {
        UIView.animate(withDuration: MediaClipsEditorViewConstants.TrashAnimationDuration) {
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
            collectionContainer.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -MediaClipsEditorViewConstants.Padding),
            collectionContainer.heightAnchor.constraint(equalToConstant: MediaClipsCollectionView.height)
        ])
    }

    func setUpTrash() {
        addSubview(trashButton)
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trashButton.bottomAnchor.constraint(equalTo: collectionContainer.topAnchor, constant: -MediaClipsEditorViewConstants.Padding),
            trashButton.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            trashButton.widthAnchor.constraint(equalTo: trashButton.heightAnchor),
            trashButton.heightAnchor.constraint(equalToConstant: MediaClipsEditorViewConstants.TrashSize)
        ])
    }

}

// MARK: - Button handling
extension MediaClipsEditorView {

    @objc func trashPressed() {
        delegate?.trashButtonWasPressed()
    }

}
