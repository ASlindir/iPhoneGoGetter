//
//  SignInViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class SignInViewController: FormViewController, FPNTextFieldDelegate {
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var linkForgotPassword: UIButton!
    
    @IBOutlet weak var editPassword: CustomTextField!
    @IBOutlet weak var editPhone: FPNTextField!
    
    @IBOutlet weak var editPasswordHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var edotPasswordTopConstraint: NSLayoutConstraint!
    
    var editPasswordHeightConstraintDefault: CGFloat = 0.0
    var editPasswordTopConstraintDefault: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init forms
        self.initTextFields(fields: [
            editPassword,
            editPhone
            ])
        
        // set default constraint
        editPasswordHeightConstraintDefault = editPasswordHeightConstraint.constant
        editPasswordHeightConstraint.constant = 0.0
        
        editPasswordTopConstraintDefault = edotPasswordTopConstraint.constant
        edotPasswordTopConstraint.constant = 0.0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // buttons
        btnContinue.layer.cornerRadius = btnContinue.frame.size.height/2
        btnContinue.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        linkForgotPassword.underline()
        
        // country picker
        editPhone.flagSize = CGSize(width: 20, height: 20)
        editPhone.flagButtonEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        editPhone.borderStyle = UITextField.BorderStyle.roundedRect
        editPhone.layer.borderColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0).cgColor
        editPhone.layer.borderWidth = 1.5
        editPhone.layer.cornerRadius = 7.0
        editPhone.delegate = self
    }

    // MARK: - Touches
    
    @IBAction func linkForgotPassword(_ sender: Any) {
        outAlert(title: "Test", message: "linkForgotPassword")
    }
    
    @IBAction func btnContinue(_ sender: Any) {
        outAlert(title: "Test", message: "btnContinue")
    }
    
    // MARK: - Delegates
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            editPasswordHeightConstraint.constant = editPasswordHeightConstraintDefault
            edotPasswordTopConstraint.constant = editPasswordTopConstraintDefault
            
            // For next step...
            //            textField.getFormattedPhoneNumber(format: .E164),           // Output "+33600000001"
            //            textField.getFormattedPhoneNumber(format: .International),  // Output "+33 6 00 00 00 01"
            //            textField.getFormattedPhoneNumber(format: .National),       // Output "06 00 00 00 01"
            //            textField.getFormattedPhoneNumber(format: .RFC3966),        // Output "tel:+33-6-00-00-00-01"
            //            textField.getRawPhoneNumber()                               // Output "600000001"
        } else {
            editPasswordHeightConstraint.constant = 0.0
            edotPasswordTopConstraint.constant = 0.0
            editPassword.text = ""
        }
    }
}
