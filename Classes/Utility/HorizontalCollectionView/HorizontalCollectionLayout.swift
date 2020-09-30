//
//  HorizontalCollectionLayout.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 12/07/2019.
//

import Foundation
import UIKit

final class HorizontalCollectionLayout: UICollectionViewFlowLayout {
    
    init(cellWidth: CGFloat, minimumHeight: CGFloat) {
        super.init()
        configure(cellWidth: cellWidth, minimumHeight: minimumHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(cellWidth: CGFloat, minimumHeight: CGFloat) {
        scrollDirection = .horizontal
        itemSize = UICollectionViewFlowLayout.automaticSize
        estimatedItemSize = CGSize(width: cellWidth, height: minimumHeight)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
