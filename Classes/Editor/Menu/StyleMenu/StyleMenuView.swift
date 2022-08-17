//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for cell binding and touch events.
protocol StyleMenuViewDelegate: AnyObject {
    
    /// Called to obtain the size of the collection.
    func numberOfItems() -> Int
    
    /// Called to bind a cell to an option.
    ///
    /// - Parameters
    ///  - index: the position of the cell in the collection.
    ///  - cell: the collection cell.
    func bindItem(at index: Int, cell: StyleMenuCell)
    
    /// Callback method when selecting a cell.
    ///
    /// - Parameter cell: the cell that was tapped.
    func didSelect(cell: StyleMenuCell)
}

/// Constants for the view
private struct Constants {
    static let animationDuration: TimeInterval = 0.3
    static let maxVisibleCells: Int = 3
    static let timerInterval: TimeInterval = 3
    static let horizontalPadding: CGFloat = 16
}

/// State of the menu.
private enum State {
    case expanded
    case collapsed
}

/// View for StyleMenuController.
final class StyleMenuView: IgnoreTouchesView, StyleMenuCellDelegate, StyleMenuExpandCellDelegate, StyleMenuScrollViewDelegate {
    
    private weak var delegate: StyleMenuViewDelegate?
    
    private var state: State
    private let scrollView: StyleMenuScrollView
    private let scrollViewContent: IgnoreTouchesView
    private let contentView: IgnoreTouchesView
    private let itemsView: IgnoreTouchesView
    private var cells: [StyleMenuCell]
    private let expandCell: StyleMenuExpandCell
    private var labelTimer: Timer?
    
    
    private var showExpandCell: Bool {
        guard let delegate = delegate else { return false }
        return delegate.numberOfItems() > Constants.maxVisibleCells
    }
    
    private lazy var contentHeightConstraint: NSLayoutConstraint = {
        contentView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    private lazy var itemsViewHeightConstraint: NSLayoutConstraint = {
        itemsView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    private lazy var menuOpenContentViewWidthConstraint: NSLayoutConstraint = {
        contentView.trailingAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.trailingAnchor)
    }()
    
    private lazy var menuClosedContentViewWidthConstraint: NSLayoutConstraint = {
        contentView.widthAnchor.constraint(equalToConstant: StyleMenuCell.iconWidth)
    }()
    
    // MARK: - Initializers
    
    init(delegate: StyleMenuViewDelegate) {
        self.delegate = delegate
        self.scrollView = StyleMenuScrollView()
        self.scrollViewContent = IgnoreTouchesView()
        self.contentView = IgnoreTouchesView()
        self.itemsView = IgnoreTouchesView()
        self.expandCell = StyleMenuExpandCell()
        self.cells = []
        self.state = .collapsed
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
            scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
        ])
    }
    
    /// Sets up the view that contains the actual cells and the expand/collapse cell.
    private func setupContentView() {
        guard let delegate = delegate else { return }
        
        scrollViewContent.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let numberOfItems = CGFloat(delegate.numberOfItems())
        
        let itemHeight: CGFloat = numberOfItems * StyleMenuCell.height
        let expandCellHeight = StyleMenuExpandCell.height
        let contentHeight: CGFloat = showExpandCell ? (itemHeight + expandCellHeight) : itemHeight
        
        contentHeightConstraint.constant = contentHeight
        NSLayoutConstraint.activate([
            contentHeightConstraint,
            contentView.centerYAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollViewContent.safeAreaLayoutGuide.leadingAnchor),
        ])
        
        setConstraints(for: .expanded)
    }
    
    /// Sets up the view that contains the actual item cells.
    private func setupItemsView() {
        guard let delegate = delegate else { return }
        
        contentView.addSubview(itemsView)
        itemsView.translatesAutoresizingMaskIntoConstraints = false
        
        let numberOfItems = CGFloat(delegate.numberOfItems())
        let contentHeight: CGFloat = numberOfItems * StyleMenuCell.height
        
        itemsViewHeightConstraint.constant = contentHeight
        NSLayoutConstraint.activate([
            itemsViewHeightConstraint,
            itemsView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            itemsView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            itemsView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    /// Adds cells in the collection.
    private func setupCollection() {
        guard let delegate = delegate else { return }
        
        for _ in 0..<delegate.numberOfItems() {
            let cell = StyleMenuCell()
            itemsView.addSubview(cell)
            cells.append(cell)
        }
    }
    
    /// Adds constraints to the cells.
    private func setupCells() {
        guard let delegate = delegate else { return }
        
        for index in 0..<delegate.numberOfItems() {
            let cell = cells[index]
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.clipsToBounds = true
            cell.delegate = self
            
            let topOffset: CGFloat = StyleMenuCell.height * CGFloat(index)
            NSLayoutConstraint.activate([
                cell.topAnchor.constraint(equalTo: itemsView.safeAreaLayoutGuide.topAnchor, constant: topOffset),
                cell.leadingAnchor.constraint(equalTo: itemsView.safeAreaLayoutGuide.leadingAnchor),
                cell.heightAnchor.constraint(equalToConstant: StyleMenuCell.height),
            ])
        }
    }
    
    /// Adds the cell that allows to expand/collapse the collection.
    private func setupExpandCell() {
        contentView.addSubview(expandCell)
        expandCell.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expandCell.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            expandCell.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            expandCell.heightAnchor.constraint(equalToConstant: StyleMenuExpandCell.height),
        ])
    }
    
    /// Binds the cells to the options.
    private func bindCells() {
        guard let delegate = delegate else { return }
        
        for (index, cell) in cells.enumerated() {
            delegate.bindItem(at: index, cell: cell)
        }
    }
    
    /// Resets the collection by removing the cells and their containers.
    private func resetCollection() {
        expandCell.removeFromSuperview()
        
        cells.forEach { cell in
            cell.removeFromSuperview()
        }
        
        cells.removeAll()
        
        itemsViewHeightConstraint.constant = 0
        itemsView.removeFromSuperview()
        
        contentHeightConstraint.constant = 0
        contentView.removeFromSuperview()
    }
    
    /// Invalidates and removes the current timer.
    private func stopTimer() {
        labelTimer?.invalidate()
        labelTimer = nil
    }
    
    // MARK: - Expand & Collapse
    
    /// Hides the extra cells that should not be shown when the collection is collapsed.
    private func hideExtraCells() {
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        extraCells.forEach {
            $0.alpha = 0
        }
    }
    
    /// Shows the extra cells that should be shown when the collection is expanded.
    private func showExtraCells() {
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        extraCells.forEach {
            $0.alpha = 1
        }
    }
    
    /// Changes the width constraints of the cell container in order to allow or not touches on the 'label' area.
    ///
    /// - Parameter state: whether the collection is expanded or collapsed.
    private func setConstraints(for state: State) {
        switch state {
        case .expanded:
            menuOpenContentViewWidthConstraint.isActive = true
            menuClosedContentViewWidthConstraint.isActive = false
        case .collapsed:
            menuOpenContentViewWidthConstraint.isActive = false
            menuClosedContentViewWidthConstraint.isActive = true
        }
    }
    
    /// Changes the height constraints to keep the content centered when the collection is collapsed.
    private func moveExpandCellUp() {
        contentHeightConstraint.constant = StyleMenuCell.height * CGFloat(Constants.maxVisibleCells) + StyleMenuExpandCell.height
        itemsViewHeightConstraint.constant = StyleMenuCell.height * CGFloat(Constants.maxVisibleCells)
    }
    
    /// Changes the height constraints to keep the content centered when the collection is expanded.
    private func moveExpandCellDown() {
        guard let delegate = delegate else { return }
        contentHeightConstraint.constant = StyleMenuCell.height * CGFloat(delegate.numberOfItems()) + StyleMenuExpandCell.height
        itemsViewHeightConstraint.constant = StyleMenuCell.height * CGFloat(delegate.numberOfItems())
    }
    
    // MARK: - Public interface
    
    /// Collapses the collection.
    ///
    /// - Parameter animated: whether to animate the transition or not.
    func collapseCollection(animated: Bool = false) {
        state = .collapsed
        stopTimer()
        
        let action: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.expandCell.rotateDown()
            self.moveExpandCellUp()
            self.showLabels(false)
            self.setConstraints(for: .collapsed)
            self.layoutIfNeeded()
        }
        
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        let timeSlice = 1.0 / Double(extraCells.count + 1) // The 'ExpandCell' is also counted
        
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
    
    /// Expands the collection.
    ///
    /// - Parameter animated: whether to animate the transition or not.
    func expandCollection(animated: Bool = false) {
        state = .expanded
        expandCell.changeLabel(to: NSLocalizedString("EditorClose", comment: "Label for the 'Close' option in the editor tools"))
        stopTimer()
        
        let action: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.expandCell.rotateUp()
            self.moveExpandCellDown()
            self.showLabels(true)
            self.setConstraints(for: .expanded)
            self.layoutIfNeeded()
        }
        
        let extraCells = cells[Constants.maxVisibleCells..<cells.count]
        let timeSlice = 1.0 / Double(extraCells.count + 1) // The 'ExpandCell' is also counted
        
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
    
    /// Loads the content of the collection.
    func load() {
        resetCollection()
        setupContentView()
        setupItemsView()
        setupCollection()
        setupCells()
        bindCells()
        
        if showExpandCell {
            setupExpandCell()
            collapseCollection()
        }
    }
    
    /// Obtains a cell by its index.
    ///
    /// - Parameter index: the position of the cell in the collection.
    func getCell(at index: Int) -> StyleMenuCell? {
        return cells.object(at: index)
    }
    
    /// Obtains the index of a cell in the collection.
    ///
    /// - Parameter cell: the cell.
    func getIndex(for cell: StyleMenuCell) -> Int? {
        return cells.firstIndex(of: cell)
    }
    
    /// Reloads a specific cell.
    ///
    /// - Parameter index: the position of the cell in the collection.
    func reloadItem(at index: Int) {
        guard let cell = cells.object(at: index) else { return }
        delegate?.bindItem(at: index, cell: cell)
    }
    
    /// Shows or hides the labels next to the cells.
    ///
    /// - Parameters
    ///  - show: true to show, false to hide.
    ///  - animated: whether to animate the transition or not.
    func showLabels(_ show: Bool, animated: Bool = false) {
        cells.forEach { cell in
            cell.showLabel(show, animated: animated)
        }
        
        expandCell.showLabel(show, animated: animated)
    }
    
    /// Shows the labels for a period of time and then hides them.
    func showTemporalLabels() {
        showLabels(true, animated: false)
        setConstraints(for: .expanded)
        
        let timer = Timer(fire: .init(timeIntervalSinceNow: Constants.timerInterval), interval: 0, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.showLabels(false, animated: true)
            self.setConstraints(for: .collapsed)
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
        case .expanded:
            collapseCollection(animated: true)
        case .collapsed:
            expandCollection(animated: true)
        }
    }
    
    // MARK: - IgnoreTouchesScrollViewDelegate
    
    func didTouchEmptySpace() {
        if state == .expanded {
            collapseCollection(animated: true)
        }
    }
}

/// Protocol for touch events.
private protocol StyleMenuScrollViewDelegate: AnyObject {
    
    /// Called when the scroll view is touched outside its content.
    func didTouchEmptySpace()
}

/// Scroll view that detects touches outside its content.
private final class StyleMenuScrollView: UIScrollView {
    
    weak var touchDelegate: StyleMenuScrollViewDelegate?
    
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
