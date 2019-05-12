//
//  PhoneViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class PhoneViewController: FormViewController {
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblInstructs: UILabel!
    @IBOutlet weak var editPhoneCode: CustomTextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var linkNewCode: UIButton!
    
    var currentPhoneNumber: String? = nil
    var currentUser: SignUpViewController.UserForm? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init forms
        self.initTextFields(fields: [
            editPhoneCode
            ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // buttons
        btnRegister.layer.cornerRadius = btnRegister.frame.size.height/2
        btnRegister.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        
        linkNewCode.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        linkNewCode.titleLabel?.textAlignment = .center
        linkNewCode.titleLabel?.numberOfLines = 0
        
        // text fields
        editPhoneCode.delegate = self
        
        // labels
        lblPhone.text = currentPhoneNumber
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sendCode()
    }
    
    func sendCode() {
        Loader.startLoaderV2(true)
        
        if currentUser?.phoneNumber != nil {
            var parameters = Dictionary<String, Any?>()
            parameters["phone_number"] = currentUser?.phoneNumber
            
            WebServices.service.webServicePostRequest(.post, .user, .sendPhoneCode, parameters as Dictionary<String, Any>, successHandler: { (response) in
                let jsonData = response
                let status = jsonData!["status"] as! String
                
                Loader.stopLoader()
                
                if status == "success"{
                    self.outAlertSuccess(message: "A Phone code was requested.  Please check your text messages")
                }else{
                    self.outAlertError(message: "You have tried to get a phone code too many times, this account is temporarily locked.  Try again in a few minutes")
                }
                
            }, errorHandler: { (error) in
                self.outAlertError(message: "Could not register because of communication error, please try again later: \(error.debugDescription)")
            })
        } else {
            Loader.stopLoader()
            self.outAlertError(message: "Phone number is null")
        }
    }
    
    private func authFirebaseForPhoneLogin(token: String?, userDetails: String?) {
        // TODO: Firebase auth and save token.
        
        self.outAlertSuccess(message: "Congrats!!! Firebase auth and save token!", compliteHandler: {
            // save token and etc
            let welcomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = welcomeViewController
        })
    }
    
    // MARK: - Touches
    
    @IBAction func btnRegister(_ sender: Any) {
        if editPhoneCode.text == nil || editPhoneCode.text!.isEmpty || editPhoneCode.text!.count < 6 {
            outAlertError(message: "The phone code must be 6 characters")
        } else {
            if currentUser?.phoneNumber != nil {
                Loader.startLoaderV2(true)
                
                var parameters = Dictionary<String, Any?>()
                parameters["phone_number"] = currentUser?.phoneNumber
                parameters["phone_code"] = editPhoneCode.text
                parameters["user_name"] = currentUser?.firstName
                parameters["pwd1"] = currentUser?.password
                parameters["pwd2"] = currentUser?.password
                parameters["gender"] = currentUser?.gender == .male ? "M" : "F"
                parameters["device_type"] = "A"
                parameters["email"] = currentUser?.email
                parameters["device_id"] = UserDefaults.standard.value(forKey: "device_token") as? String

                WebServices.service.webServicePostRequest(.post, .user, .registernewuser, parameters as Dictionary<String, Any>, successHandler: { (response) in
                    let jsonData = response
                    let status = jsonData!["status"] as! String
                    let token = jsonData?["token"] as? String
                    let userDetails = jsonData?["userDetails"] as? String

                    Loader.stopLoader()

                    if status == "success" {
                        self.authFirebaseForPhoneLogin(token: token, userDetails: userDetails)
                    } else if status == "duplicate" {
                        self.outAlertError(message: "Registration phone number is already registered, go back to login and click 'forgot password help' if you don't remember your password")
                    } else {
                        self.outAlertError(message: "Registration failed: \(status)")
                    }

                }, errorHandler: { (error) in
                    self.outAlertError(message: "Could not register because of communication error, please try again later: \(error.debugDescription)")
                })
            } else {
                Loader.stopLoader()
                self.outAlertError(message: "Phone number is null")
            }
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func linkNewCode(_ sender: Any) {
       sendCode()
    }
    
    // MARK: - Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == editPhoneCode) {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 6
        }
        
        return true
    }
}
