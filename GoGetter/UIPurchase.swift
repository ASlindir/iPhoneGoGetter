//
//  UIPurchase.swift
//  GoGetter
//
//  Created by admin on 21/08/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import Foundation
import UIKit

class UIPurchase: UINibView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bestValueImageView: UIImageView!
    
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
//    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var title4Label: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    var id: String? = nil
    var touch: ((String?) -> Void)? = nil
    
    override func commonInit() {
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // view
        self.contentView?.backgroundColor = UIColor.clear
        
        // buttons
        buyButton.layer.cornerRadius = 5.0
        buyButton.backgroundColor = UIColor.white
        
        // best value
//        self.bestValueImageView.isHidden = true
        
        // background
        self.layer.cornerRadius = 5.0
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    @IBInspectable open var title: String? = nil {
        didSet {
            //self.titleLabel.text = DataHelper.getLocalizeValue(value: title)
        }
    }
    
    @IBAction func touchBuyButton(_ sender: Any) {
        self.touch?(self.id)
        
        CustomClass.sharedInstance.playAudio(.cash, .mp3)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.buyButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: { (completed: Bool) in
            UIView.animate(withDuration: 0.3, animations: {
                self.buyButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (completed: Bool) in
                //
            })
        })
    }
    
    public func set(id: String, title1: String?, title2: String?, title3: String?, title4: String?, touch: ((String?) -> Void)? = nil) {
        self.id = id
        self.touch = touch
        self.title1Label.text = title1
        self.title2Label.text = "COINS"
//        self.title3Label.text = title3
//        self.title4Label.text = title4
        self.title4Label.text = title3
    }
}
