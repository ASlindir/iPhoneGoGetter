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
    
    @IBOutlet weak var FemaleStackView: UIStackView!
    @IBOutlet weak var MaleStackView: UIStackView!
    var userId: String? = nil
    var isPinkName: Bool = false
    var didGoHandler: ((String?) -> Void)? = nil
    var purchaseConvoId: Int = 0
    var profileDelegate: ProfileViewControllerDelegate?
     var chatListViewController : ChatListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.FemaleStackView.isHidden = true
        self.MaleStackView.isHidden = true
        didGoHandler = {userId in
//            self.purchaseScreenAction = PurchasesConst.ScreenAction.BUY_CONVO.rawValue
            self.DoPurchaseConversation();
        }

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
    
    private func verifyChatController(){
        if (self.chatListViewController == nil){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            chatListViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ChatListViewController
        }
    }
    private func openChatList(userNewId: String? = nil, doAnimation : Bool) {
//        self.vwMatch.isHidden = true
//        self.view.sendSubviewToBack(self.vwMatch)
//        self.closingDelegate?.childClosing()
        verifyChatController()
        chatListViewController!.userNewId = userNewId
        self.chatListViewController!.doHeaderToBodyAnimation = true
        chatListViewController!.profileDelegate = self.profileDelegate
        
        let vc = self.navigationController?.viewControllers.first(where: { $0 is ChatListViewController })
        if vc != nil{
            vc?.removeFromParent()
        }
        self.navigationController?.pushViewController(self.chatListViewController!, animated: true)
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
    
    func DoPurchaseConversation(){
             Loader.startLoader(true)
             
             let parameters = [
                 "userId": LocalStore.store.getFacebookID(),
                 "convoId": self.purchaseConvoId
                 ] as [String : Any]
             
             WebServices.service.webServicePostRequest(.post, .conversation, .doPurchaseConversation, parameters, successHandler: { (response) in
                 Loader.stopLoader()
                 
                 let jsonDict = response
                 var isSuccess = false
                 
                 if let convoId = jsonDict!["convoId"] as? Int {
                     let prompt = jsonDict!["prompt"] as? String
                     
                     if let screenAction = jsonDict!["screenAction"] as? Int {
                         isSuccess = true
                         
                         switch screenAction {
                         case PurchasesConst.ScreenAction.WAIT_FOR_MATCH_TO_PAY.rawValue:
                             CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
                             self.outAlert(title: "Good Choice", message: prompt, compliteHandler:{
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                self.openChat(userNewId: self.userId)
//                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                    if (self.chatListViewController == nil){
//                                        let profileController = self.profileDelegate?.getCurrentProfileViewController()
//                                        self.navigationController?.popToViewController(profileController!, animated: false)
//                                    }
//                                    else{
                                    let friendDict = LocalStore.store.getUserDetails()
                                    self.verifyChatController()
                                    self.chatListViewController!.createNewFriendOnFirebase(friendDict, isOpenChat: false)
                                    self.openChatList(userNewId: self.userId, doAnimation: true)
//                                    }
                                }
                             })
                                
                             break
                         case PurchasesConst.ScreenAction.READY_TO_CHAT.rawValue:
                            let friendDict = LocalStore.store.getUserDetails()
                            self.verifyChatController()
                            self.chatListViewController!.createNewFriendOnFirebase(friendDict, isOpenChat: false)
                            self.openChatList(userNewId: self.userId, doAnimation: true)
//                             self.openChat()
                             break
                         default:
                             self.outAlertError(message: prompt ?? "Error")
                         }
                     }
                 }
                 
                 if !isSuccess {
                     self.outAlertError(message: "Error: doPurchaseConversation failed")
                 }
             }) { (error) in
                 Loader.stopLoader()
                 self.outAlertError(message: "Error: \(error.debugDescription)")
             }
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
                        let gender = userDetails["gender"] as? String
                        if gender == "M"{
                            self.isPinkName = false
                            self.MaleStackView.isHidden = false
                            self.FemaleStackView.isHidden = true
                        }
                        else{
                            self.isPinkName = true
                            self.MaleStackView.isHidden = true
                            self.FemaleStackView.isHidden = false
                        }
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
            self.didGoHandler?(self.userId)
        })
    }
    
    @IBAction func touchNotYet(_ sender: Any) {
        let profileController = self.profileDelegate?.getCurrentProfileViewController()
        self.navigationController?.popToViewController(profileController!, animated: false)
    }
    
}
