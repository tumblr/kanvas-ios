//
//  ColorDrop.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 12/08/2019.
//

import Foundation
import UIKit

/// Constants for color drop
private struct Constants {
    static let topBorderWidth: CGFloat = 2
    static let bottomBorderWidth: CGFloat = 4
    static let horizontalBorderWidth: CGFloat = 2.5
}

/// Drop-shaped view which can change its color.
/// It also has a white border.
final class ColorDrop: UIImageView {
    
    static let defaultHeight: CGFloat = 55
    static let defaultWidth: CGFloat = 39
    
    private let innerDrop = UIImageView()
    
    var innerColor: UIColor {
        get {
            return innerDrop.tintColor
        }
        set {
            innerDrop.tintColor = newValue
        }
    }
    
    init() {
        super.init(image: nil)
        setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        image = KanvasCameraImages.dropImage?.withRenderingMode(.alwaysTemplate)
        tintColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        innerDrop.image = KanvasCameraImages.dropImage?.withRenderingMode(.alwaysTemplate)
        innerDrop.translatesAutoresizingMaskIntoConstraints = false
        innerDrop.clipsToBounds = true
        addSubview(innerDrop)
        
        NSLayoutConstraint.activate([
            innerDrop.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topBorderWidth),
            innerDrop.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomBorderWidth),
            innerDrop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalBorderWidth),
            innerDrop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalBorderWidth),
        ])
    }
}
