//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol TextureSelectorViewDelegate: AnyObject {
    /// Called when the main button is selected
    func didTapTextureButton()
    
    /// Called when the pencil option is selected
    func didTapPencilButton()
    
    /// Called when the sharpie option is selected
    func didTapSharpieButton()
    
    /// Called when the marker option is selected
    func didTapMarkerButton()
}

/// Constants for texture selector view
private struct Constants {
    static let shortAnimationDuration: TimeInterval = 0.01
    
    static let stackViewInset: CGFloat = -10
    static let selectorHeight: CGFloat = 128
    static let selectorWidth: CGFloat = 34
    static let selectorPadding: CGFloat = 7
}

/// View for TextureSelectorController
final class TextureSelectorView: IgnoreTouchesView {
    
    static let selectorHeight: CGFloat = Constants.selectorHeight
    static let selectorWidth: CGFloat = Constants.selectorWidth
    
    weak var delegate: TextureSelectorViewDelegate?
    
    private let mainButton: CircularImageView
    private let selectorBackground: SliderView
    private let optionContainer: UIStackView
    private let sharpieButton: UIButton
    private let pencilButton: UIButton
    private let markerButton: UIButton
    
    
    init() {
        mainButton = CircularImageView()
        selectorBackground = SliderView()
        optionContainer = ExtendedStackView(inset: Constants.stackViewInset)
        sharpieButton = ExtendedButton(inset: Constants.stackViewInset)
        pencilButton = ExtendedButton(inset: Constants.stackViewInset)
        markerButton = ExtendedButton(inset: Constants.stackViewInset)
        
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
        setUpSelectorBackground()
        setUpOptionContainer()
        setUpOptions()
        setUpMainButton()
    }
    
    /// Sets up the button that opens the selector
    private func setUpMainButton() {
        mainButton.contentMode = .center
        mainButton.image = KanvasImages.pencilImage
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
        selectorBackground.add(into: self)
        selectorBackground.alpha = 0
    }
    
    /// Sets up the stack view that holds the options
    private func setUpOptionContainer() {
        optionContainer.translatesAutoresizingMaskIntoConstraints = false
        optionContainer.axis = .vertical
        optionContainer.distribution = .equalSpacing
        optionContainer.alignment = .center
        selectorBackground.addSubview(optionContainer)
        
        NSLayoutConstraint.activate([
            optionContainer.leadingAnchor.constraint(equalTo: selectorBackground.leadingAnchor),
            optionContainer.trailingAnchor.constraint(equalTo: selectorBackground.trailingAnchor),
            optionContainer.topAnchor.constraint(equalTo: selectorBackground.topAnchor, constant: Constants.selectorPadding),
            optionContainer.bottomAnchor.constraint(equalTo: selectorBackground.bottomAnchor, constant: -Constants.selectorPadding),
        ])
    }
    
    /// Adds the options to the stack view
    private func setUpOptions() {
        sharpieButton.setBackgroundImage(KanvasEditorDesign.shared.drawingViewSharpieImage, for: .normal)
        pencilButton.setBackgroundImage(KanvasEditorDesign.shared.drawingViewPencilImage, for: .normal)
        markerButton.setBackgroundImage(KanvasEditorDesign.shared.drawingViewMarkerImage, for: .normal)
        
        let sharpieButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharpieButtonTapped(recognizer:)))
        let pencilButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(pencilButtonTapped(recognizer:)))
        let markerButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(markerButtonTapped(recognizer:)))
        
        sharpieButton.addGestureRecognizer(sharpieButtonRecognizer)
        pencilButton.addGestureRecognizer(pencilButtonRecognizer)
        markerButton.addGestureRecognizer(markerButtonRecognizer)
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
    
    // MARK: - Private utilities
    
    private func showOptionContainer(_ show: Bool) {
        UIView.animate(withDuration: Constants.shortAnimationDuration) {
            self.optionContainer.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - Public interface
    
    /// changes the image inside the main button
    ///
    /// - Parameter image: the new image for the icon
    func changeMainButtonIcon(image: UIImage?) {
        mainButton.image = image
    }
    
    /// shows or hides the selector
    ///
    /// - Parameter show: true to show, false to hide
    func showSelectorBackground(_ show: Bool) {
        if show {
            selectorBackground.alpha = 1
            
            selectorBackground.open(completion: {
                self.mainButton.alpha = 0
                self.showOptionContainer(true)
            })
        }
        else {
            mainButton.alpha = 1
            self.showOptionContainer(false)
            
            selectorBackground.close(completion: {
                self.selectorBackground.alpha = 0
            })
        }
    }
    
    func arrangeOptions(selectedOption: KanvasBrushType) {
        let buttons: [UIButton]
        switch selectedOption {
        case .pencil:
            buttons = [sharpieButton, markerButton, pencilButton]
        case .marker:
            buttons = [sharpieButton, pencilButton, markerButton]
        case .sharpie:
            buttons = [pencilButton, markerButton, sharpieButton]
        }
        
        buttons.forEach { button in
            optionContainer.addArrangedSubview(button)
        }
    }
}
