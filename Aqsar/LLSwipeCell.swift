//
//  SlideTableCell.swift
//
//  Created by Eugen Ovchynnykov on 2/22/16.
//  Copyright © 2016 VoidCore. All rights reserved.
//

import UIKit

extension UIView {
    internal func parentViewOfClass<T>(_ type: T.Type) -> T? {
        if let view = superview as? T {
            return view
        }
        
        return superview?.parentViewOfClass(type)
    }
}

internal class OverlayView: UIView {
    weak var targetView: UIView?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        targetView?.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        targetView?.touchesCancelled(touches, with: event) // its important to cancel touch to proper unhighlight cell
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        targetView?.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        targetView?.touchesCancelled(touches, with: event)
    }
}

internal class SlideTableCellScrollView: UIScrollView, UIGestureRecognizerDelegate {
    weak var swipeCell: LLSwipeCell?
    
    override var contentSize: CGSize {
        didSet {
            swipeCell?.hideSwipeOptions(false)
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delaysContentTouches = true
        isDirectionalLockEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

internal class SlideButtonsGroupView: UIView {
    enum Side {
        case left
        case right
    }
    
    fileprivate var buttonsConstraints: [NSLayoutConstraint] = []
    fileprivate var widthConstraint: NSLayoutConstraint!
    
    fileprivate var side: Side = .right
    
    var buttons: [UIView] = [] {
        didSet {
            setupButton()
        }
    }
    
    init(side: Side) {
        self.side = side
        super.init(frame: CGRect.zero)
        
        widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        addConstraint(widthConstraint)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
           updateButtonConstraints()
        }
    }
    
    func updateButtonConstraints() {
        for (index, constraint) in buttonsConstraints.enumerated() {
            let offset = buttonOffsetForIndex(index)
            constraint.constant = offset*CGFloat(progress)
        }
    }
    
    func buttonOffsetForIndex(_ index: Int) -> CGFloat {
        var allButtons = buttons[buttons.startIndex..<buttons.startIndex.advanced(by: index)]
        if side == .left {
            allButtons = buttons[buttons.indices.suffix(from: buttons.startIndex.advanced(by: index + 1))]
        }
        
        let offset = allButtons.reduce(0.0) { sum, control in
            return sum + control.bounds.size.width
        }
        
        return side == .right ? offset : -offset
    }
    
    fileprivate func removeOldButtons() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        buttonsConstraints.removeAll()
    }
    
    func setupButton() {
        removeOldButtons()
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            
            if side == .right {
                addSubview(button)
            } else {
                insertSubview(button, at: 0)
            }
            
            let buttonWidth = button.bounds.size.width
            
            let buttonWidthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonWidth)
            button.addConstraint(buttonWidthConstraint)
            
            let views = ["button": button]
            let buttonVertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[button]-0-|", options: [], metrics: nil, views: views)
            addConstraints(buttonVertConstraint)
            
            let attr: NSLayoutAttribute = side == .right ? .leading : .trailing
            
            let cons = NSLayoutConstraint(item: button, attribute: attr, relatedBy: .equal, toItem: self, attribute: attr, multiplier: 1, constant: 0)
            addConstraint(cons)
            buttonsConstraints.append(cons)
        }
        
        widthConstraint.constant = buttons.reduce(0) { (sum, control)  in
            return sum + control.bounds.size.width
        }
    }
}


open class LLSwipeCell: UITableViewCell, UIScrollViewDelegate {
    fileprivate let cellScrollView = SlideTableCellScrollView()
    fileprivate weak var currentTableView: UITableView?
    
    @IBOutlet open var slideContentView: UIView!
    
    fileprivate var didSetupUI = false
    
    var tapGestureRecognizer = UITapGestureRecognizer()
    

    var leftXOffset: CGFloat {
        return leftButtonsContainerView.bounds.size.width
    }
    
    var rightXOffset: CGFloat {
        return rightButtonsContainerView.bounds.size.width
    }
    
    var startOffset: CGPoint {
        let leftOffset = leftButtonsContainerView.bounds.size.width
        return CGPoint(x: leftOffset, y: 0)
    }
    
    open var rightButtons: [UIView] = [] {
        didSet {
            appendButtons()
        }
    }
    open var leftButtons: [UIView] = [] {
        didSet {
            appendButtons()
        }
    }
    
    var rightTriggerOffset = 50
    var leftTriggerOffset = 50
    
    fileprivate let rightButtonsContainerView = SlideButtonsGroupView(side: .right)
    fileprivate var rightContainerTrailingConstraint: NSLayoutConstraint!
    
    fileprivate let leftButtonsContainerView = SlideButtonsGroupView(side: .left)
    fileprivate var leftContainerTrailingConstraint: NSLayoutConstraint!
    
    open var canOpenLeftButtons = true
    open var canOpenRightButtons = true
    
    open fileprivate(set) var showsLeftButtons = false
    open fileprivate(set) var showsRightButtons = false
    
    fileprivate func setupScrollView() {
        cellScrollView.swipeCell = self
        cellScrollView.delegate = self
        
        cellScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellScrollView)
        
        cellScrollView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.addTarget(self, action: #selector(LLSwipeCell.didTapScrollView(_:)))
        
        let views = ["cellScrollView": cellScrollView]
        let vertCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cellScrollView]-0-|", options: [], metrics: nil, views: views)
        contentView.addConstraints(vertCons)
        let horizCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cellScrollView]-0-|", options: [], metrics: nil, views: views)
        contentView.addConstraints(horizCons)
    }
    
    fileprivate func setupSlideContentView() {
        slideContentView.removeFromSuperview()
        cellScrollView.addSubview(slideContentView)
        slideContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["slideContentView": slideContentView]
        let vertCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[slideContentView]-0-|", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(vertCons)
        
        let heightConstraint = NSLayoutConstraint(item: slideContentView, attribute: .height, relatedBy: .equal, toItem: cellScrollView, attribute: .height, multiplier: 1, constant: 0)
        cellScrollView.addConstraint(heightConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: slideContentView, attribute: .width, relatedBy: .equal, toItem: cellScrollView, attribute: .width, multiplier: 1, constant: 0)
        cellScrollView.addConstraint(widthConstraint)
        
        
        let rightPlaceholderView = UIView()
        rightPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        cellScrollView.addSubview(rightPlaceholderView)
        rightPlaceholderView.backgroundColor = .clear
        cellScrollView.addConstraint(NSLayoutConstraint(item: rightPlaceholderView, attribute: .width, relatedBy: .equal, toItem: rightButtonsContainerView, attribute: .width, multiplier: 1, constant: 0))
        
        
        let leftPlaceholderView = UIView()
        leftPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        leftPlaceholderView.backgroundColor = .clear
        cellScrollView.addSubview(leftPlaceholderView)
        cellScrollView.addConstraint(NSLayoutConstraint(item: leftPlaceholderView, attribute: .width, relatedBy: .equal, toItem: leftButtonsContainerView, attribute: .width, multiplier: 1, constant: 0))
        
        
        let buttonViews = ["slideContentView": slideContentView,
                           "rightPlaceholderView": rightPlaceholderView,
                           "leftPlaceholderView": leftPlaceholderView]
        
        
        let hotizontalCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[leftPlaceholderView]-0-[slideContentView]-0-[rightPlaceholderView]-0-|", options: [], metrics: nil, views: buttonViews)
        cellScrollView.addConstraints(hotizontalCons)
    }
    
    
    fileprivate func setupOverlayView() {
        let overlay = OverlayView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.clear
        overlay.targetView = contentView
        slideContentView.insertSubview(overlay, at: 0)
        
        let views = ["overlayView": overlay]
        let vertCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[overlayView]-0-|", options: [], metrics: nil, views: views)
        slideContentView.addConstraints(vertCons)

        let hotizontalCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[overlayView]-0-|", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(hotizontalCons)
    }
    
    fileprivate func setupLeftGroupView() {
        cellScrollView.addSubview(leftButtonsContainerView)
        leftButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "leftButtonsContainerView": leftButtonsContainerView,
            "slideContentView": slideContentView
        ]
        
        let vertCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[leftButtonsContainerView]-0-|", options: [], metrics: nil, views: views)
        
        cellScrollView.addConstraints(vertCons)
        
        leftContainerTrailingConstraint = NSLayoutConstraint(item: leftButtonsContainerView, attribute: .leading, relatedBy: .equal, toItem: cellScrollView, attribute: .leading, multiplier: 1, constant: 0)
        
        cellScrollView.addConstraint(leftContainerTrailingConstraint)
    }
    
    fileprivate func setupRightGroupView() {
        cellScrollView.addSubview(rightButtonsContainerView)
        rightButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "rightButtonsContainerView": rightButtonsContainerView,
            "slideContentView": slideContentView
        ]
        
        let vertCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[rightButtonsContainerView]-0-|", options: [], metrics: nil, views: views)
        cellScrollView.addConstraints(vertCons)
        
        rightContainerTrailingConstraint = NSLayoutConstraint(item: rightButtonsContainerView, attribute: .trailing, relatedBy: .equal, toItem: cellScrollView, attribute: .trailing, multiplier: 1, constant: 0)
        
        cellScrollView.addConstraint(rightContainerTrailingConstraint)
    }
    
    fileprivate func setupUIIfNeeded() {
        precondition(slideContentView != nil, "slideContentView must be set before left or right buttons")
        if didSetupUI { return }
        didSetupUI = true
        
        setupScrollView()
        setupLeftGroupView()
        setupRightGroupView()
        
        setupSlideContentView()
        setupOverlayView()
    }
    
    open func expandLeftButtons(_ animated: Bool = true) {
        cellScrollView.setContentOffset(CGPoint.zero, animated: animated)
    }
    
    open func toggleLeftButtons(_ animated: Bool = true) {
        if showsLeftButtons {
            hideSwipeOptions(animated)
        } else {
            expandLeftButtons(animated)
        }
    }
    
    open func expandRightButtons(_ animated: Bool = true) {
        let rightOffset = rightButtonsContainerView.bounds.size.width
        let offset = CGPoint(x: startOffset.x + rightOffset, y: 0)
        cellScrollView.setContentOffset(offset, animated: animated)
    }
    
    open func toggleRightButtons(_ animated: Bool = true) {
        if showsRightButtons {
            hideSwipeOptions(animated)
        } else {
            expandRightButtons(animated)
        }
    }
    
    fileprivate func appendButtons() {
        setupUIIfNeeded()
        rightButtonsContainerView.buttons = rightButtons
        leftButtonsContainerView.buttons = leftButtons
        
        cellScrollView.layoutIfNeeded()
        
        hideSwipeOptions(false)
    }
    
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        currentTableView?.panGestureRecognizer.removeTarget(self, action: #selector(LLSwipeCell.didPanTableView(_:)))
        
        currentTableView = newSuperview?.parentViewOfClass(UITableView.self)
        currentTableView?.isDirectionalLockEnabled = true
        
        currentTableView?.panGestureRecognizer.addTarget(self, action: #selector(LLSwipeCell.didPanTableView(_:)))
    }
    
    @objc fileprivate func didPanTableView(_ rec: UIPanGestureRecognizer) {
        hideSwipeOptions()
    }
    
    @objc fileprivate func didTapScrollView(_ rec: UITapGestureRecognizer) {
        hideSwipeOptions()
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        hideSwipeOptions(false)
    }
    
    open override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    internal func hideSwipeOptions(_ animated: Bool = true) {
        let leftOffset = leftButtonsContainerView.bounds.size.width
        cellScrollView.setContentOffset(CGPoint(x: leftOffset, y: 0), animated: animated)
    }
    
    internal func targetOffset(_ currentOffset: CGPoint) -> CGPoint {
        if (currentOffset.x > leftXOffset + CGFloat(rightTriggerOffset)) {
            return CGPoint(x: leftXOffset + rightXOffset, y: 0)
        } else if (currentOffset.x < CGFloat(leftTriggerOffset)) {
            return CGPoint.zero
        }
        
        return CGPoint(x: leftXOffset, y: 0)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let offset = targetOffset(scrollView.contentOffset)
        targetContentOffset.pointee = offset
        
        if abs(velocity.x) > 0.1 {
            DispatchQueue.main.async {
                scrollView.setContentOffset(offset, animated: true)
            }
        }
    }
    
    fileprivate func updateGroupViewProgres() {
        let rightScrollOffset = cellScrollView.contentOffset.x - startOffset.x
        var rightProgress = rightScrollOffset > 0.0 ? rightScrollOffset / rightXOffset : 0.0
        
        rightProgress = min(1.0, max(0, rightProgress))
        rightButtonsContainerView.progress = rightProgress
        
        let leftScrollOffset = cellScrollView.contentOffset.x
        var leftProgress = leftScrollOffset > 0.0 ? leftScrollOffset / leftXOffset : 0.0
        
        leftProgress = min(1.0, max(0, 1-leftProgress))
        leftButtonsContainerView.progress = leftProgress
    }
    
    fileprivate var shouldHideLeftButtons: Bool {
       return cellScrollView.contentOffset.x < leftXOffset && (!canOpenLeftButtons && cellScrollView.contentOffset.x < leftXOffset && !showsLeftButtons || leftButtons.isEmpty)
    }
    
    fileprivate var shouldHideRightButtons: Bool {
        return cellScrollView.contentOffset.x > leftXOffset && (!canOpenRightButtons
            && !showsRightButtons || rightButtons.isEmpty)
    }
    
    fileprivate func upateConstraints() {
        leftContainerTrailingConstraint.constant = min(cellScrollView.contentOffset.x, 0)
        let leftOffset = cellScrollView.contentOffset.x - (leftButtonsContainerView.bounds.size.width + rightButtonsContainerView.bounds.size.width)
        
        rightContainerTrailingConstraint.constant = max(0, leftOffset)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateGroupViewProgres()
        upateConstraints()
        
        if (cellScrollView.isDragging && (shouldHideLeftButtons || shouldHideRightButtons)) {
            hideSwipeOptions(false)
        }
        
        showsRightButtons = (scrollView.contentOffset.x > startOffset.x) && !rightButtons.isEmpty
        showsLeftButtons = (scrollView.contentOffset.x < startOffset.x) && !leftButtons.isEmpty
        
        tapGestureRecognizer.isEnabled = showsLeftButtons || showsRightButtons

        tapGestureRecognizer.cancelsTouchesInView = tapGestureRecognizer.isEnabled
    }
}
