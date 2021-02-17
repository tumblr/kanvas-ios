//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for StylableTextView
private struct Constants {
    static let highlightCornerRadius: CGFloat = 3.0
}

/// TextView that can be customized with TextOptions
@objc class StylableTextView: UITextView, UITextViewDelegate, MovableViewInnerElement, NSSecureCoding {

    static var supportsSecureCoding = true
    
    // Color rectangles behind the text
    private var highlightViews: [UIView]
    
    var highlightColor: UIColor? {
        didSet {
            updateHighlight()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            updateHighlight()
        }
    }
    
    override var font: UIFont? {
        didSet {
            updateHighlight()
        }
    }
    
    override var contentScaleFactor: CGFloat {
        willSet {
            setScaleFactor(newValue)
        }
    }

    var viewSize: CGSize = .zero

    var viewCenter: CGPoint = .zero

    // MARK: - Initializers
    
    init() {
        highlightViews = []
        super.init(frame: .zero, textContainer: nil)
        delegate = self
        backgroundColor = .clear
    }
    
    init(frame: CGRect) {
        highlightViews = []
        super.init(frame: frame, textContainer: nil)
        delegate = self
        backgroundColor = .clear
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        highlightViews = []
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        highlightViews = []

        let size = coder.decodeCGSize(forKey: CodingKeys.size.rawValue)

        super.init(frame: CGRect(origin: .zero, size: size), textContainer: nil)
        delegate = self
        backgroundColor = .clear

        textAlignment = NSTextAlignment(rawValue: coder.decodeInteger(forKey: CodingKeys.textAlignment.rawValue)) ?? .left
        contentScaleFactor = CGFloat(coder.decodeFloat(forKey: CodingKeys.contentScaleFactor.rawValue))
        text = String(coder.decodeObject(of: NSString.self, forKey: CodingKeys.text.rawValue) ?? "")

        viewSize = coder.decodeCGSize(forKey: CodingKeys.size.rawValue)
        viewCenter = coder.decodeCGPoint(forKey: CodingKeys.center.rawValue)
        textColor = coder.decodeObject(of: UIColor.self, forKey: CodingKeys.textColor.rawValue)
        highlightColor = coder.decodeObject(of: UIColor.self, forKey: CodingKeys.highlightColor.rawValue)

        let fontName = String(coder.decodeObject(of: NSString.self, forKey: FontKeys.name.rawValue) ?? "")
        let fontSize = CGFloat(coder.decodeFloat(forKey: FontKeys.fontSize.rawValue))
        font = UIFont(name: fontName, size: fontSize)
    }

    private enum CodingKeys: String {
        case textAlignment
        case contentScaleFactor
        case font
        case text
        case size
        case center
        case textColor
        case highlightColor
    }

    private enum FontKeys: String {
        case name
        case fontSize
    }

    override func encode(with coder: NSCoder) {

        coder.encode(textAlignment.rawValue, forKey: CodingKeys.textAlignment.rawValue)
        coder.encode(Float(contentScaleFactor), forKey: CodingKeys.contentScaleFactor.rawValue)

        coder.encode(text, forKey: CodingKeys.text.rawValue)
        coder.encode(viewSize, forKey: CodingKeys.size.rawValue)
        coder.encode(viewCenter, forKey: CodingKeys.center.rawValue)
        coder.encode(textColor, forKey: CodingKeys.textColor.rawValue)
        coder.encode(highlightColor, forKey: CodingKeys.highlightColor.rawValue)

        if let font = font {
            coder.encode(font.fontName, forKey: FontKeys.name.rawValue)
            coder.encode(Float(font.pointSize), forKey: FontKeys.fontSize.rawValue)
        }
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHighlight()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateHighlight()
    }
    
    /// Redraws the highlight rectangles
    func updateHighlight() {
        removeHighlight()
        let range = NSRange(location: 0, length: text.count)
        
        layoutManager.enumerateLineFragments(forGlyphRange: range, using: { _, usedRect, textContainer, glyphRange, _ in
            guard !self.isEmptyLine(text: self.text, utf16LineRange: glyphRange)  else { return }
            let finalRect: CGRect
            
            if self.endsInBlankSpace(text: self.text, utf16LineRange: glyphRange) {
                let lastSpaceRange = NSRange(location: glyphRange.upperBound - 1, length: 1)
                let spaceRect = self.layoutManager.boundingRect(forGlyphRange: lastSpaceRange, in: textContainer)
                finalRect = CGRect(x: usedRect.origin.x, y: usedRect.origin.y,
                                   width: usedRect.width - spaceRect.width, height: usedRect.height)
            }
            else {
                finalRect = usedRect
            }
            
            let highlightView = self.createHighlightView(rect: finalRect)
            self.addSubview(highlightView)
            self.sendSubviewToBack(highlightView)
            self.highlightViews.append(highlightView)
        })
    }
    
    /// Removes the hightlight rectangles
    private func removeHighlight() {
        highlightViews.forEach { view in
            view.removeFromSuperview()
        }
        
        highlightViews.removeAll()
    }
    
    /// Creates a highlight area for a line of text
    ///
    /// - Parameter rect: the rect of the line
    private func createHighlightView(rect: CGRect) -> UIView {
        let fontRect = createFontRect(rect: rect)
        let view = UIView(frame: fontRect)
        view.backgroundColor = highlightColor
        view.layer.cornerRadius = Constants.highlightCornerRadius
        return view
    }
    
    /// Creates a highlight rectangle for a font
    ///
    /// - Parameter rect: the rect of the line
    private func createFontRect(rect: CGRect) -> CGRect {
        guard let font = font else { return rect }
        let capHeight = font.capHeight
        let lineHeight = font.lineHeight
        let topMargin: CGFloat
        let leftMargin: CGFloat
        let extraVerticalPadding: CGFloat
        let extraHorizontalPadding: CGFloat
        
        if let padding = KanvasFonts.shared.paddingAdjustment?(font) {
            topMargin = padding.topMargin
            leftMargin = padding.leftMargin
            extraVerticalPadding = padding.extraVerticalPadding
            extraHorizontalPadding = padding.extraHorizontalPadding
        }
        else {
            topMargin = 6.0
            leftMargin = 6.0
            extraHorizontalPadding = 0
            extraVerticalPadding = 0
        }
        
        return CGRect(x: rect.origin.x + leftMargin - extraHorizontalPadding,
                      y: rect.origin.y + topMargin - extraVerticalPadding + (lineHeight - capHeight) / 2.0,
                      width: rect.width + extraHorizontalPadding * 2,
                      height: capHeight + extraVerticalPadding * 2)
    }
    
    /// Checks if a line of text is empty
    ///
    /// - Parameter text: complete string of text
    /// - Parameter utf16LineRange: the range of utf16 indexes that represents the line
    private func isEmptyLine(text: String, utf16LineRange: NSRange) -> Bool {
        return text.copy(withUTF16Range: utf16LineRange) == "\n"
    }
    
    /// Checks if a line of text ends in a space
    ///
    /// - Parameter text: complete string of text
    /// - Parameter utf16LineRange: the range of utf16 indexes that represents the line
    private func endsInBlankSpace(text: String, utf16LineRange: NSRange) -> Bool {
        return text.copy(withUTF16Range: utf16LineRange)?.last == " "
    }
    
    
    // MARK: - Scale factor
    
    /// Sets a new scale factor to update the quality of the text. This value represents how content in the view is mapped
    /// from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
    /// For example, if the scale factor is 2.0, 2 pixels will be used to draw each point of the frame.
    ///
    /// - Parameter scaleFactor: the new scale factor. The value will be internally multiplied by the native scale of the device.
    /// Values must be higher than 1.0.
    func setScaleFactor(_ scaleFactor: CGFloat) {
        guard scaleFactor >= 1.0 else { return }
        let scaleFactorForDevice = scaleFactor * UIScreen.main.nativeScale
        for subview in textInputView.subviews {
            subview.contentScaleFactor = scaleFactorForDevice
        }
    }
    
    // MARK: - MovableViewInnerElement
    
    /// Checks if the view was touched on its letters or on the space between lines
    ///
    /// - Parameter point: location where the view was touched
    /// - Returns: true if the touch was inside, false if not
    func hitInsideShape(point: CGPoint) -> Bool {
        var hitInside = false
        
        for (i, view) in highlightViews.enumerated() {
            let insideView = view.frame.contains(point)
            
            let inNextSpace: Bool
            if let nextView = highlightViews.object(at: i+1) {
                let spaceBetweenLines = [CGPoint(x: view.frame.minX, y: view.frame.maxY),
                                         CGPoint(x: view.frame.maxX, y: view.frame.maxY),
                                         CGPoint(x: nextView.frame.maxX, y: nextView.frame.minY),
                                         CGPoint(x: nextView.frame.minX, y: nextView.frame.minY),]
                
                inNextSpace = contains(polygon: spaceBetweenLines, point: point)
            }
            else {
                inNextSpace = false
            }
            
            hitInside = hitInside || insideView || inNextSpace
        }
        
        return hitInside
    }
    
    /// Checks if a polygon contains a specific point
    ///
    /// - Parameters:
    ///   - polygon: list of points to create the shape
    ///   - point: point to be tested
    private func contains(polygon: [CGPoint], point: CGPoint) -> Bool {
        guard polygon.count > 1 else { return false }

        let p = UIBezierPath()
        let firstPoint = polygon[0]

        p.move(to: firstPoint)

        for index in 1...polygon.count-1 {
            p.addLine(to: polygon[index])
        }

        p.close()

       return p.contains(point)
    }
}

// Extension for getting and setting the style options from a StylableTextView
extension StylableTextView {
    
    var options: TextOptions {
        get {
            return TextOptions(text: text,
                               font: font,
                               color: textColor,
                               highlightColor: highlightColor,
                               alignment: textAlignment,
                               textContainerInset: textContainerInset)
        }
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
            highlightColor = newValue.highlightColor
            textAlignment = newValue.alignment
            textContainerInset = newValue.textContainerInset
        }
    }
}
