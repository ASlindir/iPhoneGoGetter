//
//  FreebieViewController.swift
//  GoGetter
//
//  Created by Fred Covely on 4/9/20.
//  Copyright © 2020 Batth. All rights reserved.
//

import Foundation
import UIKit

class FreebieViewController: UIViewController, GGChildViewDelegate {
    
   
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var gradientView: UIView!
    var userId: String? = nil
    var isPinkName: Bool = false
    var didGoHandler: ((String?) -> Void)? = nil
    var purchaseConvoId: Int = 0
    var closingDelegate: GGChildViewDelegate? = nil

    func childClosing() {
        closingDelegate!.childClosing()
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
         super.viewDidLoad()
        btnNext.isHidden = false
         self.createGradientLayer(self.gradientView)
         // buttons
     }

     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
     }

     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         
     }
    @IBAction func onClick(_ sender: Any) {
        let controller = ReservePurchaseViewController.loadFromNib()
        controller.userId = userId
        controller.purchaseConvoId = purchaseConvoId
        controller.closingDelegate = self
//        controller.didGoHandler = {userId in
//            self.purchaseScreenAction = PurchasesConst.ScreenAction.BUY_CONVO.rawValue
//            self.DoPurchaseConversation();
//            // get
////                self.openChat(userNewId: userId)
//        }
        
        self.present(controller, animated: true, completion: nil)
//        dismiss(animated: false, completion: nil)
//    fhc        self.outAlertError(message: "conv purchased in test Your good!")
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
    }
}
