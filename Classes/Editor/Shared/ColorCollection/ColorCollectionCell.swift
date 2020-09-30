//
//  ColorCollectionCell.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 28/06/2019.
//

import Foundation
import UIKit

/// Delegate for touch events on this cell
protocol ColorCollectionCellDelegate: class {
    /// Callback method when selecting a cell
    ///
    /// - Parameters:
    ///   - cell: the cell that was selected
    func didSelect(cell: ColorCollectionCell)
}

private struct ColorCollectionCellConstants {
    static let circleDiameter: CGFloat = CircularImageView.size
    static let padding: CGFloat = CircularImageView.padding
    
    static var height: CGFloat {
        return circleDiameter
    }
    
    static var width: CGFloat {
        return circleDiameter + 2 * padding
    }
}

/// The cell in ColorCollectionView to display an individual color
final class ColorCollectionCell: UICollectionViewCell {
    
    static let height = ColorCollectionCellConstants.height
    static let width = ColorCollectionCellConstants.width
    
    private var circleView = CircularImageView()
    
    weak var delegate: ColorCollectionCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
        setUpRecognizers()
    }
    
    /// Updates the cell according to a color
    ///
    /// - Parameter color: The UIColor to display
    func bindTo(_ color: UIColor) {
        circleView.backgroundColor = color
    }
    
    
    /// Updates the cell to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        circleView.image = nil
        circleView.backgroundColor = nil
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        contentView.addSubview(circleView)
        circleView.accessibilityIdentifier = "Color Cell View"
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
            circleView.heightAnchor.constraint(equalToConstant: ColorCollectionCellConstants.circleDiameter),
            circleView.widthAnchor.constraint(equalToConstant: ColorCollectionCellConstants.circleDiameter)
        ])
    }
    
    
    // MARK: - Gesture recognizers
    
    func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        delegate?.didSelect(cell: self)
    }
}
