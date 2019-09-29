//
//  ReservePurchaseViewController.swift
//  GoGetter
//
//  Created by admin on 27/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class ReservePurchaseViewController: UIViewController {
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var notYetButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var userId: String? = nil
    var isPinkName: Bool = false
    var didGoHandler: ((String?) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // buttons
        self.goButton.adjustsImageWhenHighlighted = false
        self.goButton.adjustsImageWhenDisabled = false
        
        self.notYetButton.backgroundColor = UIColor.clear
        self.notYetButton.layer.borderWidth = 1.0
        self.notYetButton.layer.borderColor = UIColor(red:0.82, green:0.84, blue:0.84, alpha:1.0).cgColor
        self.notYetButton.setTitleColor(UIColor(red:0.82, green:0.84, blue:0.84, alpha:1.0), for: .normal)
        
        // load user
        self.loadDetailsOfUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.goButton.isHidden = true
        self.notYetButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.goButton.layer.cornerRadius = self.goButton.frame.height / 2.0
        self.goButton.isHidden = false
        self.notYetButton.layer.cornerRadius = self.notYetButton.frame.height / 2.0
        self.notYetButton.isHidden = false
        self.createGradientLayer(self.gradientView)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(red:0.00, green:0.65, blue:0.69, alpha:1).cgColor]
        
        self.gradientView.layer.addSublayer(gradientLayer)
    }
    
    func loadDetailsOfUser() {
        Loader.startLoader(true)
        
        if self.userId != nil {
            let parameters = ["user_fb_id": self.userId!]
            
            WebServices.service.webServicePostRequest(.post, .user, .userDetails, parameters, successHandler: { (response) in
                Loader.stopLoader()
                let jsonData = response
                let status = jsonData!["status"] as! String
                if status == "success"{
                    if let userDetails = jsonData!["user_details"] as? Dictionary<String, Any> {
                        if let name = userDetails["user_name"] as? String {
                            if self.isPinkName {
                                let string = NSMutableAttributedString(string: "Reserve a coin for \(name)")
                                let range: NSRange = string.mutableString.range(of: name, options: .caseInsensitive)
                                
                                string.addAttribute(NSAttributedString.Key.foregroundColor, value:  UIColor(red:0.94, green:0.37, blue:0.65, alpha:1.0), range: range)
                                string.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Pacifico-Regular", size: 24.0)!, range: range)
                                
                                self.titleLabel.attributedText = string
                            } else {
                                self.titleLabel.text = "Reserve a coin for \(name)"
                            }
                        }
                    }
                }
            }, errorHandler: {error in
                Loader.stopLoader()
                self.outAlertError(message: "Error: \(error.debugDescription)")
            })
        }
        
    }

    @IBAction func touchGo(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.autoreverse], animations: {
            self.goButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: {finished in
            self.goButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.dismiss(animated: true, completion: {
                self.didGoHandler?(self.userId)
            })
        })
    }
    
    @IBAction func touchNotYet(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
