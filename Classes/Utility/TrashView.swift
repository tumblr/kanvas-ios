//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for trash view
private struct Constants {
    static let animationDuration: TimeInterval = 0.5
    
    static let closedIconSize: CGFloat = 33
    static let openedIconSize: CGFloat = 38
    
    static let openedIconCenterYOffset: CGFloat = 2.5
}

/// View that shows an open or closed trash bin with a red circle as background
final class TrashView: IgnoreTouchesView {
    
    private let backgroundCircle: UIImageView
    private let openedTrash: UIImageView
    private let closedTrash: UIImageView
    
    init() {
        backgroundCircle = UIImageView()
        openedTrash = UIImageView()
        closedTrash = UIImageView()
        super.init(frame: .zero)
        
        setUpTrashViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpTrashViews() {
        setUpBackgroundCircle()
        setUpTrashOpened()
        setUpTrashClosed()
    }
    
    /// Sets up the red circle on the background
    private func setUpBackgroundCircle() {
        addSubview(backgroundCircle)
        backgroundCircle.accessibilityIdentifier = "Trash Background Circle"
        backgroundCircle.translatesAutoresizingMaskIntoConstraints = false
        backgroundCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        backgroundCircle.tintColor = .tumblrBrightRed
        
        backgroundCircle.contentMode = .scaleAspectFit
        backgroundCircle.clipsToBounds = true
        backgroundCircle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundCircle.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            backgroundCircle.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
            backgroundCircle.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            backgroundCircle.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor)
        ])
        
        backgroundCircle.alpha = 0
    }
    
    /// Sets up the opened trash bin icon
    private func setUpTrashOpened() {
        addSubview(openedTrash)
        openedTrash.accessibilityIdentifier = "Trash Opened Image"
        openedTrash.translatesAutoresizingMaskIntoConstraints = false
        openedTrash.contentMode = .scaleAspectFit
        openedTrash.clipsToBounds = true
        openedTrash.image = KanvasCameraImages.trashOpened
        
        NSLayoutConstraint.activate([
            openedTrash.heightAnchor.constraint(equalToConstant: Constants.openedIconSize),
            openedTrash.widthAnchor.constraint(equalToConstant: Constants.openedIconSize),
            openedTrash.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            openedTrash.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor, constant: -Constants.openedIconCenterYOffset)
        ])
        
        openedTrash.alpha = 0
    }
    
    /// Sets up the closed trash bin icon
    private func setUpTrashClosed() {
        addSubview(closedTrash)
        closedTrash.accessibilityIdentifier = "Trash Closed Image"
        closedTrash.translatesAutoresizingMaskIntoConstraints = false
        closedTrash.contentMode = .scaleAspectFit
        closedTrash.clipsToBounds = true
        closedTrash.image = KanvasCameraImages.trashClosed
        
        NSLayoutConstraint.activate([
            closedTrash.heightAnchor.constraint(equalToConstant: Constants.closedIconSize),
            closedTrash.widthAnchor.constraint(equalToConstant: Constants.closedIconSize),
            closedTrash.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            closedTrash.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor)
        ])
        
        closedTrash.alpha = 0
    }
    
    
    // MARK: - Public interface
    
    /// shows the opened trash icon with the background circle
    func open() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.backgroundCircle.alpha = 1
            self.openedTrash.alpha = 1
            self.closedTrash.alpha = 0
        }
    }
    
    /// shows closed trash icon without the background circle
    func close() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.backgroundCircle.alpha = 0
            self.openedTrash.alpha = 0
            self.closedTrash.alpha = 1
        }
    }
    
    /// hides the opened/closed trash icon and the background circle
    func hide() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.backgroundCircle.alpha = 0
            self.openedTrash.alpha = 0
            self.closedTrash.alpha = 0
        }
    }
}
