//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct FiltersViewConstants {
    static let iconSize: CGFloat = 32
}

/// View that handles the filter settings
final class FiltersView: IgnoreTouchesView {
    
    static let height: CGFloat = 48
    
    private let filterIcon: UIImageView
    
    override init(frame: CGRect) {
        filterIcon = UIImageView()
        super.init(frame: .zero)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(filterIcon)

        filterIcon.image = KanvasCameraImages.filterImage
        filterIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterIcon.heightAnchor.constraint(equalToConstant: FiltersViewConstants.iconSize),
            filterIcon.widthAnchor.constraint(equalToConstant: FiltersViewConstants.iconSize),
            filterIcon.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            filterIcon.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor)
        ])
    }
}
