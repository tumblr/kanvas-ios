//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for the label.
private struct Constants {
    static let height: CGFloat = 24
    static let font: UIFont = .boldSystemFont(ofSize: 16)
    static let inset: CGFloat = 12
}

/// Custom label with horizontal inset and rounded corners.
final class StyleMenuRoundedLabel: UILabel {
    
    static let height: CGFloat = Constants.height
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        font = Constants.font
        layer.cornerRadius = Constants.height / 2
        layer.masksToBounds = true
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: Constants.inset, bottom: 0, right: Constants.inset)
        super.drawText(in: rect.inset(by: insets))
    }
        
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + Constants.inset * 2, height: size.height)
    }
}
