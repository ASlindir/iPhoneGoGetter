//
//  LostPasswordViewController.swift
//  Slindir
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Touches
    
    @IBAction func btnContinue(_ sender: Any) {
        outAlert(title: "Test", message: "btnContinue")
    }
    
    @IBAction func linkForgotCode(_ sender: Any) {
        outAlert(title: "Test", message: "linkForgotCode")
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
