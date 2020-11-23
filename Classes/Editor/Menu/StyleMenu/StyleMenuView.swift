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
    static let timerInterval: TimeInterval = 3
}

protocol StyleMenuViewDelegate: class {
    
    func numberOfItems() -> Int
    
    func bindItem(at index: Int, cell: StyleMenuCell)
    
    /// Callback method when selecting a cell.
    ///
    /// - Parameter cell: the cell that was tapped
    func didSelect(cell: StyleMenuCell)
}

private enum State {
    case open
    case closed
}

/// Collection view for StyleMenuController.
final class StyleMenuView: IgnoreTouchesView, StyleMenuCellDelegate, StyleMenuExpandCellDelegate, IgnoreTouchesScrollViewDelegate {
    
    private weak var delegate: StyleMenuViewDelegate?
    
    private var state: State
    private let scrollView: IgnoreTouchesScrollView
    private let scrollViewContent: IgnoreTouchesView
    private let contentView: IgnoreTouchesView
    private let fadeView: IgnoreTouchesView
    private var cells: [StyleMenuCell]
    private let expandCell: StyleMenuExpandCell
    private var labelTimer: Timer?
    
    
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
    
    private lazy var menuOpenContentViewWidthConstraint: NSLayoutConstraint = {
        contentView.trailingAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.trailingAnchor)
    }()
    
    private lazy var menuClosedContentViewWidthConstraint: NSLayoutConstraint = {
        contentView.widthAnchor.constraint(equalToConstant: StyleMenuCell.iconWidth)
    }()
    
    init(delegate: StyleMenuViewDelegate) {
        self.delegate = delegate
        self.scrollView = IgnoreTouchesScrollView()
        self.scrollViewContent = IgnoreTouchesView()
        self.contentView = IgnoreTouchesView()
        self.fadeView = IgnoreTouchesView()
        self.expandCell = StyleMenuExpandCell()
        self.cells = []
        self.state = .closed
        super.init(frame: .zero)
        self.expandCell.delegate = self
        self.scrollView.touchDelegate = self
        
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
        
        let itemHeight: CGFloat = numberOfItems * StyleMenuCell.height
        let expandCellHeight = StyleMenuExpandCell.height
        let contentHeight: CGFloat = showExpandCell ? (itemHeight + expandCellHeight) : itemHeight
        
        contentHeightContraint.constant = contentHeight
        NSLayoutConstraint.activate([
            contentHeightContraint,
            contentView.centerYAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.leadingAnchor),
        ])
        
        setConstraints(for: .open)
    }
    
    private func setupFadeView() {
        guard let delegate = delegate else { return }
        
        contentView.addSubview(fadeView)
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        
        let numberOfItems = CGFloat(delegate.numberOfItems())
        let contentHeight: CGFloat = numberOfItems * StyleMenuCell.height
        
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
            let cell = StyleMenuCell()
            fadeView.addSubview(cell)
            cells.append(cell)
        }
    }
    
    private func setupCells() {
        guard let delegate = delegate else { return }
        
        for index in 0..<delegate.numberOfItems() {
            let cell = cells[index]
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.clipsToBounds = true
            cell.delegate = self
            
            let topOffset: CGFloat = StyleMenuCell.height * CGFloat(index)
            NSLayoutConstraint.activate([
                cell.topAnchor.constraint(equalTo: fadeView.safeAreaLayoutGuide.topAnchor, constant: topOffset),
                cell.leadingAnchor.constraint(equalTo: fadeView.safeAreaLayoutGuide.leadingAnchor),
                cell.heightAnchor.constraint(equalToConstant: StyleMenuCell.height),
            ])
        }
    }
    
    private func setupExpandCell() {
        contentView.addSubview(expandCell)
        expandCell.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expandCell.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            expandCell.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            expandCell.heightAnchor.constraint(equalToConstant: StyleMenuExpandCell.height),
        ])
    }
    
    private func bindCells() {
        guard let delegate = delegate else { return }
        
        for (index, cell) in cells.enumerated() {
            delegate.bindItem(at: index, cell: cell)
        }
    }
    
    private func resetCollection() {
        expandCell.removeFromSuperview()
        
        cells.forEach { cell in
            cell.removeFromSuperview()
        }
        
        cells.removeAll()
        
        fadeViewHeightContraint.constant = 0
        fadeView.removeFromSuperview()
        
        contentHeightContraint.constant = 0
        contentView.removeFromSuperview()
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
    
    private func stopTimer() {
        labelTimer?.invalidate()
        labelTimer = nil
    }
    
    private func setConstraints(for state: State) {
        switch state {
        case .open:
            menuOpenContentViewWidthConstraint.isActive = true
            menuClosedContentViewWidthConstraint.isActive = false
        case .closed:
            menuOpenContentViewWidthConstraint.isActive = false
            menuClosedContentViewWidthConstraint.isActive = true
        }
    }
        
    // MARK: - Expand & Collapse
    
    private func moveExpandCellUp() {
        contentHeightContraint.constant = StyleMenuCell.height * CGFloat(Constants.maxVisibleCells) + StyleMenuExpandCell.height
        fadeViewHeightContraint.constant = StyleMenuCell.height * CGFloat(Constants.maxVisibleCells)
    }
    
    private func moveExpandCellDown() {
        guard let delegate = delegate else { return }
        contentHeightContraint.constant = StyleMenuCell.height * CGFloat(delegate.numberOfItems()) + StyleMenuExpandCell.height
        fadeViewHeightContraint.constant = StyleMenuCell.height * CGFloat(delegate.numberOfItems())
    }
    
    // MARK: - Public interface
    
    func collapseCollection(animated: Bool = false) {
        state = .closed
        stopTimer()
        
        let action: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.expandCell.rotateDown()
            self.moveExpandCellUp()
            self.showLabels(false)
            self.setConstraints(for: .closed)
            self.layoutIfNeeded()
        }
        
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        let timeSlice = 1.0 / Double(extraCells.count + 1)
        
        let actions = {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0, animations: action)
            
            extraCells.enumerated().forEach { index, cell in
                let startTime = (Double(extraCells.count - index - 1)) * timeSlice
                UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: timeSlice, animations: {
                    cell.alpha = 0
                })
            }
        }
        
        let completion: (Bool) -> Void = { [weak self] _ in
            self?.expandCell.changeLabel(to: NSLocalizedString("EditorMore", comment: "Label for the 'More' option in the editor tools"))
        }
        
        if animated {
            UIView.animateKeyframes(withDuration: Constants.animationDuration, delay: 0, options: [.calculationModeCubic], animations: actions, completion: completion)
        }
        else {
            action()
            hideExtraCells()
            completion(true)
        }
    }
    
    func expandCollection(animated: Bool = false) {
        state = .open
        expandCell.changeLabel(to: NSLocalizedString("EditorClose", comment: "Label for the 'Close' option in the editor tools"))
        stopTimer()
        
        let action: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.expandCell.rotateUp()
            self.moveExpandCellDown()
            self.showLabels(true)
            self.setConstraints(for: .open)
            self.layoutIfNeeded()
        }
        
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        let timeSlice = 1.0 / Double(extraCells.count + 1)
        
        let actions = {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0, animations: action)
            
            extraCells.enumerated().forEach { index, cell in
                let startTime = (Double(index) + 1) * timeSlice
                UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: timeSlice, animations: {
                    cell.alpha = 1
                })
            }
        }
        
        
        if animated {
            UIView.animateKeyframes(withDuration: Constants.animationDuration, delay: 0, options: [.calculationModeCubic], animations: actions, completion: nil)
        }
        else {
            action()
            showExtraCells()
        }
    }
    
    func load() {
        resetCollection()
        setupContentView()
        setupFadeView()
        setupCollection()
        setupCells()
        bindCells()
        
        if showExpandCell {
            setupExpandCell()
            collapseCollection()
        }
    }
    
    func getCell(at index: Int) -> StyleMenuCell? {
        return cells.object(at: index)
    }
    
    func getIndex(for cell: StyleMenuCell) -> Int? {
        return cells.index(of: cell)
    }
    
    func reloadItem(at index: Int) {
        guard let cell = cells.object(at: index) else { return }
        delegate?.bindItem(at: index, cell: cell)
    }
    
    func showLabels(_ show: Bool, animated: Bool = false) {
        cells.forEach { cell in
            cell.showLabel(show, animated: animated)
        }
        
        expandCell.showLabel(show, animated: animated)
    }
    
    func showTemporalLabels() {
        showLabels(true, animated: false)
        setConstraints(for: .open)
        
        let timer = Timer(fire: .init(timeIntervalSinceNow: Constants.timerInterval), interval: 0, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.showLabels(false, animated: true)
            self.setConstraints(for: .closed)
            self.stopTimer()
        }
        timer.tolerance = 1.0
        RunLoop.current.add(timer, forMode: .common)
        self.labelTimer = timer
    }
    
    // MARK: - StyleMenuCellDelegate
    
    func didTap(cell: StyleMenuCell, recognizer: UITapGestureRecognizer) {
        delegate?.didSelect(cell: cell)
    }
    
    // MARK: - StyleMenuExpandCellDelegate
    
    func didTap(cell: StyleMenuExpandCell, recognizer: UITapGestureRecognizer) {
        switch state {
        case .open:
            collapseCollection(animated: true)
        case .closed:
            expandCollection(animated: true)
        }
    }
    
    // MARK: - IgnoreTouchesScrollViewDelegate
    
    func didTouchEmptySpace() {
        if state == .open {
            collapseCollection(animated: true)
        }
    }
}

private protocol IgnoreTouchesScrollViewDelegate: class {
    func didTouchEmptySpace()
}

private final class IgnoreTouchesScrollView: UIScrollView {
    
    weak var touchDelegate: IgnoreTouchesScrollViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            touchDelegate?.didTouchEmptySpace()
            return nil
        }
        else {
            return hitView
        }
    }
}
