//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Circular UIImageView with a white border
final class CircularImageView: UIImageView {
    
    static let size: CGFloat = 34
    static let padding: CGFloat = 8
    
    init() {
        super.init(image: UIImage())
        setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.masksToBounds = true
        layer.cornerRadius = CircularImageView.size / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
}
