//
//  EasyTipView.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 13/02/2019.
//

import UIKit
import Foundation

public protocol EasyTipViewDelegate: class {
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
    public class func show(animated: Bool = true, forItem item: UIBarItem, withinSuperview superview: UIView? = nil, text: String, preferences: Preferences = EasyTipView.globalPreferences, delegate: EasyTipViewDelegate? = nil){
        
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
    public class func show(animated: Bool = true, forView view: UIView, withinSuperview superview: UIView? = nil, text: String, preferences: Preferences = EasyTipView.globalPreferences, delegate: EasyTipViewDelegate? = nil) {
        
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
    public func show(animated: Bool = true, forItem item: UIBarItem, withinSuperView superview: UIView? = nil) {
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
    public func show(animated: Bool = true, forView view: UIView, withinSuperview superview: UIView? = nil) {
        
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
    public func dismiss(withCompletion completion: (() -> ())? = nil){
        
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
    
    fileprivate weak var presentingView: UIView?
    fileprivate weak var delegate: EasyTipViewDelegate?
    fileprivate var arrowTip = CGPoint.zero
    fileprivate(set) open var preferences: Preferences
    public let text: String
    
    // MARK: - Lazy variables -
    
    fileprivate lazy var textSize: CGSize = {
        
        [unowned self] in
        
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
    
    fileprivate lazy var contentSize: CGSize = {
        
        [unowned self] in
        
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
    
    fileprivate func computeFrame(arrowPosition position: ArrowPosition, refViewFrame: CGRect, superviewFrame: CGRect, margin: CGFloat) -> CGRect {
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
    
    fileprivate func adjustFrame(_ frame: inout CGRect, forSuperviewFrame superviewFrame: CGRect) {
        
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
    
    fileprivate func isFrameValid(_ frame: CGRect, forRefViewFrame: CGRect, withinSuperviewFrame: CGRect) -> Bool {
        return !frame.intersects(forRefViewFrame)
    }
    
    fileprivate func arrange(withinSuperview superview: UIView) {
        
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
    
    fileprivate func drawBubble(_ bubbleFrame: CGRect, arrowPosition: ArrowPosition,  context: CGContext) {
        
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
        
        paintBubble(context)
        
        if preferences.hasBorder {
            drawBorder(contourPath, context: context)
        }
    }
    
    fileprivate func drawBubbleBottomShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
    }
    
    fileprivate func drawBubbleTopShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
    }
    
    fileprivate func drawBubbleRightShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.height), radius: cornerRadius)
        
    }
    
    fileprivate func drawBubbleLeftShape(_ frame: CGRect, cornerRadius: CGFloat, path: CGMutablePath) {
        
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y), tangent2End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x + frame.width, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y + frame.height), radius: cornerRadius)
        path.addArc(tangent1End: CGPoint(x: frame.x, y: frame.y + frame.height), tangent2End: CGPoint(x: frame.x, y: frame.y), radius: cornerRadius)
    }
    
    fileprivate func paintBubble(_ context: CGContext) {
        let backgroundColor = getBackgroundColor()
        context.setFillColor(backgroundColor.cgColor)
        context.fill(bounds)
    }
    
    fileprivate func getBackgroundColor() -> UIColor {
        if preferences.drawing.backgroundColorCollection.isEmpty {
            return preferences.drawing.backgroundColor
        }
        else {
            let colors = preferences.drawing.backgroundColorCollection
            return createColorFromGradient(frame: bounds, colors: colors)
        }
    }
    
    fileprivate func createColorFromGradient(frame: CGRect, colors: [UIColor], defaultColor: UIColor = .red) -> UIColor {
        // create the background layer that will hold the gradient
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        backgroundGradientLayer.frame = frame
        
        // we create an array of CG colors from out UIColor array
        let cgColors = colors.map {$0.cgColor}
        backgroundGradientLayer.colors = cgColors

        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        guard let graphicsContext = UIGraphicsGetCurrentContext() else { return defaultColor }
        backgroundGradientLayer.render(in: graphicsContext)
        guard let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext() else { return defaultColor }
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: backgroundColorImage)
    }
    
    fileprivate func drawBorder(_ borderPath: CGPath, context: CGContext) {
        context.addPath(borderPath)
        context.setStrokeColor(preferences.drawing.borderColor.cgColor)
        context.setLineWidth(preferences.drawing.borderWidth)
        context.strokePath()
    }
    
    fileprivate func drawText(_ bubbleFrame: CGRect, context: CGContext) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = preferences.drawing.textAlignment
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        
        let textRect = CGRect(x: bubbleFrame.origin.x + (bubbleFrame.size.width - textSize.width) / 2, y: bubbleFrame.origin.y + (bubbleFrame.size.height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        
        #if swift(>=4.2)
        let attributes = [NSAttributedString.Key.font: preferences.drawing.font, NSAttributedString.Key.foregroundColor: preferences.drawing.foregroundColor, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        #else
        let attributes = [NSAttributedStringKey.font : preferences.drawing.font, NSAttributedStringKey.foregroundColor: preferences.drawing.foregroundColor, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        #endif
        
        text.draw(in: textRect, withAttributes: attributes)
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
        context.saveGState ()
        
        drawBubble(bubbleFrame, arrowPosition: preferences.drawing.arrowPosition, context: context)
        drawText(bubbleFrame, context: context)
        
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
    
    fileprivate func viewHasSuperview(_ view: UIView, superview: UIView) -> Bool {
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
