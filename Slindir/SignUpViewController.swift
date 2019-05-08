//
//  SignUpViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class SignUpViewController: FormViewController {
    
    enum Gender {
        case male
        case female
    }
    
    @IBOutlet weak var btnRegister: UIButton!
    
    
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblPassword1: UILabel!
    @IBOutlet weak var lblPassword2: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblEmailDescr: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    
    @IBOutlet weak var rbGenderMale: UIView!
    @IBOutlet weak var rbGenderFemale: UIView!
    
    @IBOutlet weak var editFirstName: CustomTextField!
    @IBOutlet weak var editPassword1: CustomTextField!
    @IBOutlet weak var editPassword2: CustomTextField!
    @IBOutlet weak var editEmail: CustomTextField!
    @IBOutlet weak var editBirthday: CustomTextField!
    
    @IBOutlet weak var dpContainer: UIView!
    @IBOutlet weak var dpDataPicker: UIDatePicker!
    @IBOutlet weak var dpContainerHeightConstraint: NSLayoutConstraint!
    

    var dpContainerHeightConstraintDefault: CGFloat = 0.0
    
    var currentGender: Gender? = nil
    var currentData: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init forms
        self.initTextFields(fields: [
            editFirstName,
            editPassword1,
            editPassword2,
            editEmail,
            editBirthday
            ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // buttons
        btnRegister.layer.cornerRadius = btnRegister.frame.size.height/2
        btnRegister.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        
        // init radio button
        initRadioButton(view: rbGenderMale)
        initRadioButton(view: rbGenderFemale)
        
        // text fields
        editBirthday.delegate = self
        editEmail.keyboardType = .emailAddress
        editEmail.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: UIControl.Event.editingChanged)
        
        // data picker
        dpContainer.layer.addBorder(edge: [.top], color: UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0), thickness: 1.5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dpContainerHeightConstraintDefault = dpContainerHeightConstraint.constant
        hideDataPicker(hide: true)
    }
    
    private func initRadioButton(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
        view.layer.borderColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0).cgColor
        view.layer.borderWidth = 1.5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapRadioButton(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    private func hideDataPicker(hide: Bool) {
        if hide {
            dpContainerHeightConstraint.constant = 0
            dpContainer.isHidden = true
        } else {
            dpContainerHeightConstraint.constant = dpContainerHeightConstraintDefault
            dpContainer.isHidden = false
        }
    }

    // MARK: - Touches

    @IBAction func btnRegister(_ sender: Any) {
        if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "PhoneViewController") as? PhoneViewController {
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
    
    private func rbGenderChange(view: UIView) {
        switch view {
        case rbGenderMale:
            currentGender = .male
        default:
            currentGender = .female
        }
        
        print("Changed gender")
    }
    
    @IBAction func dpCancel(_ sender: Any) {
        currentData = nil
        hideDataPicker(hide: true)
    }
    
    @IBAction func dpDone(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        editBirthday.text = dateFormatter.string(from: dpDataPicker.date)
        currentData = dpDataPicker.date
        
        hideDataPicker(hide: true)
    }
    
    
    // MARK: - Delegates
    
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        
        if textField == editEmail {
            if textField.text != nil && textField.text!.isValidEmail() {
                // TODO: Do something
                print("Email is valid")
            }
        }
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if super.textFieldShouldBeginEditing(textField) {
            if textField == editBirthday {
                hideDataPicker(hide: false)
                self.hideKeyboard()
                return false;
            }
            
            return true
        }
        
        return false
    }
    
    @objc func handleTapRadioButton(_ sender: UITapGestureRecognizer? = nil) {
        rbGenderMale.backgroundColor = .clear
        rbGenderFemale.backgroundColor = .clear
        
        sender?.view?.backgroundColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0)
        
        if sender?.view != nil {
            rbGenderChange(view: sender!.view!)
        }
    }
}
