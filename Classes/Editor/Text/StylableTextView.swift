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
class StylableTextView: UITextView, UITextViewDelegate {
    
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
    
    // MARK: - Initializers
    
    init() {
        highlightViews = []
        super.init(frame: .zero, textContainer: nil)
        delegate = self
    }
    
    init(frame: CGRect) {
        highlightViews = []
        super.init(frame: frame, textContainer: nil)
        delegate = self
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        highlightViews = []
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        highlightViews = []
        super.init(coder: aDecoder)
        delegate = self
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
        
        switch font {
        case UIFont.favoritTumblr85(fontSize: font.pointSize):
            topMargin = 8.0
            leftMargin = 5.7
            extraVerticalPadding = 0.125 * font.pointSize
            extraHorizontalPadding = 0
        default:
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
