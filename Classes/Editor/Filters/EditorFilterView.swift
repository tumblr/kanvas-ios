//
//  EditorFilterView.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 26/07/2019.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for closing the filters
protocol EditorFilterViewDelegate: class {
    
    /// Called when the user taps the background to confirm
    func didTapBackground()
}

/// Constants for EditorFilterView
private struct EditorFilterViewConstants {
    static let collectionViewBottomMargin: CGFloat = Device.belongsToIPhoneXGroup ? 12.5 : 27
    static let collectionViewHeight: CGFloat = EditorFilterCollectionCell.minimumHeight
}

/// A UIView for the editor filter view
final class EditorFilterView: UIView {
    
    weak var delegate: EditorFilterViewDelegate?
    
    private let backgroundView = UIView()
    let collectionContainer = IgnoreTouchesView()
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        setUpBackgroundView()
        setUpCollectionContrainer()
    }
    
    // MARK: - views
    
    /// Sets up the view that fills the background
    func setUpBackgroundView() {
        backgroundView.backgroundColor = .clear
        backgroundView.accessibilityIdentifier = "Edition Filter Background View"
        backgroundView.clipsToBounds = false
        backgroundView.add(into: self)
        
        let tapPressRecognizer = UITapGestureRecognizer()
        tapPressRecognizer.addTarget(self, action: #selector(backgroundPressed(recognizer:)))
        backgroundView.addGestureRecognizer(tapPressRecognizer)
    }
    
    /// Sets up the view that contains the filter collection
    func setUpCollectionContrainer() {
        collectionContainer.backgroundColor = .clear
        collectionContainer.accessibilityIdentifier = "Edition Filter Collection Container"
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        collectionContainer.clipsToBounds = false
        
        addSubview(collectionContainer)
        NSLayoutConstraint.activate([
            collectionContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            collectionContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -EditorFilterViewConstants.collectionViewBottomMargin),
            collectionContainer.heightAnchor.constraint(equalToConstant: EditorFilterViewConstants.collectionViewHeight)
        ])
    }
    
    @objc private func backgroundPressed(recognizer: UITapGestureRecognizer) {
        delegate?.didTapBackground()
    }
}
