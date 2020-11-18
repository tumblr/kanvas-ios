//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol VerticalMenuViewDelegate: class {
    
    func numberOfItems() -> Int
    
    func bindItem(at index: Int)
}

/// Collection view for VerticalMenuController.
final class VerticalMenuView: IgnoreTouchesView {
    
    private weak var delegate: VerticalMenuViewDelegate?
    
    private let scrollView: UIScrollView
    private let contentView: IgnoreTouchesView
    private var cells: [VerticalMenuCell]
    
    init(delegate: VerticalMenuViewDelegate) {
        self.delegate = delegate
        self.scrollView = IgnoreTouchesScrollView()
        self.contentView = IgnoreTouchesView()
        self.cells = []
        super.init(frame: .zero)
        setUpViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        setupScrollView()
        setupContentView()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
        
    private func setupCollection() {
        guard let delegate = delegate else { return }
        
        for _ in 0..<delegate.numberOfItems() {
            let cell = VerticalMenuCell()
            contentView.addSubview(cell)
            cells.append(cell)
        }
    }
    
    private func setupCells() {
        guard let delegate = delegate else { return }
        
        let contentHeight: CGFloat = CGFloat(cells.count) * VerticalMenuCell.height
        
        for index in 0..<delegate.numberOfItems() {
            let cell = cells[index]
            cell.translatesAutoresizingMaskIntoConstraints = false
            
            let centerYOffset: CGFloat = -(contentHeight / 2) + VerticalMenuCell.height * CGFloat(index)
            NSLayoutConstraint.activate([
                cell.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor, constant: centerYOffset),
                cell.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
                cell.heightAnchor.constraint(equalToConstant: VerticalMenuCell.height),
                cell.widthAnchor.constraint(equalToConstant: VerticalMenuCell.width),
            ])
        }
    }
    
    private func bindCells() {
        guard let delegate = delegate else { return }
        
        for i in 0..<delegate.numberOfItems() {
            delegate.bindItem(at: i)
        }
    }
    
    private func resetCollection() {
        cells.forEach { cell in
            cell.removeFromSuperview()
        }
        
        cells.removeAll()
    }
    
    // MARK: - Public interface
    
    func reload() {
        resetCollection()
        setupCollection()
        setupCells()
        bindCells()
    }
    
    func getCell(at index: Int) -> VerticalMenuCell? {
        return cells.object(at: index)
    }
    
    func getIndex(for cell: VerticalMenuCell) -> Int? {
        return cells.index(of: cell)
    }
    
    func reloadItem(at index: Int) {
        delegate?.bindItem(at: index)
    }    
}

private final class IgnoreTouchesScrollView: UIScrollView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
    
}
