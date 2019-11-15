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
    static let topContainerHeight: CGFloat = 52
    static let topContainerLineHeight: CGFloat = 5
    static let topContainerLineWidth: CGFloat = 36
    static let topContainerLineRadius: CGFloat = 36
    static let topContainerLineColor: UIColor = .black
    static let backgroundColor: UIColor = .white
    static let tabBarHeight: CGFloat = DrawerTabBarView.height
}

/// A UIView for the media drawer view
final class MediaDrawerView: UIView {
    
    static let tabBarHeight: CGFloat = Constants.tabBarHeight
    
    weak var delegate: MediaDrawerViewDelegate?
    
    private let topContainer: UIView
    private let topContainerLine: UIView
    private let backPanel: UIView
    let tabBarContainer: UIView
    let childContainer: UIView
    
    // MARK: - Initializers
    
    init() {
        topContainer = UIView()
        topContainerLine = UIView()
        backPanel = UIView()
        tabBarContainer = UIView()
        childContainer = UIView()
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        setupChildContainer()
        setupBackPanel()
        setupTopContainer()
        setupTopContainerLine()
        setupTabBar()
    }
    
    private func setupBackPanel() {
        addSubview(backPanel)
        backPanel.accessibilityLabel = "Media Drawer Back Panel"
        backPanel.backgroundColor = Constants.backgroundColor
        backPanel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backPanel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topContainerHeight / 2),
            backPanel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            backPanel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            backPanel.heightAnchor.constraint(equalToConstant: Constants.topContainerHeight / 2),
        ])
    }
    
    private func setupTopContainer() {
        addSubview(topContainer)
        topContainer.accessibilityLabel = "Media Drawer Top Container"
        topContainer.backgroundColor = Constants.backgroundColor
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: Constants.topContainerHeight),
        ])
        
        topContainer.layer.cornerRadius = 30
        topContainer.layer.masksToBounds = true
    }
    
    private func setupTopContainerLine() {
        topContainer.addSubview(topContainerLine)
        topContainerLine.accessibilityLabel = "Media Drawer Top Container Line"
        topContainerLine.backgroundColor = Constants.topContainerLineColor
        topContainerLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topContainerLine.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            topContainerLine.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            topContainerLine.heightAnchor.constraint(equalToConstant: Constants.topContainerLineHeight),
            topContainerLine.widthAnchor.constraint(equalToConstant: Constants.topContainerLineWidth),
        ])
        
        topContainerLine.layer.cornerRadius = 2.5
        topContainerLine.layer.masksToBounds = true
    }
    
    private func setupTabBar() {
        addSubview(tabBarContainer)
        tabBarContainer.accessibilityLabel = "Media Drawer Tab Bar Container"
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBarContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topContainerHeight),
            tabBarContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tabBarContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tabBarContainer.heightAnchor.constraint(equalToConstant: Constants.tabBarHeight),
        ])
    }
    
    private func setupChildContainer() {
        addSubview(childContainer)
        childContainer.accessibilityLabel = "Media Drawer Child Container"
        childContainer.translatesAutoresizingMaskIntoConstraints = false
        childContainer.clipsToBounds = false
        childContainer.backgroundColor = Constants.backgroundColor
        
        NSLayoutConstraint.activate([
            childContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topContainerHeight + Constants.tabBarHeight),
            childContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            childContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            childContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
