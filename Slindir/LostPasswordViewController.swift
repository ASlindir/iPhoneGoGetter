//
//  LostPasswordViewController.swift
//  GoGetter
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class LostPasswordViewController: FormViewController {
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var linkForgotCode: UIButton!
    
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblInstructs: UILabel!
    
    @IBOutlet weak var editPhoneCode: CustomTextField!
    @IBOutlet weak var editPassword1: CustomTextField!
    @IBOutlet weak var editPassword2: CustomTextField!
    
    var currentPhoneNumber: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init forms
        self.initTextFields(fields: [
            editPhoneCode,
            editPassword1,
            editPassword2
            ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // buttons
        btnContinue.layer.cornerRadius = btnContinue.frame.size.height/2
        btnContinue.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        
        linkForgotCode.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        linkForgotCode.titleLabel?.textAlignment = .center
        linkForgotCode.titleLabel?.numberOfLines = 0
        
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
        
        if currentPhoneNumber != nil {
            var parameters = Dictionary<String, Any?>()
            parameters["phone_number"] = currentPhoneNumber
            
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
    
    // MARK: - Touches
    
    @IBAction func btnContinue(_ sender: Any) {
        if editPhoneCode.text == nil || editPhoneCode.text!.isEmpty || editPhoneCode.text!.count < 6 {
            outAlertError(message: "The phone code must be 6 characters")
        } else if editPassword1.text == nil || editPassword1.text!.isEmpty || editPassword1.text!.count < 8 {
            outAlertError(message: "Password lengths must be at least 8 characters")
        } else if editPassword1.text != editPassword2.text {
            outAlertError(message: "The passwords must be the same")
        } else {
            if currentPhoneNumber != nil {
                Loader.startLoaderV2(true)

                var parameters = Dictionary<String, Any?>()
                parameters["phone_number"] = currentPhoneNumber
                parameters["phone_code"] = editPhoneCode.text
                parameters["new_password"] = editPassword1.text
                
                WebServices.service.webServicePostRequest(.post, .user, .changePassword, parameters as Dictionary<String, Any>, successHandler: { (response) in
                    let jsonData = response
                    let status = jsonData!["status"] as! String

                    Loader.stopLoader()

                    if status == "success" {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.outAlertError(message: "Sorry that was the wrong phone code, try again, or click the resend button to get a new code")
                    }

                }, errorHandler: { (error) in
                    self.outAlertError(message: "Password change failed: \(error.debugDescription)")
                })
            } else {
                Loader.stopLoader()
                self.outAlertError(message: "Phone number is null")
            }
        }
    }
    
    @IBAction func linkForgotCode(_ sender: Any) {
        sendCode()
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
