//
//  CustomSlider.swift
//  Slindir
//
//  Created by Batth on 22/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSlider: UISlider {

    @IBInspectable var trackWidth : CGFloat = 2{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(x: defaultBounds.origin.x, y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2, width: defaultBounds.size.width, height: trackWidth)
    }
    
}
