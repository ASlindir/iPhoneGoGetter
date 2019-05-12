//
//  ChangePhoneViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class ChangePhoneViewController: FormViewController, FPNTextFieldDelegate, EmailCodeViewControllerProtocol {
    @IBOutlet weak var lblInstructs: UILabel!
    
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var editOldPhone: FPNTextField!
    @IBOutlet weak var editNewPhone: FPNTextField!
    
    var isValidateOldPhone: Bool = false
    var isValidateNewPhone: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init forms
        self.initTextFields(fields: [
            editOldPhone,
            editNewPhone
            ])
        
        // test values
//        editOldPhone.setFlag(for: .RU)
//        editNewPhone.setFlag(for: .RU)
//        editOldPhone.set(phoneNumber: "+79315994974")
//        editNewPhone.set(phoneNumber: "+79162584786")
        
        // validate form
        validateForm()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // buttons
        btnContinue.layer.cornerRadius = btnContinue.frame.size.height/2
        btnContinue.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        
        // country picker
        initCountryPicker(editField: editOldPhone)
        initCountryPicker(editField: editNewPhone)
    }
    
    private func initCountryPicker(editField: FPNTextField) {
        editField.flagSize = CGSize(width: 20, height: 20)
        editField.flagButtonEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        editField.borderStyle = UITextField.BorderStyle.roundedRect
        editField.layer.borderColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0).cgColor
        editField.layer.borderWidth = 1.5
        editField.layer.cornerRadius = 7.0
        editField.delegate = self
    }
    
    private func validateForm() {
        btnContinue.isHidden = !isValidateNewPhone || !isValidateOldPhone
    }
    
    private func getPhoneNumber(textField: FPNTextField) -> String? {
        let code = textField.getFormattedPhoneNumber(format: .International)?.split(separator: " ")[0]
        return "\(code!) \(textField.text!)"
    }
    
    // MARK: - Touches
    
    @IBAction func btnContinue(_ sender: Any) {
        Loader.startLoaderV2(true)
        
        var parameters = Dictionary<String, Any?>()
        parameters["phone_number_old"] = getPhoneNumber(textField: editOldPhone)
        
        WebServices.service.webServicePostRequest(.post, .user, .requestMailCode, parameters as Dictionary<String, Any>, successHandler: { (response) in
            let jsonData = response
            let status = jsonData!["status"] as! String

            Loader.stopLoader()

            if status == "success"{
                if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "EmailCodeViewController") as? EmailCodeViewController {
                    newViewController.currentOldPhoneNumber = self.getPhoneNumber(textField: self.editOldPhone)
                    newViewController.currentNewPhoneNumber = self.getPhoneNumber(textField: self.editNewPhone)
                    newViewController.delegate = self
                    self.present(newViewController, animated: true)
                }
            } else {
                self.outAlertError(message: "We could not find an account for the old phone number, please check the number and try again")
            }

            self.validateForm()

        }, errorHandler: { (error) in
            self.outAlertError(message: "We were unable to request a mail code please try again later: \(error.debugDescription)")
        })
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Delegates
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        switch textField {
        case editOldPhone:
            isValidateOldPhone = isValid
        default:
            isValidateNewPhone = isValid
        }
        
        validateForm()
    }
    
    func didClose() {
        self.dismiss(animated: true, completion: nil)
    }
}
