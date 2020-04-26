//
//  PurchaseStatisticViewController.swift
//  GoGetter
//
//  Created by admin on 28/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

protocol PurchaseStatisticViewControllerDelegate {
    func didBackToMatches()
}

class PurchaseStatisticViewController: UIViewController {
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var coinsLeftLabel: UILabel!
    @IBOutlet weak var reserveLabel: UILabel!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var backToMachesButton: UIButton!
    
    var delegate: PurchaseStatisticViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // buttons
        self.backButton.setImage(UIImage(named: "back")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.backButton.tintColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0)
        
        // default colors
        self.setCountForTitle(label: self.coinsLeftLabel, title: "You have 0 coins left", value: "0", color: UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0))
        self.setCountForTitle(label: self.reserveLabel, title: "0 coins on reserve", value: "0", color: UIColor(red:0.27, green:0.64, blue:0.97, alpha:1.0))
        self.setCountForTitle(label: self.waitingLabel, title: "0 matches waiting", value: "0", color: UIColor(red:0.87, green:0.42, blue:0.65, alpha:1.0))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.createGradientLayer(self.gradientView)
        
        self.backToMachesButton.layer.cornerRadius = self.backToMachesButton.frame.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadUserConvoStats(compliteHandler: {
            //
        })
    }

    // MARK: - User functions
    
    func loadUserConvoStats(compliteHandler: (() -> Void)? = nil) {
        Loader.startLoader(true)
        
        var parameters = Dictionary<String, Any>()
        parameters["userId"] = LocalStore.store.getFacebookID()
        
        WebServices.service.webServicePostRequest(.post, .conversation, .doQueryConvoStats, parameters, successHandler: { (response) in
            Loader.stopLoader()
            
            let jsonDict = response
            
            if let userCoinRecord = jsonDict!["userCoinRecord"] as? [String:Any?] {
                if let value = userCoinRecord["coinsNotReserved"] as? String {
                    self.setCountForTitle(label: self.coinsLeftLabel, title: "You have \(value) coins left", value: value, color: UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0))
                }
                
                if let value = userCoinRecord["coinsReserved"] as? String {
                     self.setCountForTitle(label: self.reserveLabel, title: "\(value) coins on reserve", value: value, color: UIColor(red:0.27, green:0.64, blue:0.97, alpha:1.0))
                }
                
                if let value = userCoinRecord["coinsNotReserved"] as? String {
                     self.setCountForTitle(label: self.waitingLabel, title: "\(value) matches waiting", value: value, color: UIColor(red:0.87, green:0.42, blue:0.65, alpha:1.0))
                }
                
            }
            
            compliteHandler?()
        }) { (error) in
            Loader.stopLoader()
            self.outAlertError(message: "Error: \(error.debugDescription)")
            compliteHandler?()
        }
    }
    
    func setCountForTitle(label: UILabel, title: String, value: String, color: UIColor) {
        let string = NSMutableAttributedString(string: title)
        let range: NSRange = string.mutableString.range(of: value, options: .caseInsensitive)
        
        string.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        string.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Barmeno-Bold", size: 35.0)!, range: range)
        
        label.attributedText = string
    }

    // MARK: - Events

    @IBAction func touchBackbutton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchBackToMathes(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.didBackToMatches()
        })
    }
}
