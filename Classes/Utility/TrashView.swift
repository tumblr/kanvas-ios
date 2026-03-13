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
    static let size: CGFloat = KanvasDesign.shared.trashViewSize
    static let borderImageSize: CGFloat = KanvasDesign.shared.trashViewBorderImageSize
    static let closedIconHeight: CGFloat = KanvasDesign.shared.trashViewClosedIconHeight
    static let closedIconWidth: CGFloat = KanvasDesign.shared.trashViewClosedIconWidth
    static let openedIconHeight: CGFloat = KanvasDesign.shared.trashViewOpenedIconHeight
    static let openedIconWidth: CGFloat = KanvasDesign.shared.trashViewOpenedIconWidth
    static let openedIconCenterYOffset: CGFloat = KanvasDesign.shared.trashViewOpenedIconCenterYOffset
    static let openedIconCenterXOffset: CGFloat = KanvasDesign.shared.trashViewOpenedIconCenterXOffset
    static let borderWidth: CGFloat = KanvasDesign.shared.trashViewBorderWidth
}

/// View that shows an open or closed trash bin with a red circle as background
final class TrashView: IgnoreTouchesView {
    
    static let size: CGFloat = Constants.size
    
    private let borderCircle: UIImageView
    private let backgroundCircle: UIImageView
    private let translucentBackgroundCircle: UIImageView
    private let openedTrash: UIImageView
    private let closedTrash: UIImageView

    var completion: (() -> Void)?

    override var ignoredTypes: [UIEvent.EventType]? {
        return [.touches, .presses]
    }
    
    init() {
        self.borderCircle = UIImageView()
        self.backgroundCircle = UIImageView()
        self.translucentBackgroundCircle = UIImageView()
        self.openedTrash = UIImageView()
        self.closedTrash = UIImageView()
        super.init(frame: .zero)
        
        setUpViews()

        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)

        isUserInteractionEnabled = true
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
    
    /// Sets up the red translucent circle on the background
    private func setUpTranslucentBackgroundCircle() {
        addSubview(translucentBackgroundCircle)
        translucentBackgroundCircle.accessibilityIdentifier = "Trash Translucent Background Circle"
        translucentBackgroundCircle.translatesAutoresizingMaskIntoConstraints = false
        translucentBackgroundCircle.image = KanvasImages.circleImage?.withRenderingMode(.alwaysTemplate)
        translucentBackgroundCircle.tintColor = KanvasColors.shared.trashColor.withAlphaComponent(0.4)
        
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
        backgroundCircle.image = KanvasImages.circleImage?.withRenderingMode(.alwaysTemplate)
        backgroundCircle.tintColor = KanvasColors.shared.trashColor
        
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
        openedTrash.image = KanvasDesign.shared.trashViewOpenedImage
        
        let yOffset = KanvasDesign.shared.trashViewOpenedIconCenterYOffset
        let xOffset = KanvasDesign.shared.trashViewOpenedIconCenterXOffset
        let height = KanvasDesign.shared.trashViewOpenedIconHeight
        let width = KanvasDesign.shared.trashViewOpenedIconWidth
        
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
        closedTrash.image = KanvasDesign.shared.trashViewClosedImage
        
        let height = KanvasDesign.shared.trashViewClosedIconHeight
        let width = KanvasDesign.shared.trashViewClosedIconWidth
        
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
            self.translucentBackgroundCircle.alpha = KanvasDesign.shared.isBottomPicker ? 1 : 0
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

extension TrashView: UIDropInteractionDelegate {
    // MARK: - UIDropInteractionDelegate

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        completion?()
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        UISelectionFeedbackGenerator().selectionChanged()
        open()
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        UISelectionFeedbackGenerator().selectionChanged()
        close()
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return true
    }
}
