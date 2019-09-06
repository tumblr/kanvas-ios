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
    static let size: CGFloat = 98
    static let borderImageSize: CGFloat = 90
    static let closedIconSize: CGFloat = 33
    static let openedIconSize: CGFloat = 38
    static let borderWidth: CGFloat = 3.0
    static let openedIconCenterYOffset: CGFloat = 2.5
}

/// View that shows an open or closed trash bin with a red circle as background
final class TrashView: IgnoreTouchesView {
    
    static let size: CGFloat = Constants.size
    
    private let borderCircle: UIImageView
    private let backgroundCircle: UIImageView
    private let openedTrash: UIImageView
    private let closedTrash: UIImageView
    
    init() {
        borderCircle = UIImageView()
        backgroundCircle = UIImageView()
        openedTrash = UIImageView()
        closedTrash = UIImageView()
        super.init(frame: .zero)
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        setUpBorderCircle()
        setUpBackgroundCircle()
        setUpTrashOpened()
        setUpTrashClosed()
    }
    
    /// Sets up the white border of the circle
    private func setUpBorderCircle() {
        addSubview(borderCircle)
        borderCircle.accessibilityIdentifier = "Trash Border Circle"
        borderCircle.translatesAutoresizingMaskIntoConstraints = false
        
        borderCircle.layer.borderColor = UIColor.white.cgColor
        borderCircle.layer.borderWidth = Constants.borderWidth
        borderCircle.layer.cornerRadius = Constants.borderImageSize / 2.0
        
        borderCircle.contentMode = .scaleAspectFit
        borderCircle.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            borderCircle.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            borderCircle.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor),
            borderCircle.heightAnchor.constraint(equalToConstant: Constants.borderImageSize),
            borderCircle.widthAnchor.constraint(equalToConstant: Constants.borderImageSize)
        ])
        
        borderCircle.alpha = 0
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
        
        NSLayoutConstraint.activate([
            backgroundCircle.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            backgroundCircle.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor),
            backgroundCircle.heightAnchor.constraint(equalToConstant: Constants.size),
            backgroundCircle.widthAnchor.constraint(equalToConstant: Constants.size)
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
            self.borderCircle.alpha = 0
            self.backgroundCircle.alpha = 1
            self.openedTrash.alpha = 1
            self.closedTrash.alpha = 0
        }
    }
    
    /// shows closed trash icon without the background circle
    func close() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.borderCircle.alpha = 1
            self.backgroundCircle.alpha = 0
            self.openedTrash.alpha = 0
            self.closedTrash.alpha = 1
        }
    }
    
    /// hides the opened/closed trash icon and the background circle
    func hide() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.borderCircle.alpha = 0
            self.backgroundCircle.alpha = 0
            self.openedTrash.alpha = 0
            self.closedTrash.alpha = 0
        }
    }
    
    /// Checks if the view contains a point
    func contains(_ point: CGPoint) -> Bool {
        return frame.contains(point)
    }
    
    /// Checks if the view contains a list of points
    func contains(_ points: [CGPoint]) -> Bool {
        return points.contains { point in
            frame.contains(point)
        }
    }
}
