//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol TextureSelectorViewDelegate: class {
    /// Called when the main button is selected
    func didTapTextureButton()
    
    /// Called when the pencil option is selected
    func didTapPencilButton()
    
    /// Called when the sharpie option is selected
    func didTapSharpieButton()
    
    /// Called when the marker option is selected
    func didTapMarkerButton()
}

private struct TextureSelectorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    
    static let stackViewInset: CGFloat = -10
    static let selectorHeight: CGFloat = 128
    static let selectorWidth: CGFloat = 34
    static let selectorPadding: CGFloat = 7
}

final class TextureSelectorView: IgnoreTouchesView {
    
    static let selectorHeight: CGFloat = TextureSelectorViewConstants.selectorHeight
    static let selectorWidth: CGFloat = TextureSelectorViewConstants.selectorWidth
    
    weak var delegate: TextureSelectorViewDelegate?
    
    private let mainButton: CircularImageView
    private let selectorBackground: CircularImageView
    private let optionContainer: UIStackView
    private let sharpieButton: UIButton
    private let pencilButton: UIButton
    private let markerButton: UIButton
    
    
    init() {
        mainButton = CircularImageView()
        selectorBackground = CircularImageView()
        optionContainer = ExtendedStackView(inset: TextureSelectorViewConstants.stackViewInset)
        sharpieButton = ExtendedButton(inset: TextureSelectorViewConstants.stackViewInset)
        pencilButton = ExtendedButton(inset: TextureSelectorViewConstants.stackViewInset)
        markerButton = ExtendedButton(inset: TextureSelectorViewConstants.stackViewInset)
        
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
        setUpMainButton()
        setUpSelectorBackground()
        setUpOptionContainer()
        setUpOptions()
    }
    
    /// Sets up the texture button
    private func setUpMainButton() {
        mainButton.contentMode = .center
        mainButton.image = KanvasCameraImages.pencilImage
        mainButton.accessibilityIdentifier = "Texture Main Button"
        mainButton.backgroundColor = .white
        addSubview(mainButton)
        
        NSLayoutConstraint.activate([
            mainButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            mainButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(textureButtonTapped(recognizer:)))
        mainButton.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the rounded white background for the selector
    private func setUpSelectorBackground() {
        selectorBackground.accessibilityIdentifier = "Texture Selector Background"
        selectorBackground.backgroundColor = .white
        selectorBackground.add(into: self)
        
        selectorBackground.alpha = 0
    }
    
    /// Sets up the stack view that holds the texture options
    private func setUpOptionContainer() {
        optionContainer.translatesAutoresizingMaskIntoConstraints = false
        optionContainer.axis = .vertical
        optionContainer.distribution = .equalSpacing
        optionContainer.alignment = .center
        selectorBackground.addSubview(optionContainer)
        
        NSLayoutConstraint.activate([
            optionContainer.leadingAnchor.constraint(equalTo: selectorBackground.leadingAnchor),
            optionContainer.trailingAnchor.constraint(equalTo: selectorBackground.trailingAnchor),
            optionContainer.topAnchor.constraint(equalTo: selectorBackground.topAnchor, constant: TextureSelectorViewConstants.selectorPadding),
            optionContainer.bottomAnchor.constraint(equalTo: selectorBackground.bottomAnchor, constant: -TextureSelectorViewConstants.selectorPadding),
        ])
    }
    
    /// Adds the texture options to the stack view
    private func setUpOptions() {
        sharpieButton.setBackgroundImage(KanvasCameraImages.sharpieImage, for: .normal)
        pencilButton.setBackgroundImage(KanvasCameraImages.pencilImage, for: .normal)
        markerButton.setBackgroundImage(KanvasCameraImages.markerImage, for: .normal)
        
        let sharpieButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharpieButtonTapped(recognizer:)))
        let pencilButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(pencilButtonTapped(recognizer:)))
        let markerButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(markerButtonTapped(recognizer:)))
        
        sharpieButton.addGestureRecognizer(sharpieButtonRecognizer)
        pencilButton.addGestureRecognizer(pencilButtonRecognizer)
        markerButton.addGestureRecognizer(markerButtonRecognizer)
        
        optionContainer.addArrangedSubview(sharpieButton)
        optionContainer.addArrangedSubview(pencilButton)
        optionContainer.addArrangedSubview(markerButton)
    }
    
    
    // MARK: - Gesture Recognizers
    
    @objc func textureButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapTextureButton()
    }
    
    @objc func sharpieButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapSharpieButton()
    }
    
    @objc func pencilButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapPencilButton()
    }
    
    @objc func markerButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapMarkerButton()
    }

    
    // MARK: - Public interface
    
    /// changes the image inside the texture button
    ///
    /// - Parameter image: the new image for the icon
    func changeMainButtonIcon(image: UIImage?) {
        UIView.animate(withDuration: TextureSelectorViewConstants.animationDuration) {
            self.mainButton.image = image
        }
    }
    
    /// shows or hides the texture selector
    ///
    /// - Parameter show: true to show, false to hide
    func showSelectorBackground(_ show: Bool) {
        UIView.animate(withDuration: TextureSelectorViewConstants.animationDuration) {
            self.selectorBackground.alpha = show ? 1 : 0
        }
    }
}
