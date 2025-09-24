//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for confirming the text tools
protocol EditorTextControllerDelegate: AnyObject {
    
    /// Called after the confirm button is tapped
    ///
    /// - Parameter textView: confirmed text view 
    /// - Parameter transformations: position, scaling and rotation angle for the view
    /// - Parameter location: location of the text view before transformations
    /// - Parameter size: text view size
    func didConfirmText(textView: StylableTextView, transformations: ViewTransformations, location: CGPoint, size: CGSize)
    
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
    
    /// Called when the color selector appears
    func didStartColorSelection()
    
    /// Called when the color selector starts its movement
    func didStartMovingColorSelector()
    
    /// Called when the color selector is released
    func didEndColorSelection()

    /// Called when the font is changes
    func didChange(font: UIFont)

    /// Called when the text alighment is changed
    func didChange(alignment: NSTextAlignment)

    /// Called when the text highlight is changed
    ///
    /// - Parameter highlight: is the text highlighted?
    func didChange(highlight: Bool)

    func didChange(color: Bool)
}

/// Constants for EditorTextController
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let fonts: [UIFont?] = KanvasFonts.shared.editorFonts
    static let alignments: [NSTextAlignment] = [.left, .center, .right]
}

/// A view controller that contains the text tools menu
final class EditorTextController: UIViewController, EditorTextViewDelegate, ColorCollectionControllerDelegate, ColorPickerControllerDelegate, ColorSelectorControllerDelegate {
    
    weak var delegate: EditorTextControllerDelegate?
    
    private var textTransformations: ViewTransformations

    private var alignments: [NSTextAlignment]
    private var fonts: [UIFont?]
    private var highlight: Bool?
        
    private lazy var textView: EditorTextView = {
        let textView = EditorTextView(settings: settings.textViewSettings)
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
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return textView.confirmButtonLocation
    }

    struct Settings {
        let textViewSettings: EditorTextView.Settings
    }

    private let settings: Settings
    
    // MARK: - Initializers
    
    init(settings inSettings: Settings) {
        textTransformations = ViewTransformations()
        fonts = Constants.fonts
        alignments = Constants.alignments
        settings = inSettings
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
        highlight = options.highlightColor?.isVisible()
        textView.eyeDropperColor = highlight == true ? options.highlightColor : options.color
    }
    
    // MARK: - EditorTextViewDelegate
    
    func didTapConfirmButton() {
        didConfirmText()
    }
    
    func didTapTextViewBackground() {
        didConfirmText()
    }
    
    func didTapAlignmentSelector() {
        alignments.rotateLeft()
        if let newAlignment = alignments.first {
            textView.alignment = newAlignment
            delegate?.didChange(alignment: newAlignment)
        }
    }
    
    func didTapFontSelector() {
        fonts.rotateLeft()
        if let newFont = fonts.first ?? nil, let currentFont = textView.font {
            textView.font = newFont.withSize(currentFont.pointSize)
            delegate?.didChange(font: newFont)
        }
    }
    
    func didTapHighlightSelector() {
        swapColors()
        delegate?.didChange(highlight: highlight ?? false)
    }
    
    func didTapEyeDropper() {
        colorSelectorController.circleInitialLocation = textView.colorSelectorOrigin
        colorSelectorController.resetLocation()
        colorSelectorController.resetColor()
        
        textView.closeKeyboard()
        colorSelectorController.show(true)
    }
    
    private func didConfirmText() {
        let newTextView = StylableTextView()
        newTextView.isUserInteractionEnabled = false
        newTextView.options = textView.options
        
        delegate?.didConfirmText(textView: newTextView, transformations: textTransformations, location: textView.location, size: textView.textSize)
    }
    
    // MARK: - ColorCollectionControllerDelegate
    
    func didSelectColor(_ color: UIColor) {
        setColor(color)
    }
    
    // MARK: - ColorPickerControllerDelegate
    
    func didSelectColor(_ color: UIColor, definitive: Bool) {
        setColor(color)
        
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
    
    func didShowCircle() {
        delegate?.didStartColorSelection()
    }
    
    func didStartMovingCircle() {
        delegate?.didStartMovingColorSelector()
    }
    
    func didEndMovingCircle(color: UIColor) {
        setColor(color)
        addColorsForCarousel(colors: [color])
        
        textView.openKeyboard()
        delegate?.didEndColorSelection()
    }
    
    // MARK: - Keyboard
    
    // This method is called inside the keyboard animation,
    // so any UI change made here will be animated.
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue

            let bottom = CGPoint(x: view.frame.minX, y: view.frame.maxY)
            let difference = keyboardRectangle.maxY - view.convert(bottom, to: nil).y

            let heightDiff = keyboardRectangle.height - difference
            textView.moveToolsUp(distance: heightDiff)
        }
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        delegate?.didMoveToolsUp()
    }
    
    // This method is called inside the keyboard animation,
    // so any UI change made here will be animated.
    @objc func keyboardWillHide(notification: NSNotification) {
        if isHiding == false && textView.alpha != 0 {
            didConfirmText()
        }
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
                  options: TextOptions = TextOptions(font: Constants.fonts.first ?? nil),
                  transformations: ViewTransformations = ViewTransformations()) {
        if visible {
            show(options: options, transformations: transformations)
        }
        else {
            hide()
        }
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        textView.showConfirmButton(show)
    }
    
    // MARK: - Show & Hide
    
    /// Makes the view appear
    ///
    /// - Parameter transformations: transformations for the view
    /// - Parameter options: text style options
    private func show(options: TextOptions = TextOptions(font: Constants.fonts.first ?? nil),
                      transformations: ViewTransformations = ViewTransformations()) {
        prepareForText(options, transformations)
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.textView.alpha = 1
        }, completion: { _ in
            self.textView.startWriting()
        })
    }

    /// A flag to indicate whether we're in the process of hiding. This is used in `keyboardWillHide` to determine whether to confirm the text.
    private var isHiding = false
    
    /// Makes the view disappear
    private func hide() {
        textView.endWriting()
        isHiding = true
        UIView.animate(withDuration: Constants.animationDuration) {
            self.textView.alpha = 0
            self.isHiding = false
        }
    }
    
    // MARK: - Private utilities
    
    /// Sets the new color as the text color or the highlight color depending on the current state
    ///
    /// - Parameter color: the new color to be set
    private func setColor(_ color: UIColor?) {
        textView.eyeDropperColor = color
        if highlight == true {
            textView.highlightColor = color
            textView.textColor = color?.matchingColor()
        }
        else {
            textView.textColor = color
        }
        delegate?.didChange(color: true)
    }
    
    /// Swaps the colors of the text and the background
    private func swapColors() {
        highlight?.toggle()
        if highlight == true {
            guard let color = textView.textColor else { return }
            textView.highlightColor = color
            textView.textColor = color.matchingColor()
        }
        else {
            guard let color = textView.highlightColor else { return }
            textView.highlightColor = .clear
            textView.textColor = color
        }
    }
}
