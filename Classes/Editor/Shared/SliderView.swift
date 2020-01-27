//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

final class SliderView: UIView {
    
    private let topCircle: CircularImageView
    private let bottomCircle: CircularImageView
    private let rectangle: UIView
    
    // MARK: - Initializers
    
    init() {
        topCircle = CircularImageView()
        bottomCircle = CircularImageView()
        rectangle = UIView()
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        moveDown()
    }
    
    // MARK: - Layout
    
    private func setupView() {
        setupTopCircle()
        setupBottomCircle()
        setupRectangle()
    }
    
    private func setupTopCircle() {
        addSubview(topCircle)
        topCircle.backgroundColor = .white
        topCircle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topCircle.topAnchor.constraint(equalTo: topAnchor),
            topCircle.heightAnchor.constraint(equalTo: widthAnchor),
            topCircle.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    private func setupBottomCircle() {
        addSubview(bottomCircle)
        bottomCircle.backgroundColor = .white
        bottomCircle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomCircle.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomCircle.heightAnchor.constraint(equalTo: widthAnchor),
            bottomCircle.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    private func setupRectangle() {
        addSubview(rectangle)
        rectangle.backgroundColor = .white
        rectangle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rectangle.topAnchor.constraint(equalTo: topCircle.centerYAnchor),
            rectangle.bottomAnchor.constraint(equalTo: bottomCircle.centerYAnchor),
            rectangle.leadingAnchor.constraint(equalTo: leadingAnchor),
            rectangle.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    // MARK: - Private utilities
    
    private func moveUp() {
        self.topCircle.transform = .identity
        self.rectangle.transform = .identity
    }
    
    private func moveDown() {
        let circleTranslation = CGAffineTransform(translationX: 0, y: self.bottomCircle.center.y - self.topCircle.center.y)
        self.topCircle.transform = circleTranslation
        
        let rectangleTranslation = CGAffineTransform(translationX: 0, y: self.bottomCircle.center.y - self.rectangle.center.y)
        let rectangleScale = CGAffineTransform(scaleX: 1, y: 0.0001)
        self.rectangle.transform = rectangleScale.concatenating(rectangleTranslation)
    }
    
    // MARK: - Public interface
    
    func open(animated: Bool = true, animationDuration: TimeInterval = Constants.animationDuration,
              animation: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                self.moveUp()
                animation?()
            }, completion: { _ in
                completion?()
            })
        }
        else {
            moveUp()
            animation?()
            completion?()
        }
    }
    
    func close(animated: Bool = true, animationDuration: TimeInterval = Constants.animationDuration,
               animation: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                self.moveDown()
                animation?()
            }, completion: { _ in
                completion?()
            })
        }
        else {
            moveDown()
            animation?()
            completion?()
        }
    }
}
