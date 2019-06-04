//
//  UiViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

extension UIViewController {
    func outAlert(title: String?, message: String?, compliteHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default) { (action:UIAlertAction) in
            compliteHandler?()
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func outAlertError(message: String?, compliteHandler: (() -> Void)? = nil) {
        outAlert(title: "Error", message: message, compliteHandler: compliteHandler)
    }
    
    func outAlertSuccess(message: String?, compliteHandler: (() -> Void)? = nil) {
        outAlert(title: "Success", message: message, compliteHandler: compliteHandler)
    }
}
