//
//  FreebieViewController.swift
//  GoGetter
//
//  Created by Fred Covely on 4/9/20.
//  Copyright © 2020 Batth. All rights reserved.
//

import Foundation
import UIKit

class FreebieViewController: UIViewController {
    
   
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var gradientView: UIView!
    var oppUserFBId: String? = nil
    var oppUserName: String? = nil
    var oppUserImg: String? = nil

    var isPinkName: Bool = false
    var didGoHandler: ((String?) -> Void)? = nil
    var purchaseConvoId: Int = 0
    var rpController : ReservePurchaseViewController? = nil
    var profileDelegate: ProfileViewControllerDelegate?


    override func viewDidLoad() {
         super.viewDidLoad()
        btnNext.isHidden = false
        self.btnNext.layer.cornerRadius = 16
        self.btnNext.clipsToBounds = true
        self.createGradientLayer(self.gradientView)
         // buttons
     }

     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
     }

     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        animateSayHelloBtn()
     }
    
    @IBAction func onClick(_ sender: Any) {
//         self.navigationController?.popToRootViewController(animated: true)
//        self.dismiss(animated: false, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let xrpController = ReservePurchaseViewController.loadFromNib()
            xrpController.oppUserFBId = self.oppUserFBId
            xrpController.oppUserImg = self.oppUserImg
            xrpController.oppUserName = self.oppUserName
            xrpController.profileDelegate = self.profileDelegate
            xrpController.purchaseConvoId = self.purchaseConvoId
            self.navigationController?.pushViewController(xrpController, animated: true)
//            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        }
    }
    func animateSayHelloBtn() {
           self.btnNext.rotate(10, 0.05, finished: { (completed: Bool) in
               self.btnNext.rotate(-10, 0.05, finished: { (completed: Bool) in
                   self.btnNext.rotate(10, 0.05, finished: { (completed: Bool) in
                       self.btnNext.rotate(-10, 0.05, finished: { (completed: Bool) in
                           self.btnNext.rotate(10, 0.05, finished: { (completed:Bool) in
                               self.btnNext.rotate(-10, 0.05, finished: { (completed: Bool) in
                                   self.btnNext.rotate(8, 0.05, finished: { (completed: Bool) in
                                       self.btnNext.rotate(-8, 0.05, finished: { (completed: Bool) in
                                           self.btnNext.rotate(6, 0.1, finished: { (completed:Bool) in
                                               self.btnNext.rotate(-6, 0.1, finished: { (completed:Bool) in
                                                   self.btnNext.rotate(2, 0.2, finished: { (completed:Bool) in
                                                       self.btnNext.rotate(-2, 0.1, finished: { (completed:Bool) in
                                                           self.btnNext.rotate(0, 0.1, finished: { (completed:Bool) in
                                                              
                                                           })
                                                       })
                                                   })
                                               })
                                           })
                                       })
                                   })
                               })
                           })
                       })
                   })
               })
           })
           
       }
}
