//
//  EasyTipView.swift
//
//  Created by Teodor Patraş
//  Source: https://github.com/teodorpatras/EasyTipView
//
//  Modified for Kanvas
//

import UIKit
import Foundation

public protocol EasyTipViewDelegate: AnyObject {
    func easyTipViewDidDismiss(_ tipView: EasyTipView)
}


// MARK: - Public methods extension

public extension EasyTipView {
    
    // MARK:- Class methods -
    
    /**
     Presents an EasyTipView pointing to a particular UIBarItem instance within the specified superview
     
     - parameter animated:    Pass true to animate the presentation.
     - parameter item:        The UIBarButtonItem or UITabBarItem instance which the EasyTipView will be pointing to.
     - parameter superview:   A view which is part of the UIBarButtonItem instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
     - parameter text:        The text to be displayed.
     - parameter preferences: The preferences which will configure the EasyTipView.
     - parameter delegate:    The delegate.
     */
    class func show(animated: Bool = true, forItem item: UIBarItem, withinSuperview superview: UIView? = nil, text: String, preferences: Preferences = EasyTipView.globalPreferences, delegate: EasyTipViewDelegate? = nil){
        
        if let view = item.view {
            show(animated: animated, forView: view, withinSuperview: superview, text: text, preferences: preferences, delegate: delegate)
        }
    }
    
    /**
     Presents an EasyTipView pointing to a particular UIView instance within the specified superview
     
     - parameter animated:    Pass true to animate the presentation.
     - parameter view:        The UIView instance which the EasyTipView will be pointing to.
     - parameter superview:   A view which is part of the UIView instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
     - parameter text:        The text to be displayed.
     - parameter preferences: The preferences which will configure the EasyTipView.
     - parameter delegate:    The delegate.
     */
    class func show(animated: Bool = true, forView view: UIView, withinSuperview superview: UIView? = nil, text: String, preferences: Preferences = EasyTipView.globalPreferences, delegate: EasyTipViewDelegate? = nil) {
        
        let ev = EasyTipView(text: text, preferences: preferences, delegate: delegate)
        ev.show(animated: animated, forView: view, withinSuperview: superview)
    }
    
    // MARK:- Instance methods -
    
    /**
     Presents an EasyTipView pointing to a particular UIBarItem instance within the specified superview
     
     - parameter animated:  Pass true to animate the presentation.
     - parameter item:      The UIBarButtonItem or UITabBarItem instance which the EasyTipView will be pointing to.
     - parameter superview: A view which is part of the UIBarButtonItem instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
     */
    func show(animated: Bool = true, forItem item: UIBarItem, withinSuperView superview: UIView? = nil) {
        if let view = item.view {
            show(animated: animated, forView: view, withinSuperview: superview)
        }
    }
    
    /**
     Presents an EasyTipView pointing to a particular UIView instance within the specified superview
     
     - parameter animated:  Pass true to animate the presentation.
     - parameter view:      The UIView instance which the EasyTipView will be pointing to.
     - parameter superview: A view which is part of the UIView instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
     */
    func show(animated: Bool = true, forView view: UIView, withinSuperview superview: UIView? = nil) {
        
        if let unwrappedSuperview = superview {
            precondition(view.hasSuperview(unwrappedSuperview), "The supplied superview <\(unwrappedSuperview)> is not a direct nor an indirect superview of the supplied reference view <\(view)>. The superview passed to this method should be a direct or an indirect superview of the reference view. To display the tooltip within the main window, ignore the superview parameter.")
            
        }
        
        guard let defaultView = view.superview else { return }
        let superview = superview ?? defaultView
        
        let initialTransform = preferences.animating.showInitialTransform
        let finalTransform = preferences.animating.showFinalTransform
        let initialAlpha = preferences.animating.showInitialAlpha
        let damping = preferences.animating.springDamping
        let velocity = preferences.animating.springVelocity
        
        presentingView = view
        arrange(withinSuperview: superview)
        
        transform = initialTransform
        alpha = initialAlpha
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        addGestureRecognizer(tap)
        
        superview.addSubview(self)
        
        let animations: () -> () = {
            self.transform = finalTransform
            self.alpha = 1
        }
        
        if animated {
            UIView.animate(withDuration: preferences.animating.showDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.curveEaseInOut], animations: animations, completion: nil)
        }
        else {
            animations()
        }
    }
    
    /**
     Dismisses the EasyTipView
     
     - parameter completion: Completion block to be executed after the EasyTipView is dismissed.
     */
    func dismiss(withCompletion completion: (() -> ())? = nil){
        
        let damping = preferences.animating.springDamping
        let velocity = preferences.animating.springVelocity
        
        UIView.animate(withDuration: preferences.animating.dismissDuration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.dismissTransform
            self.alpha = self.preferences.animating.dismissFinalAlpha
        }) { (finished) -> Void in
            completion?()
            self.delegate?.easyTipViewDidDismiss(self)
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
        }
    }
    
    /**
     Checks if the EasyTipView is being shown
     */
    func isVisible() -> Bool {
        return alpha > 0
    }
    
    /**
     Checks to see if view is within it's superview
     
     - parameter item:      The UIBarButtonItem or UITabBarItem instance which the EasyTipView will be pointing to.
     - parameter superview: A view which is part of the UIBarButtonItem instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
     */
    func itemIsInSuperView(forItem item: UIBarItem, withinSuperView superview: UIView) -> Bool {
        guard let view = item.view else { return false }
        return view.hasSuperview(superview)
    }
}

// MARK: - UIGestureRecognizerDelegate implementation

extension EasyTipView: UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return preferences.animating.dismissOnTap
    }
}

// MARK: - EasyTipView class implementation -

open class EasyTipView: UIView {
    
    // MARK:- Nested types -
    
    public enum ArrowPosition {
        case any
        case top
        case bottom
        case right
        case left
        
        static let allValues = [top, bottom, right, left]
    }
    
    public struct Preferences {
        
        public struct Drawing {
            public var cornerRadius                             = CGFloat(5)
            public var arrowHeight                              = CGFloat(5)
            public var arrowWidth                               = CGFloat(10)
            public var foregroundColor                          = UIColor.white
            public var backgroundColor                          = UIColor.red
            public var backgroundColorCollection: [UIColor]     = []
            public var arrowPosition                            = ArrowPosition.any
            public var textAlignment                            = NSTextAlignment.center
            public var borderWidth                              = CGFloat(0)
            public var borderColor                              = UIColor.clear
            public var font                                     = UIFont.systemFont(ofSize: 15)
        }
        
        public struct Positioning {
            public var bubbleHInset         = CGFloat(1)
            public var bubbleVInset         = CGFloat(1)
            public var textHInset           = CGFloat(10)
            public var textVInset           = CGFloat(10)
            public var maxWidth             = CGFloat(200)
            public var margin               = CGFloat(0)
        }
        
        public struct Animating {
            public var dismissTransform     = CGAffineTransform(scaleX: 0.1, y: 0.1)
            public var showInitialTransform = CGAffineTransform(scaleX: 0, y: 0)
            public var showFinalTransform   = CGAffineTransform.identity
            public var springDamping        = CGFloat(0.7)
            public var springVelocity       = CGFloat(0.7)
            public var showInitialAlpha     = CGFloat(0)
            public var dismissFinalAlpha    = CGFloat(0)
            public var showDuration         = 0.7
            public var dismissDuration      = 0.7
            public var dismissOnTap         = true
            public var gradientVelocity     = 10.0
        }
        
        public var drawing      = Drawing()
        public var positioning  = Positioning()
        public var animating    = Animating()
        public var hasBorder: Bool {
            return drawing.borderWidth > 0 && drawing.borderColor != UIColor.clear
        }
        
        public init() {}
    }
    
    // MARK:- Variables -
    
    override open var backgroundColor: UIColor? {
        didSet {
            guard let color = backgroundColor
                , color != UIColor.clear else {return}
            
            preferences.drawing.backgroundColor = color
            backgroundColor = UIColor.clear
        }
    }
    
    override open var description: String {
        let substrings = "'\(String(reflecting: Swift.type(of: self)))'".components(separatedBy: ".")
        
        let type = substrings.last ?? ""
        
        return "<< \(type) with text : '\(text)' >>"
    }
    
    private weak var presentingView: UIView?
    private weak var delegate: EasyTipViewDelegate?
    private var arrowTip = CGPoint.zero
    private(set) open var preferences: Preferences
    public let text: String
    
    // Gradient animation
    var gradientAnimation: CABasicAnimation?
    var gradientAnimationStartingTime: TimeInterval = 0
    
    
    // MARK: - Lazy variables -
    
    private lazy var textSize: CGSize = {
        
        [weak self] in

        guard let self = self else { return CGSize(width: 0, height: 0) }
        
        #if swift(>=4.2)
        var attributes = [NSAttributedString.Key.font: self.preferences.drawing.font]
        #else
        var attributes = [NSAttributedStringKey.font: self.preferences.drawing.font]
        #endif
        
        var textSize = self.text.boundingRect(with: CGSize(width: self.preferences.positioning.maxWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        if textSize.width < self.preferences.drawing.arrowWidth {
            textSize.width = self.preferences.drawing.arrowWidth
        }
        
        return textSize
        }()
    
    private lazy var contentSize: CGSize = {
        
        [weak self] in

        guard let self = self else { return CGSize(width: 0, height: 0) }
        
        var contentSize = CGSize(width: self.textSize.width + self.preferences.positioning.textHInset * 2 + self.preferences.positioning.bubbleHInset * 2, height: self.textSize.height + self.preferences.positioning.textVInset * 2 + self.preferences.positioning.bubbleVInset * 2 + self.preferences.drawing.arrowHeight)
        
        return contentSize
        }()
    
    // MARK: - Static variables -
    
    public static var globalPreferences = Preferences()
    
    // MARK:- Initializer -
    
    public init (text: String, preferences: Preferences = EasyTipView.globalPreferences, delegate: EasyTipViewDelegate? = nil){
        
        self.text = text
        self.preferences = preferences
        self.delegate = delegate
        
        super.init(frame: CGRect.zero)
        
        self.alpha = 0
        self.backgroundColor = UIColor.clear
        
        #if swift(>=4.2)
        let notificationName = UIDevice.orientationDidChangeNotification
        #else
        let notificationName = NSNotification.Name.UIDeviceOrientationDidChange
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRotation), name: notificationName, object: nil)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     NSCoding not supported. Use init(text, preferences, delegate) instead!
     */
    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported. Use init(text, preferences, delegate) instead!")
    }
    
    // MARK: - Rotation support -
    
    @objc func handleRotation() {
        guard let sview = superview
            , presentingView != nil else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.arrange(withinSuperview: sview)
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Private methods -
    
    private func computeFrame(arrowPosition position: ArrowPosition, refViewFrame: CGRect, superviewFrame: CGRect, margin: CGFloat) -> CGRect {
        var xOrigin: CGFloat = 0
        var yOrigin: CGFloat = 0
        
        switch position {
        case .top, .any:
            xOrigin = refViewFrame.centerPoint.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height + margin
        case .bottom:
            xOrigin = refViewFrame.centerPoint.x - contentSize.width / 2
            yOrigin = refViewFrame.y - contentSize.height - margin
        case .right:
            xOrigin = refViewFrame.x - contentSize.width - margin
            yOrigin = refViewFrame.centerPoint.y - contentSize.height / 2
        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width + margin
            yOrigin = refViewFrame.y - contentSize.height / 2
        }
        
        var frame = CGRect(x: xOrigin, y: yOrigin, width: contentSize.width, height: contentSize.height)
        adjustFrame(&frame, forSuperviewFrame: superviewFrame)
        return frame
    }
    
    private func adjustFrame(_ frame: inout CGRect, forSuperviewFrame superviewFrame: CGRect) {
        
        // adjust horizontally
        if frame.x < 0 {
            frame.x =  0
        }
        else if frame.maxX > superviewFrame.width {
            frame.x = superviewFrame.width - frame.width
        }
        
        //adjust vertically
        if frame.y < 0 {
            frame.y = 0
        }
        else if frame.maxY > superviewFrame.maxY {
            frame.y = superviewFrame.height - frame.height
        }
    }
    
    private func isFrameValid(_ frame: CGRect, forRefViewFrame: CGRect, withinSuperviewFrame: CGRect) -> Bool {
        return !frame.intersects(forRefViewFrame)
    }
    
    private func arrange(withinSuperview superview: UIView) {
        
        var position = preferences.drawing.arrowPosition
        
        guard let presentingView = presentingView else { return }
        let refViewFrame = presentingView.convert(presentingView.bounds, to: superview)
        
        let superviewFrame: CGRect
        if let scrollview = superview as? UIScrollView {
            superviewFrame = CGRect(origin: scrollview.frame.origin, size: scrollview.contentSize)
        }
        else {
            superviewFrame = superview.frame
        }
        
        let margin = preferences.positioning.margin
        
        var frame = computeFrame(arrowPosition: position, refViewFrame: refViewFrame, superviewFrame: superviewFrame, margin: margin)
        
        if !isFrameValid(frame, forRefViewFrame: refViewFrame, withinSuperviewFrame: superviewFrame) {
            for value in ArrowPosition.allValues where value != position {
                let newFrame = computeFrame(arrowPosition: value, refViewFrame: refViewFrame, superviewFrame: superviewFrame, margin: margin)
                if isFrameValid(newFrame, forRefViewFrame: refViewFrame, withinSuperviewFrame: superviewFrame) {
                    
                    if position != .any {
                        print("[EasyTipView - Info] The arrow position you chose <\(position)> could not be applied. Instead, position <\(value)> has been applied! Please specify position <\(ArrowPosition.any)> if you want EasyTipView to choose a position for you.")
                    }
                    
                    frame = newFrame
                    position = value
                    preferences.drawing.arrowPosition = value
                    break
                }
            }
        }
        
        var arrowTipXOrigin: CGFloat
        
        switch position {
        case .bottom, .top, .any:
            if frame.width < refViewFrame.width {
                arrowTipXOrigin = contentSize.width / 2
            }
            else {
                arrowTipXOrigin = abs(frame.x - refViewFrame.x) + refViewFrame.width / 2
            }
            
            arrowTip = CGPoint(x: arrowTipXOrigin, y: position == .bottom ? contentSize.height - preferences.positioning.bubbleVInset :  preferences.positioning.bubbleVInset)
        case .right, .left:
            if frame.height < refViewFrame.height {
                arrowTipXOrigin = contentSize.height / 2
            }
            else {
                arrowTipXOrigin = abs(frame.y - refViewFrame.y) + refViewFrame.height / 2
            }
            
            arrowTip = CGPoint(x: preferences.drawing.arrowPosition == .left ? preferences.positioning.bubbleVInset : contentSize.width - preferences.positioning.bubbleVInset, y: arrowTipXOrigin)
        }
        self.frame = frame
    }
    
    // MARK:- Callbacks -
    
    @objc func handleTap() {
        dismiss()
    }
    
    // MARK:- Drawing -
    
    private func drawBubble(_ bubbleFrame: CGRect, arrowPosition: ArrowPosition,  context: CGContext) {
        
        let arrowWidth = preferences.drawing.arrowWidth
        let arrowHeight = preferences.drawing.arrowHeight
        let cornerRadius = preferences.drawing.cornerRadius
        
        let contourPath = CGMutablePath()
        
        contourPath.move(to: CGPoint(x: arrowTip.x, y: arrowTip.y))
        
        switch arrowPosition {
        case .bottom, .top, .any:
            
            contourPath.addLine(to: CGPoint(x: arrowTip.x - arrowWidth / 2, y: arrowTip.y + (arrowPosition == .bottom ? -1 : 1) * arrowHeight))
            if arrowPosition == .bottom {
                drawBubbleBottomShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }
            else {
                drawBubbleTopShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }
            contourPath.addLine(to: CGPoint(x: arrowTip.x + arrowWidth / 2, y: arrowTip.y + (arrowPosition == .bottom ? -1 : 1) * arrowHeight))
            
        case .right, .left:
            
            contourPath.addLine(to: CGPoint(x: arrowTip.x + (arrowPosition == .right ? -1 : 1) * arrowHeight, y: arrowTip.y - arrowWidth / 2))
            
            if arrowPosition == .right {
                drawBubbleRightShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }
            else {
                drawBubbleLeftShape(bubbleFrame, cornerRadius: cornerRadius, path: contourPath)
            }
            
            contourPath.addLine(to: CGPoint(x: arrowTip.x + (arrowPosition == .right ? -1 : 1) * arrowHeight, y: arrowTip.y + arrowWidth / 2))
        }
        
        contourPath.closeSubpath()
        context.addPath(contourPath)
        context.clip()
        
        paintBubble(contourPath)
        
        if preferences.hasBorder {
            drawBorder(contourPath, context: context)
        }
    }
    
    private func drawBubbleBottomShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
    }
    
    private func drawBubbleTopShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
    }
    
    private func drawBubbleRightShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.height), radius: cornerRadius)
        
    }
    
    private func drawBubbleLeftShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
    }
    
    private func paintBubble(_ path: CGMutablePath) {
        let colors: [CGColor]
        if preferences.drawing.backgroundColorCollection.isEmpty {
            colors = [preferences.drawing.backgroundColor.cgColor]
        }
        else {
            colors = preferences.drawing.backgroundColorCollection.map { $0.cgColor }
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors + colors
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = createStartingValues(for: colors)
        let animation = getAnimation(colors: colors)
        gradient.removeAllAnimations()
        gradient.add(animation, forKey: nil)
        
        let shape = CAShapeLayer()
        shape.path = path
        gradient.mask = shape
        
        let backView = UIView(frame: bounds)
        backView.layer.addSublayer(gradient)
        addSubview(backView)
    }
    
    private func getAnimation(colors: [CGColor]) -> CABasicAnimation {
        if let animation = gradientAnimation {
            animation.timeOffset = layer.convertTime(CACurrentMediaTime() - gradientAnimationStartingTime, to: nil)
            return animation
        }
        else {
            let animation = createAnimation(colors: colors)
            gradientAnimation = animation
            return animation
        }
    }
    
    private func createAnimation(colors: [CGColor]) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = createStartingValues(for: colors)
        animation.toValue = createEndingValues(for: colors)
        animation.duration = preferences.animating.gradientVelocity
        animation.repeatCount = Float.infinity
        gradientAnimationStartingTime = CACurrentMediaTime()
        return animation
    }
    
    private func createStartingValues(for list: [Any]) -> [NSNumber] {
        let size = Double(list.count)
        let step = 0.5
        let gradientPositions = stride(from: -step * size, to: step * size, by: step)
        return gradientPositions.map { NSNumber(value: $0) }
    }
    
    private func createEndingValues(for list: [Any]) -> [NSNumber] {
        let size = Double(list.count)
        let step = 0.5
        let gradientPositions = stride(from: 0, to: step * size * 2, by: step)
        return gradientPositions.map { NSNumber(value: $0) }
    }
    
    private func drawBorder(_ borderPath: CGPath, context: CGContext) {
        context.addPath(borderPath)
        context.setStrokeColor(preferences.drawing.borderColor.cgColor)
        context.setLineWidth(preferences.drawing.borderWidth)
        context.strokePath()
    }
    
    private func drawText(_ bubbleFrame: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = preferences.drawing.textAlignment
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let textRect = CGRect(x: bubbleFrame.origin.x + (bubbleFrame.size.width - textSize.width) / 2, y: bubbleFrame.origin.y + (bubbleFrame.size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        
        let textView = UIView(frame: textRect)
        addSubview(textView)
        
        let label = UILabel(frame: textView.bounds)
        textView.addSubview(label)
        
        #if swift(>=4.2)
        let attributes = [NSAttributedString.Key.font: preferences.drawing.font, NSAttributedString.Key.foregroundColor: preferences.drawing.foregroundColor, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        label.attributedText = attributedString
        #else
        let attributes = [NSAttributedStringKey.font: preferences.drawing.font, NSAttributedStringKey.foregroundColor: preferences.drawing.foregroundColor, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        label.attributedText = attributes
        label.text = text
        #endif
    }
    
    override open func draw(_ rect: CGRect) {
        
        let arrowPosition = preferences.drawing.arrowPosition
        let bubbleWidth: CGFloat
        let bubbleHeight: CGFloat
        let bubbleXOrigin: CGFloat
        let bubbleYOrigin: CGFloat
        switch arrowPosition {
        case .bottom, .top, .any:
            
            bubbleWidth = contentSize.width - 2 * preferences.positioning.bubbleHInset
            bubbleHeight = contentSize.height - 2 * preferences.positioning.bubbleVInset - preferences.drawing.arrowHeight
            
            bubbleXOrigin = preferences.positioning.bubbleHInset
            bubbleYOrigin = arrowPosition == .bottom ? preferences.positioning.bubbleVInset : preferences.positioning.bubbleVInset + preferences.drawing.arrowHeight
            
        case .left, .right:
            
            bubbleWidth = contentSize.width - 2 * preferences.positioning.bubbleHInset - preferences.drawing.arrowHeight
            bubbleHeight = contentSize.height - 2 * preferences.positioning.bubbleVInset
            
            bubbleXOrigin = arrowPosition == .right ? preferences.positioning.bubbleHInset: preferences.positioning.bubbleHInset + preferences.drawing.arrowHeight
            bubbleYOrigin = preferences.positioning.bubbleVInset
            
        }
        let bubbleFrame = CGRect(x: bubbleXOrigin, y: bubbleYOrigin, width: bubbleWidth, height: bubbleHeight)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        
        drawBubble(bubbleFrame, arrowPosition: preferences.drawing.arrowPosition, context: context)
        drawText(bubbleFrame)
        
        context.restoreGState()
    }
}

// MARK: - UIBarItem extension -
extension UIBarItem {
    var view: UIView? {
        if let item = self as? UIBarButtonItem, let customView = item.customView {
            return customView
        }
        return self.value(forKey: "view") as? UIView
    }
}

// MARK:- UIView extension -
extension UIView {
    
    func hasSuperview(_ superview: UIView) -> Bool{
        return viewHasSuperview(self, superview: superview)
    }
    
    private func viewHasSuperview(_ view: UIView, superview: UIView) -> Bool {
        if let sview = view.superview {
            if sview === superview {
                return true
            }
            else {
                return viewHasSuperview(sview, superview: superview)
            }
        }
        else {
            return false
        }
    }
}

// MARK:- CGRect extension -
extension CGRect {
    
    var centerPoint: CGPoint {
        return CGPoint(x: self.x + self.width / 2, y: self.y + self.height / 2)
    }
    
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return self.origin.y
        }
        
        set {
            self.origin.y = newValue
        }
    }
}
