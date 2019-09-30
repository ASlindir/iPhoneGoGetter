//
//  UIView.swift
//  GoGetter
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

extension UIView {
    
    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                        if let complete = onCompletion { complete() }
        }
        )
    }
    
    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                        self.isHidden = true
                        if let complete = onCompletion { complete() }
        }
        )
    }
    
    func loadViewFromNib(_ nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func copyView() -> UIView {
        self.isHidden = false //The copy not works if is hidden, just prevention
        let viewCopy = self.snapshotView(afterScreenUpdates: true)
        self.isHidden = true
        return viewCopy!
    }
    
    func takeSnapshotOfView() -> UIImage? {
        
        let size = CGSize(width: frame.size.width, height: frame.size.height)
        let rect = CGRect.init(origin: .init(x: 0, y: 0), size: frame.size)
        
        UIGraphicsBeginImageContext(size)
        drawHierarchy(in: rect, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let imageData = image?.pngData() else {
            return nil
        }
        
        return UIImage.init(data: imageData)
    }
}
