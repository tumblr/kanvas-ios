//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for MainTextView
private struct Constants {
    static let fontSizes: [CGFloat] = [10, 12, 14, 16, 18, 21, 26, 32, 48, 64]
}

/// Protocol for the text view inside text tools
protocol MainTextViewDelegate: AnyObject {
    
    /// Called when the background was touched
    func didTapBackground()
}

/// Main text view for editing
final class MainTextView: StylableTextView {
    
    weak var textViewDelegate: MainTextViewDelegate?
    
    override var contentSize: CGSize {
        didSet {
            centerContentVertically()
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        resizeFont()
        centerContentVertically()
    }

    var resizesFont: Bool = true
    
    override init() {
        super.init()
        setUpView()
        setUpGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(from:) has not been implemented")
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    private func setUpView() {
        backgroundColor = .clear
        tintColor = .white
        showsVerticalScrollIndicator = false
        autocorrectionType = .no
        textDragInteraction?.isEnabled = false
    }
    
    private func setUpGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(textViewTapped(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Private utilities
    
    private func centerContentVertically() {
        var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2
        topCorrection = max(0, topCorrection)
        contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func textViewTapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)
        if !textInputView.frame.contains(point) {
            textViewDelegate?.didTapBackground()
        }
    }
    
    // MARK: - Text scaling
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        resizeFont()
    }
    
    func resizeFont() {
        guard resizesFont && !bounds.size.equalTo(.zero), let currentFont = font else { return }
        var bestFont = currentFont.withSize(Constants.fontSizes[0])
        
        for fontSize in Constants.fontSizes {
            font = currentFont.withSize(fontSize)
            if sizeThatFits(CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))).height < frame.size.height {
                bestFont = currentFont.withSize(fontSize)
            }
        }
        
        font = bestFont
    }
    
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        // Intentionally left empty.
        // This prevents the text from being pulled up when changing the font size.
    }
}
