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
    static let size: CGFloat = KanvasCameraDesign.shared.trashViewSize
    static let borderImageSize: CGFloat = KanvasCameraDesign.shared.trashViewBorderImageSize
    static let closedIconSize: CGFloat = 33
    static let openedIconSize: CGFloat = 38
    static let borderWidth: CGFloat = 3.0
    static let openedIconCenterYOffset: CGFloat = 2.5
    static let openedIconCenterXOffset: CGFloat = 0
    
    // Redesign
    static let closedBinHeight: CGFloat = 28
    static let closedBinWidth: CGFloat = 24
    static let openedBinHeight: CGFloat = 31.76
    static let openedBinWidth: CGFloat = 23.29
    static var openedBinCenterYOffset: CGFloat = 1
    static var openedBinCenterXOffset: CGFloat = 0.9
}

/// View that shows an open or closed trash bin with a red circle as background
final class TrashView: IgnoreTouchesView {
    
    static let size: CGFloat = Constants.size
    
    private let isRedesign: Bool
    private let borderCircle: UIImageView
    private let backgroundCircle: UIImageView
    private let translucentBackgroundCircle: UIImageView
    private let openedTrash: UIImageView
    private let closedTrash: UIImageView
    
    init(isRedesign: Bool) {
        self.isRedesign = isRedesign
        self.borderCircle = UIImageView()
        self.backgroundCircle = UIImageView()
        self.translucentBackgroundCircle = UIImageView()
        self.openedTrash = UIImageView()
        self.closedTrash = UIImageView()
        super.init(frame: .zero)
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        setUpTranslucentBackgroundCircle()
        setUpBorderCircle()
        setUpBackgroundCircle()
        setUpTrashOpened()
        setUpTrashClosed()
    }
    
    /// Sets up the red circle on the background
    private func setUpTranslucentBackgroundCircle() {
        addSubview(translucentBackgroundCircle)
        translucentBackgroundCircle.accessibilityIdentifier = "Trash Translucent Background Circle"
        translucentBackgroundCircle.translatesAutoresizingMaskIntoConstraints = false
        translucentBackgroundCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        translucentBackgroundCircle.tintColor = KanvasCameraColors.shared.trashColor.withAlphaComponent(0.4)
        
        translucentBackgroundCircle.contentMode = .scaleAspectFit
        translucentBackgroundCircle.clipsToBounds = true

        
        NSLayoutConstraint.activate([
            translucentBackgroundCircle.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            translucentBackgroundCircle.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor),
            translucentBackgroundCircle.leadingAnchor.constraint(equalTo: safeLayoutGuide.leadingAnchor),
            translucentBackgroundCircle.trailingAnchor.constraint(equalTo: safeLayoutGuide.trailingAnchor)
        ])
        
        translucentBackgroundCircle.alpha = 0
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
        backgroundCircle.tintColor = KanvasCameraColors.shared.trashColor
        
        backgroundCircle.contentMode = .scaleAspectFit
        backgroundCircle.clipsToBounds = true

        
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
        
        let yOffset: CGFloat
        let xOffset: CGFloat
        let height: CGFloat
        let width: CGFloat
        let image: UIImage?
        
        if isRedesign {
            height = Constants.openedBinHeight
            width = Constants.openedBinWidth
            yOffset = Constants.openedBinCenterYOffset
            xOffset = Constants.openedBinCenterXOffset
            image = KanvasCameraImages.trashBinOpened
        }
        else {
            height = Constants.openedIconSize
            width = Constants.openedIconSize
            yOffset = Constants.openedIconCenterYOffset
            xOffset = Constants.openedIconCenterXOffset
            image = KanvasCameraImages.trashOpened
        }
        
        openedTrash.image = image
        
        NSLayoutConstraint.activate([
            openedTrash.heightAnchor.constraint(equalToConstant: height),
            openedTrash.widthAnchor.constraint(equalToConstant: width),
            openedTrash.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor, constant: -xOffset),
            openedTrash.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor, constant: -yOffset)
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
        
        let height: CGFloat
        let width: CGFloat
        let image: UIImage?
        
        if isRedesign {
            height = Constants.closedBinHeight
            width = Constants.closedBinWidth
            image = KanvasCameraImages.trashBinClosed
        }
        else {
            height = Constants.closedIconSize
            width = Constants.closedIconSize
            image = KanvasCameraImages.trashClosed
        }
        
        closedTrash.image = image
        
        NSLayoutConstraint.activate([
            closedTrash.heightAnchor.constraint(equalToConstant: height),
            closedTrash.widthAnchor.constraint(equalToConstant: width),
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
            self.translucentBackgroundCircle.alpha = 0
            self.openedTrash.alpha = 1
            self.closedTrash.alpha = 0
        }
    }
    
    /// shows closed trash icon without the background circle
    func close() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.borderCircle.alpha = 1
            self.backgroundCircle.alpha = 0
            self.translucentBackgroundCircle.alpha = self.isRedesign ? 1 : 0
            self.openedTrash.alpha = 0
            self.closedTrash.alpha = 1
        }
    }
    
    /// hides the opened/closed trash icon and the background circle
    func hide() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.borderCircle.alpha = 0
            self.backgroundCircle.alpha = 0
            self.translucentBackgroundCircle.alpha = 0
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
    
    /// Opens/closes if a point is inside/outside the view
    func changeStatus(_ points: [CGPoint]) {
        let fingerOnView = self.contains(points)
        
        if fingerOnView {
            open()
        }
        else {
            close()
        }
    }
}
