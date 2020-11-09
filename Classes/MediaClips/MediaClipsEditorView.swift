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
    
    
    static let buttonHorizontalMargin: CGFloat = 16
    static let topPadding: CGFloat = 6
    static let bottomPadding: CGFloat = 6 + (Device.belongsToIPhoneXGroup ? 28 : 0)
    static let nextButtonCenterYOffset: CGFloat = 3
    
    // Redesign
    static let buttonLeadingMargin: CGFloat = 7
    static let buttonTrailingMargin: CGFloat = 28
    static let collectionTopPadding: CGFloat = 11
    static let collectionBottomPadding: CGFloat = Device.belongsToIPhoneXGroup ? 29 : 15
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

    static let totalHeight = MediaClipsCollectionView.totalHeight +
                            Constants.collectionTopPadding +
                            Constants.collectionBottomPadding
    
    weak var delegate: MediaClipsEditorViewDelegate?
    
    private let isRedesign: Bool
    private let mainContainer: IgnoreTouchesView
    private let nextButton: UIButton
    let collectionContainer: IgnoreTouchesView

    // MARK: - Initializers
    
    init(isRedesign: Bool) {
        self.isRedesign = isRedesign
        mainContainer = IgnoreTouchesView()
        mainContainer.backgroundColor = isRedesign ? CameraConstants.buttonBackgroundColor : KanvasCameraColors.shared.translucentBlack
        
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
        let bottomPadding: CGFloat
        let height: CGFloat
        if isRedesign {
            trailingMargin = Constants.nextButtonSize + Constants.buttonLeadingMargin + Constants.buttonTrailingMargin
            bottomPadding = Constants.collectionBottomPadding
            height = MediaClipsCollectionView.totalHeight
        }
        else {
            trailingMargin = Constants.nextButtonSize + Constants.buttonHorizontalMargin * 1.5
            bottomPadding = Constants.bottomPadding
            height = MediaClipsCollectionView.height
        }
        
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.trailingAnchor, constant: -trailingMargin),
            collectionContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -bottomPadding),
            collectionContainer.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    private func setUpNextButton() {
        mainContainer.addSubview(nextButton)
        nextButton.accessibilityIdentifier = "Media Clips Next Button"
        nextButton.accessibilityLabel = "Next Button"
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingMargin: CGFloat
        let nextButtonYOffset: CGFloat
        if isRedesign {
            let circle = UIImage.circle(diameter: Constants.nextButtonSize, color: UIColor(hex: 0x00B8FF))
            nextButton.setBackgroundImage(circle, for: .normal)
            nextButton.setImage(KanvasCameraImages.nextArrowImage, for: .normal)
            trailingMargin = Constants.buttonTrailingMargin
            nextButtonYOffset = 0
        }
        else {
            nextButton.setImage(KanvasCameraImages.nextImage, for: .normal)
            trailingMargin = Constants.buttonHorizontalMargin
            nextButtonYOffset = Constants.nextButtonCenterYOffset
        }
        
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.trailingAnchor, constant: -trailingMargin),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.nextButtonSize),
            nextButton.widthAnchor.constraint(equalToConstant: Constants.nextButtonSize),
            nextButton.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor, constant: -nextButtonYOffset)
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
