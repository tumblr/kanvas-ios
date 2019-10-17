//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

class CustomizableTextView: UITextView, UITextViewDelegate {
    
    private var backgroundViews: [UIView]
    
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
    
    init() {
        backgroundViews = []
        super.init(frame: .zero, textContainer: nil)
        delegate = self
    }
    
    init(frame: CGRect) {
        backgroundViews = []
        super.init(frame: frame, textContainer: nil)
        delegate = self
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        backgroundViews = []
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        backgroundViews = []
        super.init(coder: aDecoder)
        delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateHighlight()
    }
    
    func updateHighlight() {
        removeHighlights()
        let range = NSRange(location: 0, length: text.count)
        layoutManager.enumerateLineFragments(forGlyphRange: range, using: { _, usedRect, _, _, _ in
            let highlight = self.createHighlight(rect: usedRect)
            self.addSubview(highlight)
            self.sendSubviewToBack(highlight)
            self.backgroundViews.append(highlight)
        })
    }
    
    private func removeHighlights() {
        backgroundViews.forEach { view in
            view.removeFromSuperview()
        }
        
        backgroundViews.removeAll()
    }
    
    private func createHighlight(rect: CGRect) -> UIView {
        let fontRect = createFontRect(rect: rect)
        let view = UIView(frame: fontRect)
        view.backgroundColor = highlightColor
        return view
    }
    
    private func createFontRect(rect: CGRect) -> CGRect {
        guard let font = font else { return rect }
        let topMargin = rect.height - font.lineHeight
        
        return rect
    }
}


extension CustomizableTextView {
    
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
