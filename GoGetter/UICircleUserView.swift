//
//  UICircleUserView.swift
//  GoGetter
//
//  Created by admin on 29/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import Foundation

class UICircleUserView: UINibView {
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var traililngImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingImageViewConstraint: NSLayoutConstraint!
    
    var shapeLayer: CAShapeLayer? = nil
    var tapHandler: ((UICircleUserView) -> Void)? = nil
    var indexPath : IndexPath? = nil // used for circles in header for animation
    
    @IBInspectable open var shapeColor: UIColor? = UIColor.purple {
        didSet {
            self.shapeLayer?.strokeColor = shapeColor?.cgColor
        }
    }
    
    @IBInspectable open var shapeWidth: CGFloat = 1.0 {
        didSet {
            self.shapeLayer?.lineWidth = shapeWidth
            self.topImageViewConstraint.constant = shapeWidth
            self.traililngImageViewConstraint.constant = shapeWidth
            self.bottomImageViewConstraint.constant = shapeWidth
            self.leadingImageViewConstraint.constant = shapeWidth
        }
    }
    
    @IBInspectable open var image: UIImage? = nil {
        didSet {
            self.imageView.image = image
        }
    }
    
    override func commonInit() {
        
        self.backgroundColor = UIColor.clear
        self.circularView.backgroundColor = UIColor.clear
        
        // taps
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.zPosition = 0
        self.circularView.layer.zPosition = 1000
        self.imageView.layer.zPosition = 1000
        self.circularView.layer.backgroundColor = UIColor.clear.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2.0
        }
        
        self.clipsToBounds = true
    }
    
    func addView(startAngle: CGFloat = 0.0, endAngle: CGFloat = CGFloat(Double.pi * 2)) {
        if shapeLayer != nil {
            shapeLayer?.removeFromSuperlayer()
        }
        
        let circlePath: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0), radius: CGFloat(self.frame.height / 2.0) - shapeWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //color inside circle
        shapeLayer.fillColor = UIColor.clear.cgColor
        //colored border of circle
        shapeLayer.strokeColor = self.shapeColor?.cgColor
        //width size of border
        shapeLayer.lineWidth = self.shapeWidth
        
        self.circularView.layer.addSublayer(shapeLayer)
        self.shapeLayer = shapeLayer
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
    func addCircle(_ perc: CGFloat) {
        let prefixAngle = self.deg2rad(-90)
        let startAngle = self.deg2rad(360.0 * perc / 100.0)
        self.addView(startAngle: prefixAngle + startAngle, endAngle: prefixAngle + self.deg2rad(360))
    }
    
    func animationShow(completion: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.alpha = 0
        self.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.alpha = 1
        }, completion: { (completed: Bool) in
            self.animationClick(completion: completion)
        })
    }
    
    func animationClick(completion: (() -> Void)? = nil) {
        let step: CGFloat = 0.05
        
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 1.0 + step, y: 1.0 + step)
            self.circularView.alpha = 0
        }, completion: { (completed: Bool) in
            self.circularView.alpha = 1
            
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0 + step * 3, y: 1.0 + step * 3)
                self.imageView.transform = CGAffineTransform(scaleX: 1.0 - step * 3, y: 1.0 - step * 3)
            }, completion: { (completed: Bool) in
                UIView.animate(withDuration: 0.25, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.imageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: { (completed: Bool) in
                    completion?()
                })
            })
        })
    }
    
    func animationChangeColor(color: UIColor, completion: (() -> Void)? = nil) {
        let step: CGFloat = 0.15
        
        self.circularView.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0 + step, y: 1.0 + step)
            self.imageView.transform = CGAffineTransform(scaleX: 1.0 - step, y: 1.0 - step)
        }, completion: { (completed: Bool) in
            self.circularView.alpha = 1
            
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.imageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.shapeLayer?.strokeColor = color.cgColor
            }, completion: { (completed: Bool) in
                self.shapeColor = color
                completion?()
            })
        })
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        self.tapHandler?(self)
    }
}
