//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the media drawer view
protocol MediaDrawerViewDelegate: class {
    
}

/// Constants for MediaDrawerView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let backgroundColor: UIColor = .white
}

/// A UIView for the media drawer view
final class MediaDrawerView: UIView {
    
    weak var delegate: MediaDrawerViewDelegate?
    
    let childContainer: UIView
    
    // MARK: - Initializers
    
    init() {
        childContainer = UIView()
        super.init(frame: .zero)
        backgroundColor = Constants.backgroundColor
        setupView()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setupChildContainer()
    }
    
    private func setupChildContainer() {
        addSubview(childContainer)
        childContainer.accessibilityLabel = "Child Container"
        childContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            childContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            childContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            childContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            childContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
