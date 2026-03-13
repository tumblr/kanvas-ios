//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for changes in the trimming range
protocol TrimAreaDelegate: AnyObject {
    func didMoveLeftSide(recognizer: UIGestureRecognizer)
    func didMoveRightSide(recognizer: UIGestureRecognizer)
}

/// Constants for Trim area
private struct Constants {
    // General
    static let height: CGFloat = 71
    static let selectorInset: CGFloat = -20
    static let cornerRadius: CGFloat = 8
    static let backgroundColor: UIColor = KanvasColors.shared.trimBackgroundColor
    
    // Top and bottom borders
    static let selectorBorderHeight: CGFloat = 5
    
    // Selectors
    static let selectorSideWidth: CGFloat = 16
    
    // Selector inner line
    static let selectorLineHeight: CGFloat = 35
    static let selectorLineWidth: CGFloat = 4
    static let selectorLineCornerRadius: CGFloat = 4
    static let selectorLineColor: UIColor = .white
}

final class TrimArea: IgnoreTouchesView {
    
    weak var delegate: TrimAreaDelegate?
    
    static let height: CGFloat = Constants.height
    static let selectorWidth = Constants.selectorSideWidth
    static let cornerRadius = Constants.cornerRadius
    
    private let leftSelector: TrimAreaSelector
    private let rightSelector: TrimAreaSelector
    private let topBorder: UIView
    private let bottomBorder: UIView
    
    var leftSelectorLocation: CGFloat {
        return convert(leftSelector.center, to: superview).x + Constants.selectorSideWidth / 2
    }
    
    var rightSelectorLocation: CGFloat {
        return convert(rightSelector.center, to: superview).x - Constants.selectorSideWidth / 2
    }
    
    // MARK: - Initializers
    
    init() {
        leftSelector = TrimAreaSelector()
        rightSelector = TrimAreaSelector()
        topBorder = UIView()
        bottomBorder = UIView()
        super.init(frame: .zero)
        
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setupLeftSelector()
        setupRightSelector()
        setupTopBorder()
        setupBottomBorder()
    }
    
    private func setupLeftSelector() {
        leftSelector.accessibilityIdentifier = "Trim Area Left Selector"
        leftSelector.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftSelector)
        
        NSLayoutConstraint.activate([
            leftSelector.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            leftSelector.widthAnchor.constraint(equalToConstant: Constants.selectorSideWidth),
            leftSelector.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            leftSelector.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(leftViewTouched(recognizer:)))
        recognizer.minimumPressDuration = 0
        leftSelector.addGestureRecognizer(recognizer)
    }
    
    private func setupRightSelector() {
        rightSelector.accessibilityIdentifier = "Trim Area Right Selector"
        rightSelector.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightSelector)
        
        NSLayoutConstraint.activate([
            rightSelector.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            rightSelector.widthAnchor.constraint(equalToConstant: Constants.selectorSideWidth),
            rightSelector.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            rightSelector.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(rightViewTouched(recognizer:)))
        recognizer.minimumPressDuration = 0
        rightSelector.addGestureRecognizer(recognizer)
    }
    
    private func setupTopBorder() {
        topBorder.accessibilityIdentifier = "Trim Area Top View"
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.backgroundColor = Constants.backgroundColor
        topBorder.layer.cornerRadius = Constants.cornerRadius
        addSubview(topBorder)
        
        NSLayoutConstraint.activate([
            topBorder.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topBorder.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: Constants.selectorBorderHeight),
        ])
    }
    
    private func setupBottomBorder() {
        bottomBorder.accessibilityIdentifier = "Trim Area Bottom View"
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.backgroundColor = Constants.backgroundColor
        bottomBorder.layer.cornerRadius = Constants.cornerRadius
        addSubview(bottomBorder)
        
        NSLayoutConstraint.activate([
            bottomBorder.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: Constants.selectorBorderHeight),
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func leftViewTouched(recognizer: UIGestureRecognizer) {
        delegate?.didMoveLeftSide(recognizer: recognizer)
    }
    
    @objc private func rightViewTouched(recognizer: UIGestureRecognizer) {
        delegate?.didMoveRightSide(recognizer: recognizer)
    }
    
    // MARK: - Touches
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: 0, left: Constants.selectorInset, bottom: 0, right: Constants.selectorInset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    /// Shows or hides the white lines in the selectors.
    ///
    /// - Parameter show: true to show, false to hide.
    func showLines(_ show: Bool) {
        leftSelector.showLine(false)
        rightSelector.showLine(false)
    }
    
    /// Changes the background color of the view.
    ///
    /// - Parameter color: the new color.
    func setBackgroundColor(_ color: UIColor) {
        topBorder.backgroundColor = color
        bottomBorder.backgroundColor = color
        leftSelector.backgroundColor = color
        rightSelector.backgroundColor = color
    }
}

/// Handle at the side of the trim area.
private class TrimAreaSelector: UIView {
    
    private let innerLine: UIView
    
    // MARK: - Initializers
    
    init() {
        innerLine = UIView()
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        backgroundColor = Constants.backgroundColor
        setupInnerLine()
    }
    
    private func setupInnerLine() {
        innerLine.accessibilityIdentifier = "Trim Area Left Selector Line"
        innerLine.translatesAutoresizingMaskIntoConstraints = false
        innerLine.backgroundColor = Constants.selectorLineColor
        innerLine.layer.cornerRadius = Constants.selectorLineCornerRadius
        addSubview(innerLine)
        
        NSLayoutConstraint.activate([
            innerLine.centerXAnchor.constraint(equalTo: centerXAnchor),
            innerLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerLine.heightAnchor.constraint(equalToConstant: Constants.selectorLineHeight),
            innerLine.widthAnchor.constraint(equalToConstant: Constants.selectorLineWidth),
        ])
    }
    
    // MARK: - Touch
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: 0, left: Constants.selectorInset, bottom: 0, right: Constants.selectorInset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    // MARK: - Public interface
    
    /// Shows or hides the white line
    ///
    /// - Parameter show: true to show, false to hide.
    func showLine(_ show: Bool) {
        innerLine.alpha = show ? 1 : 0
    }
}
