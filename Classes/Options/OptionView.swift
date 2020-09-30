//
//  OptionView.swift
//  KanvasEditor
//
//  Created by Daniela Riesgo on 25/06/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

import Foundation
import UIKit

/// A view that contains a button and handles image layout
final class OptionView: UIView {

    private(set) var button: ExtendedButton
    private let inset: CGFloat
    
    /// The designated initializer for an OptionView, it can accept an `inset` value for a larger tap area
    ///
    /// - Parameters:
    ///   - image: image to describe the option
    ///   - inset: use a negative value to "outset"
    init(image: UIImage?, inset: CGFloat = 0) {
        self.inset = inset
        button = ExtendedButton(inset: inset)
        button.contentMode = .scaleAspectFit
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.applyShadows(offset: CGSize(width: 0.0, height: 2.0), radius: 0.0)
        super.init(frame: .zero)
        setUpButton()
    }

    @available(*, unavailable, message: "use init(image:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(image:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    private func setUpButton() {
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
