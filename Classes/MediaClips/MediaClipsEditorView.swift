//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let animationDuration: TimeInterval = 0.5
    static let buttonHorizontalMargin: CGFloat = 16
    static let buttonRadius: CGFloat = 25
    static let addButtonWidth: CGFloat = 40
    static let addButtonHeight: CGFloat = 60
    static let nextButtonSize: CGFloat = 49
    static let buttonLeadingMargin: CGFloat = KanvasDesign.shared.mediaClipsEditorViewButtonLeadingMargin
    static let buttonTrailingMargin: CGFloat = KanvasDesign.shared.mediaClipsEditorViewButtonTrailingMargin
    static let topPadding: CGFloat = KanvasDesign.shared.mediaClipsEditorViewTopPadding
    static let bottomPadding: CGFloat = KanvasDesign.shared.mediaClipsEditorViewBottomPadding
    static let nextButtonCenterYOffset: CGFloat = KanvasDesign.shared.mediaClipsEditorViewNextButtonCenterYOffset
}

protocol MediaClipsEditorViewDelegate: AnyObject {
    /// Callback for when next button is selected
    func nextButtonWasPressed()
    func addButtonWasPressed()
}

/// View for media clips editor
final class MediaClipsEditorView: IgnoreTouchesView {
    
    static let height = MediaClipsCollectionView.height +
                        Constants.topPadding +
                        Constants.bottomPadding
    
    weak var delegate: MediaClipsEditorViewDelegate?
    
    private let mainContainer: IgnoreTouchesView
    private let nextButton: UIButton
    private let addButton: UIButton // For adding a new clip
    let collectionContainer: IgnoreTouchesView

    // MARK: - Initializers
    
    init(showsAddButton: Bool = false) {
        mainContainer = IgnoreTouchesView()
        mainContainer.backgroundColor = KanvasDesign.shared.mediaClipsEditorViewBackgroundColor
        
        collectionContainer = IgnoreTouchesView()

        nextButton = UIButton()
        addButton = UIButton()
        super.init(frame: .zero)
        
        clipsToBounds = false
        
        setUpViews()
        
        if showsAddButton {
            setUpAddButton()
        }
        else {
            setUpNextButton()
        }
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
        if KanvasDesign.shared.isBottomPicker {
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
        
        if KanvasDesign.shared.isBottomPicker {
            let circle = UIImage.circle(diameter: Constants.nextButtonSize, color: KanvasColors.shared.primaryButtonBackgroundColor)
            nextButton.setBackgroundImage(circle, for: .normal)
        }
        
        nextButton.setImage(KanvasDesign.shared.mediaClipsEditorViewNextImage, for: .normal)
        
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.buttonTrailingMargin),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.nextButtonSize),
            nextButton.widthAnchor.constraint(equalToConstant: Constants.nextButtonSize),
            nextButton.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor, constant: -Constants.nextButtonCenterYOffset)
        ])
    }
    
    private func setUpAddButton() {
        mainContainer.addSubview(addButton)
        addButton.accessibilityIdentifier = "Media Clips Next Button"
        addButton.accessibilityLabel = "Next Button"
        addButton.tintColor = .white
        addButton.setImage(UIImage.imageFromCameraBundle(named: "new"), for: .normal)
        addButton.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: mainContainer.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.buttonHorizontalMargin),
            addButton.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: Constants.addButtonHeight),
            addButton.widthAnchor.constraint(equalToConstant: Constants.addButtonWidth)
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func nextPressed() {
        delegate?.nextButtonWasPressed()
    }
    
    @objc private func addPressed() {
        delegate?.addButtonWasPressed()
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
