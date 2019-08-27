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
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title3Label: UILabel!
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
        buyButton.layer.cornerRadius = buyButton.frame.size.height/2
        buyButton.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
    }
    
    @IBInspectable open var title: String? = nil {
        didSet {
            //self.titleLabel.text = DataHelper.getLocalizeValue(value: title)
        }
    }
    
    @IBAction func touchBuyButton(_ sender: Any) {
        self.touch?(self.id)
    }
    
    public func set(id: String, title1: String?, title2: String?, title3: String?, title4: String?, touch: ((String?) -> Void)? = nil) {
        self.id = id
        self.touch = touch
        self.title1Label.text = title1
        self.title2Label.text = title2
        self.title3Label.text = title3
        self.title4Label.text = title4
    }
}
