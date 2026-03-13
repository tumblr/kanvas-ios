//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for color drop
private struct Constants {
    static let topBorderWidth: CGFloat = 2
    static let bottomBorderWidth: CGFloat = 4
    static let horizontalBorderWidth: CGFloat = 2.5
}

/// Drop-shaped view which can change its color.
/// It also has a white border.
final class ColorDrop: UIImageView {
    
    static let defaultHeight: CGFloat = 55
    static let defaultWidth: CGFloat = 39
    
    private let innerDrop = UIImageView()
    
    var innerColor: UIColor {
        get {
            return innerDrop.tintColor
        }
        set {
            innerDrop.tintColor = newValue
        }
    }
    
    init() {
        super.init(image: nil)
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
        image = KanvasImages.dropImage?.withRenderingMode(.alwaysTemplate)
        tintColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        innerDrop.image = KanvasImages.dropImage?.withRenderingMode(.alwaysTemplate)
        innerDrop.translatesAutoresizingMaskIntoConstraints = false
        innerDrop.clipsToBounds = true
        addSubview(innerDrop)
        
        NSLayoutConstraint.activate([
            innerDrop.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topBorderWidth),
            innerDrop.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomBorderWidth),
            innerDrop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalBorderWidth),
            innerDrop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalBorderWidth),
        ])
    }
}
