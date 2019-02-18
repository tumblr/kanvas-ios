//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import TumblrTheme

private struct MediaClipsEditorViewConstants {
    static let topPadding: CGFloat = 6
    static let bottomPadding: CGFloat = 12
    static let buttonHorizontalMargin: CGFloat = 25
    static let buttonRadius: CGFloat = 25
    static let buttonWidth: CGFloat = 91
    static let buttonHeight: CGFloat = 41
    static let buttonTopOffset: CGFloat = 3
    static let animationDuration: TimeInterval = 0.5
}

protocol MediaClipsEditorViewDelegate: class {
    /// Callback for when preview button is selected
    func previewButtonWasPressed()
}

/// View for media clips editor
final class MediaClipsEditorView: IgnoreTouchesView {
    
    static let height = MediaClipsCollectionView.height +
                        MediaClipsEditorViewConstants.topPadding +
                        MediaClipsEditorViewConstants.bottomPadding

    let collectionContainer: IgnoreTouchesView
    let previewButton: UIButton

    weak var delegate: MediaClipsEditorViewDelegate?

    init() {
        collectionContainer = IgnoreTouchesView()
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Media Clips Collection Container"
        collectionContainer.clipsToBounds = false

        previewButton = UIButton()
        previewButton.accessibilityIdentifier = "Media Clips Preview Button"
        super.init(frame: .zero)

        clipsToBounds = false
        backgroundColor = KanvasCameraColors.translucentBlack
        setUpViews()
        previewButton.addTarget(self, action: #selector(previewPressed), for: .touchUpInside)
    }

    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public interface
    
    func show(_ enabled: Bool) {
        UIView.animate(withDuration: MediaClipsEditorViewConstants.animationDuration) { [weak self] in
            self?.alpha = enabled ? 1 : 0
        }
    }
}

// MARK: - UI Layout
private extension MediaClipsEditorView {

    func setUpViews() {
        setUpCollection()
        setUpPreview()
    }
    
    func setUpCollection() {
        addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        let trailingMargin = MediaClipsEditorViewConstants.buttonWidth + MediaClipsEditorViewConstants.buttonHorizontalMargin * 2
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -trailingMargin),
            collectionContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                                        constant: -MediaClipsEditorViewConstants.bottomPadding),
            collectionContainer.heightAnchor.constraint(equalToConstant: MediaClipsCollectionView.height)
        ])
    }
    
    func setUpPreview() {
        addSubview(previewButton)
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.setTitle("Preview", for: .normal)
        previewButton.layer.cornerRadius = 20
        previewButton.backgroundColor = .tumblrBrightBlue
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.titleLabel?.font = .favoritTumblrMedium(fontSize: 15)
        NSLayoutConstraint.activate([
            previewButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -MediaClipsEditorViewConstants.buttonHorizontalMargin),
            previewButton.heightAnchor.constraint(equalToConstant: MediaClipsEditorViewConstants.buttonHeight),
            previewButton.widthAnchor.constraint(equalToConstant: MediaClipsEditorViewConstants.buttonWidth),
            previewButton.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor,
                                                   constant: MediaClipsEditorViewConstants.buttonTopOffset)
        ])
    }

}

// MARK: - Button handling
extension MediaClipsEditorView {

    @objc func previewPressed() {
        delegate?.previewButtonWasPressed()
    }

}
