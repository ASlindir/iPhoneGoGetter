//
//  CustomTextField.swift
//  GoGetter
//
//  Created by Gurinder Batth on 26/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {

    override func drawText(in rect: CGRect) {
        let edgeContents = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        super.drawText(in: rect.inset(by: edgeContents))
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let margin: CGFloat = 10
        let insets = CGRect(x: bounds.origin.x + margin, y: bounds.origin.y, width: bounds.size.width - margin, height: bounds.size.height)
        return insets
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let margin: CGFloat = 10
        let insets = CGRect(x: bounds.origin.x + margin, y: bounds.origin.y, width: bounds.size.width - margin, height: bounds.size.height)
        return insets
    }
    
    @IBInspectable var borderColor: UIColor?{
        didSet{
            self.layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
}
