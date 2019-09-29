//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Special text view for editing
final class StylableTextView: UITextView {
    
    override var contentSize: CGSize {
        didSet {
            centerContentVertically()
        }
    }
    
    override var frame: CGRect {
        didSet {
            centerContentVertically()
        }
    }
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    private func setUpView() {
        backgroundColor = .clear
        tintColor = .white
        showsVerticalScrollIndicator = false
        autocorrectionType = .no
    }
    
    // MARK: - Private utilities
    
    private func centerContentVertically() {
        var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2
        topCorrection = max(0, topCorrection)
        contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
    }
}
