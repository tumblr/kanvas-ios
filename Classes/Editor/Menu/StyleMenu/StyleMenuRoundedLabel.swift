//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let labelHeight: CGFloat = 24
    static let labelFont: UIFont = .boldSystemFont(ofSize: 16)
    static let labelInset: CGFloat = 12
}

/// Custom label with horizontal inset and rounded corners.
final class StyleMenuRoundedLabel: UILabel {
    
    static let height: CGFloat = Constants.labelHeight
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        font = Constants.labelFont
        layer.cornerRadius = Constants.labelHeight / 2
        layer.masksToBounds = true
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: Constants.labelInset, bottom: 0, right: Constants.labelInset)
        super.drawText(in: rect.inset(by: insets))
    }
        
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + Constants.labelInset * 2, height: size.height)
    }
}
