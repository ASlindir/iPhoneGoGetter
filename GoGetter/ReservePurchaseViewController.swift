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
    var oppUserFBId: String? = nil
    var oppUserName: String? = nil
    var oppUserImg: String? = nil
    var isPinkName: Bool = false
    var didGoHandler: ((String?) -> Void)? = nil
    var purchaseConvoId: Int = 0
    var profileDelegate: ProfileViewControllerDelegate?
//     var chatListViewController : ChatListViewController?
    
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
    
//    private func verifyChatController(){
//        if (self.chatListViewController == nil){
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            chatListViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ChatListViewController
//        }
//    }
    private func openChatList(userNewId: String? = nil, doAnimation : Bool, newFriend : Dictionary<String, Any>?) {
//        self.vwMatch.isHidden = true
//        self.view.sendSubviewToBack(self.vwMatch)
//        self.closingDelegate?.childClosing()
        let vc = self.navigationController?.viewControllers.first(where: { $0 is ChatListViewController })
        if vc != nil{
            ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  doPurchaseConversation remove prior chat");
            vc?.removeFromParent()
        }
//        verifyChatController()
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            ClientLog.WriteClientLog( msgType: "ios", msg:"openChatList");
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatListViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ChatListViewController
            chatListViewController.userNewId = userNewId
            chatListViewController.newFriendFromReservePurchase = newFriend
            chatListViewController.doHeaderToBodyAnimation = true
            chatListViewController.profileDelegate = self.profileDelegate
            self.navigationController?.pushViewController(chatListViewController, animated: true)
        }
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
             ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  doPurchaseConversation");

             WebServices.service.webServicePostRequest(.post, .conversation, .doPurchaseConversation, parameters, successHandler: { (response) in
                 ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  doPurchaseConversation back");
                 Loader.stopLoader()
                 
                 let jsonDict = response
                 var isSuccess = false
                 
                if (jsonDict!["convoId"] as? Int) != nil {
                     ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  doPurchaseConversation got valid convid");
                     let prompt = jsonDict!["prompt"] as? String
                     
                     if let screenAction = jsonDict!["screenAction"] as? Int {
                         isSuccess = true
                         
                         switch screenAction {
                         case PurchasesConst.ScreenAction.WAIT_FOR_MATCH_TO_PAY.rawValue:
                             CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
                             ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  doPurchaseConversation WAIT_FOR_MATCH_TO_PAY");
                             self.outAlert(title: "Good Choice", message: prompt, compliteHandler:{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                    self.verifyChatController()
                                    self.openChatList(userNewId: self.oppUserFBId, doAnimation: true, newFriend: nil)
                                }
                             })
                             break
                         case PurchasesConst.ScreenAction.READY_TO_CHAT.rawValue:
//                            self.verifyChatController()
                            ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  doPurchaseConversation READY_TO_CHAT");

                            var friendDict = Dictionary<String, Any>()
                            friendDict["user_fb_id"] = self.oppUserFBId
                            friendDict["user_name"] = self.oppUserName
                            friendDict["profile_pic"] = self.oppUserImg
                            self.openChatList(userNewId: self.oppUserFBId, doAnimation: true, newFriend: friendDict)
//                             self.openChat()
                             break
                         default:
                             ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  ERROR FROM WEB SERVICE");
                             self.outAlertError(message: prompt ?? "Error")
                         }
                     }
                 }
                 
                 if !isSuccess {
                     self.outAlertError(message: "Error: doPurchaseConversation failed")
                 }
             }) { (error) in
                 Loader.stopLoader()
                 ClientLog.WriteClientLog( msgType: "ios", msg:"rpc  EXCEPTION FROM WEB SERVICE");
                 self.outAlertError(message: "Error: \(error.debugDescription)")
             }
    }
    func loadDetailsOfUser() {
        Loader.startLoader(true)
        
        if self.oppUserFBId != nil {
            let parameters = ["user_fb_id": self.oppUserFBId!]
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
            self.didGoHandler?(self.oppUserFBId)
        })
    }
    
    @IBAction func touchNotYet(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ProfileViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
//        let profileController = self.profileDelegate?.getCurrentProfileViewController()
//        self.navigationController?.popToViewController(profileController!, animated: false)
    }
    
}
