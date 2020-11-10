//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let animationDuration: TimeInterval = 0.5
    static let buttonRadius: CGFloat = 25
    static let nextButtonSize: CGFloat = 49
    static let buttonLeadingMargin: CGFloat = KanvasCameraDesign.shared.mediaClipsEditorViewButtonLeadingMargin
    static let buttonTrailingMargin: CGFloat = KanvasCameraDesign.shared.mediaClipsEditorViewButtonTrailingMargin
    static let topPadding: CGFloat = KanvasCameraDesign.shared.mediaClipsEditorViewTopPadding
    static let bottomPadding: CGFloat = KanvasCameraDesign.shared.mediaClipsEditorViewBottomPadding
    static let nextButtonCenterYOffset: CGFloat = KanvasCameraDesign.shared.mediaClipsEditorViewNextButtonCenterYOffset
}

protocol MediaClipsEditorViewDelegate: class {
    /// Callback for when next button is selected
    func nextButtonWasPressed()
}

/// View for media clips editor
final class MediaClipsEditorView: IgnoreTouchesView {
    
    static let height = MediaClipsCollectionView.height +
                        Constants.topPadding +
                        Constants.bottomPadding
    
    weak var delegate: MediaClipsEditorViewDelegate?
    
    private let mainContainer: IgnoreTouchesView
    private let nextButton: UIButton
    let collectionContainer: IgnoreTouchesView

    // MARK: - Initializers
    
    init() {
        mainContainer = IgnoreTouchesView()
        mainContainer.backgroundColor = KanvasCameraDesign.shared.isRedesign ? CameraConstants.buttonBackgroundColor : KanvasCameraColors.shared.translucentBlack
        
        collectionContainer = IgnoreTouchesView()

        nextButton = UIButton()
        super.init(frame: .zero)
        
        clipsToBounds = false
        
        setUpViews()
    }

    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        setUpMainContainer()
        setUpCollection()
        setUpNextButton()
    }
    
    private func setUpMainContainer() {
        addSubview(mainContainer)
        
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setUpCollection() {
        mainContainer.addSubview(collectionContainer)
        collectionContainer.accessibilityIdentifier = "Media Clips Collection Container"
        collectionContainer.backgroundColor = .clear
        collectionContainer.clipsToBounds = false
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingMargin: CGFloat
        if KanvasCameraDesign.shared.isRedesign {
            trailingMargin = Constants.nextButtonSize + Constants.buttonLeadingMargin + Constants.buttonTrailingMargin
        }
        else {
            trailingMargin = Constants.nextButtonSize + Constants.buttonTrailingMargin * 1.5
        }
        
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.trailingAnchor, constant: -trailingMargin),
            collectionContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -Constants.bottomPadding),
            collectionContainer.heightAnchor.constraint(equalToConstant: MediaClipsCollectionView.height)
        ])
    }
    
    private func setUpNextButton() {
        mainContainer.addSubview(nextButton)
        nextButton.accessibilityIdentifier = "Media Clips Next Button"
        nextButton.accessibilityLabel = "Next Button"
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        if KanvasCameraDesign.shared.isRedesign {
            let circle = UIImage.circle(diameter: Constants.nextButtonSize, color: UIColor(hex: 0x00B8FF))
            nextButton.setBackgroundImage(circle, for: .normal)
        }
        
        nextButton.setImage(KanvasCameraDesign.shared.mediaClipsEditorViewNextImage, for: .normal)
        
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.buttonTrailingMargin),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.nextButtonSize),
            nextButton.widthAnchor.constraint(equalToConstant: Constants.nextButtonSize),
            nextButton.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor, constant: -Constants.nextButtonCenterYOffset)
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func nextPressed() {
        delegate?.nextButtonWasPressed()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the complete view
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.mainContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the preview button
    ///
    /// - Parameter show: true to show, false to hide
    func showPreviewButton(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.nextButton.alpha = show ? 1 : 0
        }
    }
}
