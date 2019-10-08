//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for confirming the text tools
protocol EditorTextControllerDelegate: class {
    
    /// Called after the confirm button is tapped
    ///
    /// - Parameter options: text style options
    /// - Parameter transformations: position, scaling and rotation angle for the view
    /// - Parameter location: location of the text view before transformations
    /// - Parameter size: text view size
    func didConfirmText(options: TextOptions, transformations: ViewTransformations, location: CGPoint, size: CGSize)
    
    /// Called when the keyboard moves up
    func didMoveToolsUp()
    
    /// Called to ask if color selector tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func editorShouldShowColorSelectorTooltip() -> Bool
    
    /// Called after the color selector tooltip is dismissed
    func didDismissColorSelectorTooltip()
    
    /// Called when the color selector is panned
    ///
    /// - Parameter point: location to take the color from
    /// - Returns: Color from image
    func getColor(from point: CGPoint) -> UIColor
    
    /// Called when the color selector is pressed
    func didStartColorSelection()
    
    /// Called when the color selector is released
    func didEndColorSelection()
}

/// Constants for EditorTextController
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let fonts: [UIFont?] = [.fairwater(fontSize: 48), .favoritTumblr85(fontSize: 48)]
    static let alignments: [NSTextAlignment] = [.left, .center, .right]
}

/// A view controller that contains the text tools menu
final class EditorTextController: UIViewController, EditorTextViewDelegate, ColorCollectionControllerDelegate, ColorPickerControllerDelegate, ColorSelectorControllerDelegate {

    weak var delegate: EditorTextControllerDelegate?
    
    private var textTransformations: ViewTransformations

    private var fonts: [UIFont?]
    private var alignments: [NSTextAlignment]
    
    private lazy var textView: EditorTextView = {
        let textView = EditorTextView()
        textView.delegate = self
        return textView
    }()
    
    private lazy var colorCollectionController: ColorCollectionController = {
        let controller = ColorCollectionController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var colorPickerController: ColorPickerController = {
        let controller = ColorPickerController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var colorSelectorController: ColorSelectorController = {
        let controller = ColorSelectorController()
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Initializers
    
    init() {
        textTransformations = ViewTransformations()
        fonts = Constants.fonts
        alignments = Constants.alignments
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    override func loadView() {
        view = textView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setUpView()
        load(childViewController: colorCollectionController, into: textView.colorCollection)
        load(childViewController: colorPickerController, into: textView.colorGradient)
        load(childViewController: colorSelectorController, into: textView.colorSelector)
    }
    
    private func setUpView() {
        textView.alpha = 0
    }
    
    private func prepareForText(_ options: TextOptions, _ transformations: ViewTransformations) {
        textTransformations = transformations
        textView.options = options
        
        fonts.rotate(to: options.font)
        alignments.rotate(to: options.alignment)
    }
    
    // MARK: - EditorTextViewDelegate
    
    func didTapConfirmButton() {
        didConfirmText()
    }
    
    func didTapTextViewBackground() {
        didConfirmText()
    }
    
    func didTapFontSelector() {
        fonts.rotateLeft()
        if let newFont = fonts.first {
            textView.font = newFont
        }
    }
    
    func didTapAlignmentSelector() {
        alignments.rotateLeft()
        if let newAlignment = alignments.first {
            textView.alignment = newAlignment
        }
    }
    
    func didTapEyeDropper() {
        colorSelectorController.circleInitialLocation = textView.colorSelectorOrigin
        colorSelectorController.show(true)
    }
    
    private func didConfirmText() {
        delegate?.didConfirmText(options: textView.options, transformations: textTransformations, location: textView.location, size: textView.textSize)
    }
    
    // MARK: - ColorCollectionControllerDelegate
    
    func didSelectColor(_ color: UIColor) {
        textView.textColor = color
    }
    
    // MARK: - ColorPickerControllerDelegate
    
    func didSelectColor(_ color: UIColor, definitive: Bool) {
        textView.textColor = color
        
        if definitive {
            addColorsForCarousel(colors: [color])
        }
    }
    
    // MARK: - ColorSelectorControllerDelegate
    
    func shouldShowTooltip() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowColorSelectorTooltip()
    }
    
    func didDismissTooltip() {
        delegate?.didDismissColorSelectorTooltip()
    }
    
    func getColor(at point: CGPoint) -> UIColor {
        guard let delegate = delegate else { return .black }
        return delegate.getColor(from: point)
    }
    
    func didStartColorSelection() {
        delegate?.didStartColorSelection()
    }
    
    func didEndColorSelection(color: UIColor) {
        delegate?.didEndColorSelection()
    }
    
    // MARK: - Keyboard
    
    // This method is called inside the keyboard animation,
    // so any UI change made here will be animated.
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            textView.moveToolsUp(distance: keyboardRectangle.height)
        }
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        delegate?.didMoveToolsUp()
    }
    
    // This method is called inside the keyboard animation,
    // so any UI change made here will be animated.
    @objc func keyboardWillHide(notification: NSNotification) {
        textView.moveToolsDown()
    }
    
    // MARK: - Public interface
    
    
    /// Adds colors to the color carousel
    ///
    /// - Parameter colors: list of colors to be added
    func addColorsForCarousel(colors: [UIColor]) {
        colorCollectionController.addColors(colors)
    }
    
    /// shows or hides the text tools menu
    ///
    /// - Parameter visible: true to show, false to hide
    /// - Parameter transformations: transformations for the view
    /// - Parameter options: text style options
    func showView(_ visible: Bool,
                  options: TextOptions = TextOptions(),
                  transformations: ViewTransformations = ViewTransformations()) {
        if visible {
            show(options: options, transformations: transformations)
        }
        else {
            hide()
        }
    }
    
    // MARK: - Show & Hide
    
    /// Makes the view appear
    ///
    /// - Parameter transformations: transformations for the view
    /// - Parameter options: text style options
    private func show(options: TextOptions = TextOptions(),
                      transformations: ViewTransformations = ViewTransformations()) {
        prepareForText(options, transformations)
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.textView.alpha = 1
        }, completion: { _ in
            self.textView.startWriting()
        })
    }
    
    
    /// Makes the view disappear
    private func hide() {
        textView.endWriting()
        UIView.animate(withDuration: Constants.animationDuration) {
            self.textView.alpha = 0
        }
    }
}
