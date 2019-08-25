//
//  UINibView.swift
//  GoGetter
//
//  Created by admin on 21/08/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class UINibView: UIView {
    var nibName: String?
    var contentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultInit()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultInit()
        commonInit()
    }
    
    func defaultInit() {
        if self.nibName == nil {
            self.nibName = String(describing: type(of: self))
        }
        
        guard let view = loadViewFromNib(self.nibName!) else { return }
        view.frame = self.bounds
        //print(self.bounds)
        self.addSubview(view)
        self.contentView = view
        
        // localize Interface
        self.localizeInterface()
    }
    
    func commonInit() {
        
    }
    
    func localizeInterface() {
        
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.contentView?.frame = self.bounds
    }
}

