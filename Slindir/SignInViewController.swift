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
    
    // internal
    var isValidNumber: Bool = false
    var isValidNumberFromServer: Bool = false
    
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
        
        // test values
        editPhone.setFlag(for: .US)
        //        editPhone.set(phoneNumber: "+79315994974")
        //        editPhone.set(phoneNumber: "+79162584277")
        //                editPhone.set(phoneNumber: "+79162584786")
        //        editPassword.text = "123456789"
        //        isValidNumber = true
        //        isValidNumberFromServer = true
        validateForm()
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
        
        // text fields
        editPassword.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    private func validateForm() {
        btnContinue.isHidden = !isValidNumber
            || (isValidNumberFromServer && editPassword.text?.isEmpty ?? true)
        
        if isValidNumberFromServer {
            linkForgotPassword.setTitle("Forgot password? Click here", for: .normal)
            linkForgotPassword.underline()
        } else {
            linkForgotPassword.setTitle("Phone number changed?  Click here", for: .normal)
            linkForgotPassword.underline()
        }
        
        hiddenPassword(hidden: !isValidNumberFromServer)
    }
    
    private func hiddenPassword(hidden: Bool) {
        if hidden {
            editPasswordHeightConstraint.constant = 0.0
            edotPasswordTopConstraint.constant = 0.0
            editPassword.text = ""
        } else {
            editPasswordHeightConstraint.constant = editPasswordHeightConstraintDefault
            edotPasswordTopConstraint.constant = editPasswordTopConstraintDefault
        }
    }
    
    private func getPhoneNumber() -> String? {
        let code = editPhone.getFormattedPhoneNumber(format: .International)?.split(separator: " ")[0]
        return "\(code!) \(editPhone.text!)"
    }
    
    private func authFirebaseForPhoneLogin(token: String, jsonData : Dictionary<String, Any>, userDetails:Dictionary<String, Any>) {
        // TODO: Firebase auth and save token.
        if let userDetails = jsonData["userDetails"] as? Dictionary<String, Any> {
            LocalStore.store.facebookID = userDetails["user_fb_id"] as! String
            let del = UIApplication.shared.delegate as! AppDelegate
            if del.latitude != 0.0 && del.longitude != 0.0 {
                del.saveUserLocation()
            }
            if let profile_video = userDetails["profile_video"] as? String {
                if profile_video != ""{
                    self.writeVideo(profile_video)
                }
            }
            print(userDetails)
            let dictData = NSKeyedArchiver.archivedData(withRootObject: userDetails)
            LocalStore.store.saveUserDetails = dictData
            self.loadProfileImagesInCache(userDetails)
            
            LocalStore.store.login = true;
            LocalStore.store.appNotFirstTime = true
            LocalStore.store.quizDone = true
            LocalStore.store.heightDone = true
            
            if let brain = userDetails["brain"] as? String{
                if brain == "" {
                    LocalStore.store.quizDone = false
                    LocalStore.store.heightDone = false
                }
            }
            else {
                LocalStore.store.quizDone = false
                LocalStore.store.heightDone = false
            }
            //                                let del = UIApplication.shared.delegate as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
            controller.isRootController = true
            del.window?.rootViewController = navigationController
        }
        // straight to profiles
        /*
        // save token and etc	
        let welcomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
        welcomeViewController?.fbLoginType = 1
        welcomeViewController?.userDetails = userDetails
        welcomeViewController?.jsonDataFromPhoneLogin = jsonData
        LocalStore.store.facebookID = userDetails["user_fb_id"] as! String

        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = welcomeViewController*/
    }
    
    // MARK: - Touches
    
    @IBAction func linkForgotPassword(_ sender: Any) {
        if isValidNumberFromServer {
            if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "LostPasswordViewController") as? LostPasswordViewController {
                newViewController.currentPhoneNumber = getPhoneNumber()
                self.present(newViewController, animated: true)
            }
            
        } else {
            if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "ChangePhoneViewController") as? ChangePhoneViewController {
                self.present(newViewController, animated: true)
            }
        }
    }
    
    @IBAction func btnContinue(_ sender: Any) {
        hideKeyboard()
        
        var parameters = Dictionary<String, Any?>()
        parameters["phone_number"] = getPhoneNumber()
        
        Loader.startLoaderV2(true)
        
        if !isValidNumberFromServer {
            WebServices.service.webServicePostRequest(.post, .user, .checkPhone, parameters as Dictionary<String, Any>, successHandler: { (response) in
                let jsonData = response
                let status = jsonData!["status"] as! String
                
                Loader.stopLoader()
                
                if status == "success"{
                    self.isValidNumberFromServer = true
                }else{
                    self.isValidNumberFromServer = false
                    
                    if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
                        newViewController.currentPhoneNumber = parameters["phone_number"] as? String
                        self.present(newViewController, animated: true, completion: nil)
                    }
                }
                
                self.validateForm()
                
            }, errorHandler: { (error) in
                Loader.stopLoader()
                self.outAlertError(message: "We could not check your phone please try again: \(error.debugDescription)")
            })
        } else {
            parameters["password"] = editPassword.text
            parameters["device_type"] = "A"
            parameters["device_id"] = UserDefaults.standard.value(forKey: "device_token") as? String
            
            WebServices.service.webServicePostRequest(.post, .user, .loginPhone, parameters as Dictionary<String, Any>, successHandler: { (response) in
                let jsonData = response
                let status = jsonData!["status"] as! String
                let token = jsonData!["token"] as? String
                let userDetails = jsonData!["userDetails"] as? Dictionary<String, Any>
                
                Loader.stopLoader()
                
                if status == "success" && token != nil {
                    self.authFirebaseForPhoneLogin(token: token!, jsonData:jsonData!, userDetails:userDetails!)
                } else if (status == "duplicate"){
                    self.outAlertError(message: "Registration phone number is already registered, go back to login and click 'forgot password help' if you don't remember your password")
                } else {
                    self.outAlertError(message: "Login failed, wrong phone number or password")
                }
            }, errorHandler: { (error) in
                Loader.stopLoader()
                self.outAlertError(message: "Login failed: \(error.debugDescription)")
            })
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Delegates
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        // set state
        isValidNumber = isValid
        validateForm()
    }
    
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        
        if textField == editPhone {
            isValidNumberFromServer = false
        }
        
        validateForm()
    }
}
