//
//  EmailCodeViewController.swift
//  Slindir
//
//  Created by admin on 12/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

protocol EmailCodeViewControllerProtocol {
    func didClose()
}

class EmailCodeViewController: FormViewController {
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblInstructs: UILabel!
    @IBOutlet weak var editPhoneCode: CustomTextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var linkNewCode: UIButton!
    
    var currentNewPhoneNumber: String? = nil
    var currentOldPhoneNumber: String? = nil
    
    var delegate: EmailCodeViewControllerProtocol? = nil
    
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
        lblPhone.text = currentOldPhoneNumber
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Touches
    
    @IBAction func btnRegister(_ sender: Any) {
        if editPhoneCode.text == nil || editPhoneCode.text!.isEmpty || editPhoneCode.text!.count < 6 {
            outAlertError(message: "The phone code must be 6 characters")
        } else {
            if currentNewPhoneNumber != nil {
                Loader.startLoaderV2(true)

                var parameters = Dictionary<String, Any?>()
                parameters["oldphone"] = currentOldPhoneNumber
                parameters["newphone"] = currentNewPhoneNumber
                parameters["email_code"] = editPhoneCode.text

                WebServices.service.webServicePostRequest(.post, .user, .checkEmailCode, parameters as Dictionary<String, Any>, successHandler: { (response) in
                    let jsonData = response
                    let status = jsonData!["status"] as! String

                    Loader.stopLoader()

                    if status == "success" {
                        self.outAlertError(message: "Your phone number has been changed.  Please login")
                        self.dismiss(animated: false, completion: {
                            self.delegate?.didClose()
                        })
                    } else {
                        self.outAlertError(message: "Sorry that was the wrong phone code, try again, or click the resend button to get a new code")
                    }

                }, errorHandler: { (error) in
                    self.outAlertError(message: "We were unable to check the phone code at this time, please try again later: \(error.debugDescription)")
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
        Loader.startLoaderV2(true)
        
        var parameters = Dictionary<String, Any?>()
        parameters["phone_number_old"] = currentOldPhoneNumber
        
        WebServices.service.webServicePostRequest(.post, .user, .requestMailCode, parameters as Dictionary<String, Any>, successHandler: { (response) in
            let jsonData = response
            let status = jsonData!["status"] as! String
            
            Loader.stopLoader()
            
            if status == "success"{
                self.outAlertSuccess(message: "A code was requested, please check your email.")
            } else {
                Loader.stopLoader()
                self.outAlertError(message: "Sorry we are unable to send you an email at this time please try again later.")
            }
        }, errorHandler: { (error) in
            Loader.stopLoader()
            self.outAlertError(message: "Phone number change failed, please try again later: \(error.debugDescription)")
        })
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
