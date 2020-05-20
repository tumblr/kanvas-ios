//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for changes in the trimming range
protocol TrimAreaDelegate: class {
    func didMoveLeftSide(recognizer: UIGestureRecognizer)
    func didMoveRightSide(recognizer: UIGestureRecognizer)
}

/// Constants for Trim area
private struct Constants {
    static let selectorInset: CGFloat = -20
    
    static let cornerRadius: CGFloat = 8
    
    static let selectorColor: UIColor = .tumblrBrightBlue
    static let selectorBorderHeight: CGFloat = 5
    static let selectorSideWidth: CGFloat = 16
    
    static let selectorLineHeight: CGFloat = 35
    static let selectorLineWidth: CGFloat = 4
    static let selectorLineCornerRadius: CGFloat = 4
    static let selectorLineColor: UIColor = .white
}

final class TrimArea: IgnoreTouchesView {
    
    weak var delegate: TrimAreaDelegate?
    
    static let selectorWidth = Constants.selectorSideWidth
    
    private let leftSelector: TrimAreaSelector
    private let rightSelector: TrimAreaSelector
    private let leftLine: UIView
    private let rightLine: UIView
    private let topView: UIView
    private let bottomView: UIView
    
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
        leftLine = UIView()
        rightLine = UIView()
        topView = UIView()
        bottomView = UIView()
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setupLeftSelector()
        setupLeftLine()
        setupRightSelector()
        setupRightLine()
        setupTopView()
        setupBottomView()
    }
    
    private func setupLeftSelector() {
        leftSelector.accessibilityIdentifier = "Trim Area Left View"
        leftSelector.translatesAutoresizingMaskIntoConstraints = false
        leftSelector.backgroundColor = Constants.selectorColor
        leftSelector.layer.cornerRadius = Constants.cornerRadius
        leftSelector.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
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
        rightSelector.accessibilityIdentifier = "Trim Area Right View"
        rightSelector.translatesAutoresizingMaskIntoConstraints = false
        rightSelector.backgroundColor = Constants.selectorColor
        rightSelector.layer.cornerRadius = Constants.cornerRadius
        rightSelector.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
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
    
    private func setupLeftLine() {
        leftLine.accessibilityIdentifier = "Trim Area Left Line"
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.backgroundColor = Constants.selectorLineColor
        leftLine.layer.cornerRadius = Constants.selectorLineCornerRadius
        leftSelector.addSubview(leftLine)
        
        NSLayoutConstraint.activate([
            leftLine.centerXAnchor.constraint(equalTo: leftSelector.centerXAnchor),
            leftLine.centerYAnchor.constraint(equalTo: leftSelector.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: Constants.selectorLineHeight),
            leftLine.widthAnchor.constraint(equalToConstant: Constants.selectorLineWidth),
        ])
    }
    
    private func setupRightLine() {
        rightLine.accessibilityIdentifier = "Trim Area Right Line"
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.backgroundColor = Constants.selectorLineColor
        rightLine.layer.cornerRadius = Constants.selectorLineCornerRadius
        rightSelector.addSubview(rightLine)
        
        NSLayoutConstraint.activate([
            rightLine.centerXAnchor.constraint(equalTo: rightSelector.centerXAnchor),
            rightLine.centerYAnchor.constraint(equalTo: rightSelector.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: Constants.selectorLineHeight),
            rightLine.widthAnchor.constraint(equalToConstant: Constants.selectorLineWidth),
        ])
    }
    
    private func setupTopView() {
        topView.accessibilityIdentifier = "Trim Area Top View"
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = Constants.selectorColor
        topView.layer.cornerRadius = Constants.cornerRadius
        addSubview(topView)
        
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: Constants.selectorBorderHeight),
        ])
    }
    
    private func setupBottomView() {
        bottomView.accessibilityIdentifier = "Trim Area Bottom View"
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = Constants.selectorColor
        bottomView.layer.cornerRadius = Constants.cornerRadius
        addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: Constants.selectorBorderHeight),
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
    
}


private class TrimAreaSelector: UIView {
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: 0, left: Constants.selectorInset, bottom: 0, right: Constants.selectorInset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}
