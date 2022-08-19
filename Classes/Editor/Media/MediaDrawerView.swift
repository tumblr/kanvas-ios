//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol MediaDrawerViewDelegate: AnyObject {
    /// Called when the close button is tapped
    func didTapCloseButton()
}

/// Constants for MediaDrawerView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let topContainerHeight: CGFloat = 52
    static let topContainerLineHeight: CGFloat = 5
    static let topContainerLineWidth: CGFloat = 36
    static let topContainerLineRadius: CGFloat = 2.5
    static let topContainerLineColor: UIColor = .black
    static let backgroundColor: UIColor = .white
    static let bottomBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    static let tabBarHeight: CGFloat = DrawerTabBarView.height
    static let closeButtonSize: CGFloat = 17
    static let closeButtonHorizontalMargin: CGFloat = 18
    static let closeButtonInset: CGFloat = -9
}

/// A UIView for the media drawer controller
final class MediaDrawerView: UIView {
    
    static let tabBarHeight: CGFloat = Constants.tabBarHeight
    
    weak var delegate: MediaDrawerViewDelegate?
    
    private let topContainer: UIView
    private let topContainerLine: UIView
    private let closeButton: UIButton
    
    // Containers
    let tabBarContainer: UIView
    let childContainer: UIView
    
    // MARK: - Initializers
    
    init() {
        topContainer = UIView()
        topContainerLine = UIView()
        closeButton = ExtendedButton(inset: Constants.closeButtonInset)
        tabBarContainer = UIView()
        childContainer = UIView()
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupView() {
        backgroundColor = Constants.backgroundColor
        setupChildContainer()
        setupTopContainer()
        setupTopContainerLine()
        setupCloseButton()
        setupTabBar()
    }
    
    /// Sets up the container for the new view after a tab is selected
    private func setupChildContainer() {
        addSubview(childContainer)
        childContainer.accessibilityIdentifier = "Media Drawer Child Container"
        childContainer.translatesAutoresizingMaskIntoConstraints = false
        childContainer.backgroundColor = Constants.bottomBackgroundColor
        childContainer.clipsToBounds = false
        
        NSLayoutConstraint.activate([
            childContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topContainerHeight + Constants.tabBarHeight),
            childContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            childContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            childContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    /// Sets up the top view with rounded corners
    private func setupTopContainer() {
        addSubview(topContainer)
        topContainer.accessibilityIdentifier = "Media Drawer Top Container"
        topContainer.backgroundColor = Constants.backgroundColor
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: Constants.topContainerHeight),
        ])
    }
    
    /// Sets up the small black line with rounded ends in the top view
    private func setupTopContainerLine() {
        topContainer.addSubview(topContainerLine)
        topContainerLine.accessibilityIdentifier = "Media Drawer Top Container Line"
        topContainerLine.backgroundColor = Constants.topContainerLineColor
        topContainerLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topContainerLine.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            topContainerLine.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            topContainerLine.heightAnchor.constraint(equalToConstant: Constants.topContainerLineHeight),
            topContainerLine.widthAnchor.constraint(equalToConstant: Constants.topContainerLineWidth),
        ])
        
        topContainerLine.layer.cornerRadius = Constants.topContainerLineRadius
        topContainerLine.layer.masksToBounds = true
    }
    
    /// Sets up the close button
    private func setupCloseButton() {
        addSubview(closeButton)
        closeButton.accessibilityIdentifier = "Media Drawer Top Container Close Button"
        let image = KanvasImages.closeImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = KanvasColors.shared.closeButtonColor
        closeButton.adjustsImageWhenHighlighted = false
        closeButton.contentMode = .scaleAspectFit
        closeButton.contentVerticalAlignment = .center
        closeButton.contentHorizontalAlignment = .center
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.closeButtonHorizontalMargin),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
        ])
    }
    
    /// Sets up the top tab bar
    private func setupTabBar() {
        addSubview(tabBarContainer)
        tabBarContainer.accessibilityIdentifier = "Media Drawer Tab Bar Container"
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBarContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topContainerHeight),
            tabBarContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tabBarContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tabBarContainer.heightAnchor.constraint(equalToConstant: Constants.tabBarHeight),
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func closeButtonTapped() {
        delegate?.didTapCloseButton()
    }
}
