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

/// Color drop with white border
final class ColorDrop: UIImageView {
    
    static let defaultHeight: CGFloat = 55
    static let defaultWidth: CGFloat = 39
    
    private let innerDrop = UIImageView()
    
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
        image = KanvasCameraImages.dropImage?.withRenderingMode(.alwaysTemplate)
        tintColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        innerDrop.image = KanvasCameraImages.dropImage?.withRenderingMode(.alwaysTemplate)
        innerDrop.translatesAutoresizingMaskIntoConstraints = false
        innerDrop.clipsToBounds = true
        addSubview(innerDrop)
        
        NSLayoutConstraint.activate([
            innerDrop.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: Constants.topBorderWidth),
            innerDrop.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -Constants.bottomBorderWidth),
            innerDrop.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor, constant: Constants.horizontalBorderWidth),
            innerDrop.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor, constant: -Constants.horizontalBorderWidth),
        ])
    }
    
    // MARK: - Public interface
    
    func setColor(_ color: UIColor) {
        innerDrop.tintColor = color
    }
}
