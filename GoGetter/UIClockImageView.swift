//
//  UIClockImageView.swift
//  GoGetter
//
//  Created by admin on 26/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class UIClockImageView: UINibView {
    @IBOutlet weak var imageView: UIImageView!
    var shapeLayer: CAShapeLayer? = nil
    
    override func commonInit() {
        //
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2.0
        }
        
        self.clipsToBounds = true
//        self.addCircle(23.0)
    }
    
    func addView(startAngle: CGFloat = 0.0, endAngle: CGFloat = CGFloat(Double.pi * 2), width: CGFloat = 5.0, color: UIColor = UIColor.purple) {
        if shapeLayer != nil {
            shapeLayer?.removeFromSuperlayer()
        }
        
        let circlePath: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0), radius: CGFloat(self.frame.height / 2.0) - width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //color inside circle
        shapeLayer.fillColor = UIColor.clear.cgColor
        //colored border of circle
        shapeLayer.strokeColor = color.cgColor
        //width size of border
        shapeLayer.lineWidth = width
        
        self.layer.addSublayer(shapeLayer)
        self.shapeLayer = shapeLayer
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }

    func addCircle(_ perc: CGFloat, width: CGFloat = 5.0) {
        let prefixAngle = self.deg2rad(-90)
        let startAngle = self.deg2rad(360.0 * perc / 100.0)
        self.addView(startAngle: prefixAngle + startAngle, endAngle: prefixAngle + self.deg2rad(360), width: width)
    }
    
    func animationHide(completion: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.alpha = 0
        self.isHidden = false
        
        let durationLayer: Double = 0.5
        
        let animLine = CABasicAnimation(keyPath: "lineWidth")
        animLine.fromValue         = 5.0
        animLine.toValue           = 6.0
        animLine.duration          = durationLayer
        animLine.repeatCount       = 0
        animLine.autoreverses      = true
        self.shapeLayer?.add(animLine, forKey: "lineWidth")
        
        let animcolor = CABasicAnimation(keyPath: "strokeColor")
        animcolor.fromValue         = shapeLayer?.strokeColor
        animcolor.toValue           = shapeLayer?.strokeColor?.copy(alpha: 0.5)
        animcolor.duration          = durationLayer
        animcolor.repeatCount       = 0
        animcolor.autoreverses      = true
        self.shapeLayer?.add(animcolor, forKey: "strokeColor")
        
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.alpha = 1
        }, completion: { (completed: Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (completed: Bool) in
                completion?()
            })
        })
    }
}
