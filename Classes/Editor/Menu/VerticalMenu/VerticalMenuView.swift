//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let animationDuration: TimeInterval = 0.5
    static let maxVisibleCells: Int = 3
}

protocol VerticalMenuViewDelegate: class {
    
    func numberOfItems() -> Int
    
    func bindItem(at index: Int)
}

private enum State {
    case open
    case closed
}

/// Collection view for VerticalMenuController.
final class VerticalMenuView: IgnoreTouchesView, ExpandCellDelegate {
    
    private weak var delegate: VerticalMenuViewDelegate?
    
    private var state: State
    private let scrollView: UIScrollView
    private let scrollViewContent: IgnoreTouchesView
    private let contentView: IgnoreTouchesView
    private let fadeView: IgnoreTouchesView
    private var cells: [VerticalMenuCell]
    private let expandCell: ExpandCell
    
    private var showExpandCell: Bool {
        guard let delegate = delegate else { return false }
        return delegate.numberOfItems() > Constants.maxVisibleCells
    }
    
    private lazy var contentHeightContraint: NSLayoutConstraint = {
        contentView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    private lazy var fadeViewHeightContraint: NSLayoutConstraint = {
        fadeView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    init(delegate: VerticalMenuViewDelegate) {
        self.delegate = delegate
        self.scrollView = IgnoreTouchesScrollView()
        self.scrollViewContent = IgnoreTouchesView()
        self.contentView = IgnoreTouchesView()
        self.fadeView = IgnoreTouchesView()
        self.expandCell = ExpandCell()
        self.cells = []
        self.state = .closed
        super.init(frame: .zero)
        self.expandCell.delegate = self
        
        setupViews()
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
    
    private func setupViews() {
        setupScrollView()
        setupScrollViewContent()
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
    
    private func setupScrollViewContent() {
        scrollView.addSubview(scrollViewContent)
        scrollViewContent.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollViewContent.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
            scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
       
    private func setupContentView() {
        guard let delegate = delegate else { return }
        
        scrollViewContent.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let numberOfItems = CGFloat(delegate.numberOfItems())
        
        let itemHeight: CGFloat = numberOfItems * VerticalMenuCell.height
        let expandCellHeight = ExpandCell.height
        let contentHeight: CGFloat = showExpandCell ? (itemHeight + expandCellHeight) : itemHeight
        
        contentHeightContraint.constant = contentHeight
        NSLayoutConstraint.activate([
            contentHeightContraint,
            contentView.centerYAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupFadeView() {
        guard let delegate = delegate else { return }
        
        contentView.addSubview(fadeView)
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        
        let numberOfItems = CGFloat(delegate.numberOfItems())
        let contentHeight: CGFloat = numberOfItems * VerticalMenuCell.height
        
        fadeViewHeightContraint.constant = contentHeight
        NSLayoutConstraint.activate([
            fadeViewHeightContraint,
            fadeView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            fadeView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            fadeView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupCollection() {
        guard let delegate = delegate else { return }
        
        for _ in 0..<delegate.numberOfItems() {
            let cell = VerticalMenuCell()
            fadeView.addSubview(cell)
            cells.append(cell)
        }
    }
    
    private func setupCells() {
        guard let delegate = delegate else { return }
        
        for index in 0..<delegate.numberOfItems() {
            let cell = cells[index]
            cell.translatesAutoresizingMaskIntoConstraints = false
            
            let topOffset: CGFloat = VerticalMenuCell.height * CGFloat(index)
            NSLayoutConstraint.activate([
                cell.topAnchor.constraint(equalTo: fadeView.safeAreaLayoutGuide.topAnchor, constant: topOffset),
                cell.centerXAnchor.constraint(equalTo: fadeView.safeAreaLayoutGuide.centerXAnchor),
                cell.heightAnchor.constraint(equalToConstant: VerticalMenuCell.height),
                cell.widthAnchor.constraint(equalToConstant: VerticalMenuCell.width),
            ])
        }
    }
    
    private func setupExpandCell() {
        contentView.addSubview(expandCell)
        expandCell.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expandCell.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            expandCell.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            expandCell.heightAnchor.constraint(equalToConstant: ExpandCell.height),
            expandCell.widthAnchor.constraint(equalToConstant: ExpandCell.width),
        ])
    }
    
    private func bindCells() {
        guard let delegate = delegate else { return }
        
        for i in 0..<delegate.numberOfItems() {
            delegate.bindItem(at: i)
        }
    }
    
    private func resetCollection() {
        expandCell.removeFromSuperview()
        
        cells.forEach { cell in
            cell.removeFromSuperview()
        }
        
        cells.removeAll()
        contentHeightContraint.constant = 0
        fadeViewHeightContraint.constant = 0
    }
    
    // MARK: - Expand & Collapse
    
    private func moveExpandCellUp() {
        contentHeightContraint.constant = VerticalMenuCell.height * CGFloat(Constants.maxVisibleCells) + ExpandCell.height
        fadeViewHeightContraint.constant = VerticalMenuCell.height * CGFloat(Constants.maxVisibleCells)
    }
    
    private func moveExpandCellDown() {
        guard let delegate = delegate else { return }
        contentHeightContraint.constant = VerticalMenuCell.height * CGFloat(delegate.numberOfItems()) + ExpandCell.height
        fadeViewHeightContraint.constant = VerticalMenuCell.height * CGFloat(delegate.numberOfItems())
    }
    
    private func hideExtraCells() {
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        extraCells.forEach {
            $0.alpha = 0
        }
    }
    
    private func showExtraCells() {
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        extraCells.forEach {
            $0.alpha = 1
        }
    }
    
    // MARK: - Public interface
    
    func collapseCollection(animated: Bool = false) {
        state = .closed
        let firstAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.hideExtraCells()
        }
        
        let secondAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.expandCell.close()
            self.moveExpandCellUp()
            self.layoutIfNeeded()
        }
        
        if animated {
            let duration = Constants.animationDuration
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1 / duration, animations: firstAction)
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5 / duration, animations: secondAction)
            }, completion: nil)
        }
        else {
            firstAction()
            secondAction()
        }
    }
    
    func expandCollection(animated: Bool = false) {
        state = .open
        
        let firstAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.expandCell.open()
            self.moveExpandCellDown()
            self.layoutIfNeeded()
        }
        
        let secondAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.showExtraCells()
        }
        
        if animated {
            let duration = Constants.animationDuration
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0 / duration, relativeDuration: 0.5 / duration, animations: firstAction)
                UIView.addKeyframe(withRelativeStartTime: 0.1 / duration, relativeDuration: 0.4 / duration, animations: secondAction)
            }, completion: nil)
        }
        else {
            firstAction()
            secondAction()
        }
    }
    
    func reload() {
        resetCollection()
        setupFadeView()
        setupContentView()
        setupCollection()
        setupCells()
        bindCells()
        
        if showExpandCell {
            setupExpandCell()
            collapseCollection()
        }
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
    
    // MARK: - ExpandCellDelegate
    
    func didTap(cell: ExpandCell, recognizer: UITapGestureRecognizer) {
        switch state {
        case .open:
            collapseCollection(animated: true)
        case .closed:
            expandCollection(animated: true)
        }
    }
}

private final class IgnoreTouchesScrollView: UIScrollView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}
