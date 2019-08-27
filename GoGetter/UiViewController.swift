//
//  UiViewController.swift
//  GoGetter
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
    
    class func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        func instanceFromNib<T: UIViewController>(_ bundle: Bundle? = nil) -> T {
            return T(nibName: String(describing: self), bundle: bundle)
        }
        
        return instanceFromNib(bundle)
    }
    
    class func loadFromStoryboard(storyboardName: String, withIdentifier: String? = nil,  bundle: Bundle? = nil) -> Self {
        func loadFromStoryboard<T: UIViewController>(storyboardName: String, withIdentifier: String,  bundle: Bundle? = nil) -> T {
            return UIStoryboard(name: storyboardName, bundle: bundle).instantiateViewController(withIdentifier: withIdentifier) as! T
        }
        
        let identifier = withIdentifier == nil ? String(describing: self) : withIdentifier!
        
        return loadFromStoryboard(storyboardName: storyboardName, withIdentifier: identifier, bundle: bundle)
    }
}
