import UIKit

protocol StartStopAnimationDelegate : class {
    func canStopAnimation()
    func canStartAnimation()
}

class SpinerLayer: CAShapeLayer, CAAnimationDelegate {
    
    var spinnerColor = UIColor.white {
        didSet {
            strokeColor = spinnerColor.cgColor
        }
    }
    
    weak var spinnerDelegate : StartStopAnimationDelegate?
    
    init(frame:CGRect) {
        super.init()
        calculate(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculate(frame: CGRect) {
        let radius:CGFloat = (frame.height / 2) * 0.5
        self.frame = CGRect(x: 0, y: 0, width: frame.height, height: frame.height)
        let center = CGPoint(x: frame.height / 2, y: bounds.center.y)
        let startAngle = 0 - Double.pi
        let endAngle = Double.pi * 2 - Double.pi
        let clockwise: Bool = true
        self.path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: CGFloat(startAngle),
            endAngle: CGFloat(endAngle),
            clockwise: clockwise
            ).cgPath
        
        self.fillColor = nil
        self.strokeColor = spinnerColor.cgColor
        self.lineWidth = 1
        
        self.strokeEnd = 0.4
        self.isHidden = true
    }
    
    func animation() {
        self.isHidden = false
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = Double.pi * 2
        rotate.duration = 0.4
        rotate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        rotate.repeatCount = HUGE
        rotate.fillMode = CAMediaTimingFillMode.forwards
        rotate.isRemovedOnCompletion = false
        rotate.delegate = self
        self.add(rotate, forKey: rotate.keyPath)
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        spinnerDelegate?.canStopAnimation()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        spinnerDelegate?.canStartAnimation()
    }
    
    func stopAnimation() {
        self.isHidden = true
        self.removeAllAnimations()
    }
}
