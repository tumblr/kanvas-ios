//
//  HorizontalCollectionView.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 12/07/2019.
//

import Foundation
import UIKit

final class HorizontalCollectionView: UICollectionView {
    
    private let ignoreTouches: Bool
    
    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, ignoreTouches: Bool) {
        self.ignoreTouches = ignoreTouches
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        isScrollEnabled = true
        allowsSelection = true
        bounces = true
        alwaysBounceHorizontal = true
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        autoresizesSubviews = true
        contentInset = .zero
        decelerationRate = UIScrollView.DecelerationRate.fast
        dragInteractionEnabled = true
        reorderingCadence = .immediate
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if ignoreTouches {
            return hitView == self ? nil : hitView
        }
        else {
            return hitView
        }
    }
}
