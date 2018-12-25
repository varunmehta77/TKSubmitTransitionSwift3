import Foundation
import UIKit

@IBDesignable
open class TKTransitionSubmitButton : UIButton, UIViewControllerTransitioningDelegate, CAAnimationDelegate, StartStopAnimationDelegate {
    
    func canStopAnimation() {
        canStop = true
        if (!isAnimating) {
            stopAnimation()
        }
    }
    
    func canStartAnimation() {
        canStop = false
    }
    
    open func stopAnimation() {
        self.setTitle(self.cachedTitle, for: .normal)
        self.expandButton()
        self.spiner.stopAnimation()
        self.isAnimating = false
        self.layer.cornerRadius = self.cornerRadius
    }
    
    lazy var spiner: SpinerLayer! = {
        let s = SpinerLayer(frame: self.frame)
        self.layer.addSublayer(s)
        s.spinnerDelegate = self
        return s
    }()
    
    
    @IBInspectable open var spinnerColor: UIColor = UIColor.white {
        didSet {
            spiner.spinnerColor = spinnerColor
        }
    }
    
    //Normal state bg and border
    @IBInspectable var normalBorderColor: UIColor? {
        didSet {
            layer.borderColor = normalBorderColor?.cgColor
        }
    }
    
    @IBInspectable var normalBackgroundColor: UIColor? {
        didSet {
            setBgColorForState(color: normalBackgroundColor, forState: .normal)
        }
    }
    
    
    //Highlighted state bg and border
    @IBInspectable var highlightedBorderColor: UIColor?
    
    @IBInspectable var highlightedBackgroundColor: UIColor? {
        didSet {
            setBgColorForState(color: highlightedBackgroundColor, forState: .highlighted)
        }
    }
    
    private func setBgColorForState(color: UIColor?, forState: UIControl.State){
        if color != nil {
            setBackgroundImage(UIImage.imageWithColor(color: color!), for: forState)
            
        } else {
            setBackgroundImage(nil, for: forState)
        }
    }
    
    open var didEndFinishAnimation : (()->())? = nil
    open var isAnimating = false
    open var cornerRadius: CGFloat = 0
    open var width: CGFloat = 0
    
    let springGoEase = CAMediaTimingFunction(controlPoints: 0.45, -0.36, 0.44, 0.92)
    let shrinkCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    let expandCurve = CAMediaTimingFunction(controlPoints: 0.95, 0.02, 1, 0.05)
    let shrinkDuration: CFTimeInterval  = 0.1
    
    open var normalCornerRadius:CGFloat? = 0.0 {
        didSet {
            self.layer.cornerRadius = normalCornerRadius!
        }
    }
    
    var cachedTitle: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.spiner.calculate(frame: self.bounds)
    }
    
    func setup() {
        self.clipsToBounds = true
        spiner.spinnerColor = spinnerColor
    }
    
    open func startLoadingAnimation() {
        if self.spiner == nil {
            self.spiner = SpinerLayer(frame: self.frame)
        }
        self.width = self.frame.width
        self.isAnimating = true
        self.cornerRadius = self.layer.cornerRadius
        self.cachedTitle = title(for: UIControl.State())
        self.setTitle("", for: UIControl.State())
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layer.cornerRadius = self.frame.height / 2
        }, completion: { (done) -> Void in
            self.shrink()
            _ = Timer.schedule(delay: self.shrinkDuration - 0.25) { _ in
                self.spiner.animation()
            }
        })
        
    }
    
    open func startFinishAnimation(_ delay: TimeInterval, completion:(()->())?) {
        _ = Timer.schedule(delay: delay) { _ in
            self.didEndFinishAnimation = completion
            self.expand()
            self.spiner.stopAnimation()
            self.isAnimating = false
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    private var canStop : Bool = false
    
    open func animate(_ duration: TimeInterval, completion:(()->())?) {
        startLoadingAnimation()
        startFinishAnimation(duration, completion: completion)
    }
    
    open func setOriginalState() {
        self.returnToOriginalState()
        self.spiner.stopAnimation()
    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let a = anim as! CABasicAnimation
        if a.keyPath == "transform.scale" {
            didEndFinishAnimation?()
            _ = Timer.schedule(delay: 1) { _ in
                self.returnToOriginalState()
            }
        }
    }
    
    open func returnToOriginalState() {
        self.layer.removeAllAnimations()
        self.setTitle(self.cachedTitle, for: UIControl.State())
        self.spiner.stopAnimation()
    }
    
    func shrink() {
        let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnim.fromValue = frame.width
        shrinkAnim.toValue = frame.height
        shrinkAnim.duration = shrinkDuration
        shrinkAnim.timingFunction = shrinkCurve
        shrinkAnim.fillMode = CAMediaTimingFillMode.forwards
        shrinkAnim.isRemovedOnCompletion = false
        layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
    }
    
    func expand() {
        let expandAnim = CABasicAnimation(keyPath: "transform.scale")
        expandAnim.fromValue = 1.0
        expandAnim.toValue = 26.0
        expandAnim.timingFunction = expandCurve
        expandAnim.duration = 0.3
        expandAnim.delegate = self
        expandAnim.fillMode = CAMediaTimingFillMode.forwards
        expandAnim.isRemovedOnCompletion = false
        layer.add(expandAnim, forKey: expandAnim.keyPath)
    }
    
    func expandButton() {
        let expandAnim = CABasicAnimation(keyPath: "bounds.size.width")
        expandAnim.fromValue = frame.height
        expandAnim.toValue = self.width
        expandAnim.duration = shrinkDuration
        expandAnim.timingFunction = shrinkCurve
        expandAnim.fillMode = CAMediaTimingFillMode.forwards
        expandAnim.isRemovedOnCompletion = false
        layer.add(expandAnim, forKey: expandAnim.keyPath)
    }
    
}
