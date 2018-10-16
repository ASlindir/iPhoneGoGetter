//
//  CustomLabel.swift
//  Slindir
//
//  Created by Batth on 16/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit

@IBDesignable
class CustomLabel: UILabel {

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
}
