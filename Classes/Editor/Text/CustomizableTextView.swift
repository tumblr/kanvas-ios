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
    
    private func updateHighlight() {
        removeHighlights()
        let range = NSRange(location: 0, length: text.count)
        layoutManager.enumerateLineFragments(forGlyphRange: range, using: { _, usedRect, _, _, _ in
            print("L - lines \(usedRect)")
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
        let view = UIView(frame: rect)
        view.backgroundColor = highlightColor
        return view
    }
}
