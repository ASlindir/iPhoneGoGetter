//
//  ChangePhoneViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class ChangePhoneViewController: FormViewController, FPNTextFieldDelegate {
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
        
        // buttons
        btnContinue.isHidden = true
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
    
    // MARK: - Touches
    
    @IBAction func btnContinue(_ sender: Any) {
        outAlert(title: "Test", message: "btnContinue")
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
        
        if isValidateOldPhone && isValidateNewPhone {
            btnContinue.isHidden = false
        } else {
            btnContinue.isHidden = true
        }
    }
}
