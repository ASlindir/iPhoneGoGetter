//
//  PhoneViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

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
                
                if status != "success"{
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
    
    //MARK:-  Calculate User Age
    func calculateAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!
    }

    private func startThisUser(jsonData: Dictionary<String, Any>?,token: String?){
        // set email
        if let userDetails = jsonData!["userDetails"] as? Dictionary<String, Any> {
        let email = userDetails["email"] as? String

        let fuser = Auth.auth().currentUser
        fuser?.updateEmail(to: email!, completion: {(error)  in
            if let err = error{
                self.outAlertError(message:"The email on your Facebook asccount is already associated with a Slindir user who has a telephone based login, please try logging in with your phone number.")
                // need deleteaccount right here
                print("Error :- ",err)
            }
            else{
                let status = jsonData!["status"] as! String
                
                if status == "success"{
                        let welcomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
                        welcomeViewController?.customAccessToken = token!
                        welcomeViewController?.fbLoginType = 1
                        welcomeViewController?.userDetails = userDetails
                        welcomeViewController?.jsonDataFromPhoneLogin = jsonData
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window!.rootViewController = welcomeViewController
                }
            }
            });
        }
    }
            
    func callDeleteAccountWebService() {
        let facebookId = LocalStore.store.getFacebookID()
        var parameters = Dictionary<String,Any>()
        parameters["user_fb_id"] = facebookId
        WebServices.service.webServicePostRequest(.post, .user, .deleteAccount, parameters, successHandler: { (response) in
            Loader.stopLoader()
            
        }, errorHandler: { (error) in
            
        })
    }
            
    func authFirebaseForPhoneRegistration(token: String?, jsonData: Dictionary<String, Any>?) {
        // TODO: Firebase auth and save token.
           // setup firebase
        DispatchQueue.main.async {
	            Auth.auth().signIn(withCustomToken: token!, completion: { (user, error) in
                if let err = error{
                    print("Error :- ",err)
                    // delete user record and display error here
                     self.callDeleteAccountWebService();
                }else{
                    let userDetails = jsonData!["userDetails"] as? Dictionary<String, Any>
                    let fbid = userDetails!["user_fb_id"]
                    DispatchQueue.main.async {
                        LocalStore.store.facebookID = fbid as! String?
                        LocalStore.store.facebookDetails = nil
                        FirebaseObserver.observer.observeFriendList()
                        FirebaseObserver.observer.observeFriendsRemoved()
                        self.startThisUser(jsonData:jsonData, token:token)
                    }
                }
            })
        }
    }
    
    // MARK: - Touches
    
    @IBAction func btnRegister(_ sender: Any) {
        if editPhoneCode.text == nil || editPhoneCode.text!.isEmpty || editPhoneCode.text!.count < 6 {
            outAlertError(message: "The phone code must be 6 characters")
        } else {
            if currentUser?.phoneNumber != nil {
                Loader.startLoaderV2(true)
                let formatter = DateFormatter()
                // initially set the format based on your datepicker date / server String
                formatter.dateFormat = "yyyy-MM-dd"
                let dobstr = formatter.string(from: currentUser!.birthday! ) // string purpose I add here
                var parameters = Dictionary<String, Any?>()
                parameters["phone_number"] = currentUser?.phoneNumber
                parameters["phone_code"] = editPhoneCode.text
                parameters["user_name"] = currentUser?.firstName	    
                parameters["pwd1"] = currentUser?.password
                parameters["pwd2"] = currentUser?.password
                parameters["dob"] = dobstr
                parameters["gender"] = currentUser?.gender == .male ? "M" : "F"
                parameters["device_type"] = "A"
                parameters["email"] = currentUser?.email
                parameters["device_id"] = UserDefaults.standard.value(forKey: "device_token") as? String

                WebServices.service.webServicePostRequest(.post, .user, .registernewuser, parameters as Dictionary<String, Any>, successHandler: { (response) in
                    let jsonData = response
                    let status = jsonData!["status"] as! String
                    let token = jsonData?["token"] as? String
                    //let userDetails = jsonData?["userDetails"] as? String
                    let userDetails = jsonData!["userDetails"] as? Dictionary<String, Any>
                    Loader.stopLoader()

                    if status == "success" {
                        LocalStore.store.facebookID = userDetails!["user_fb_id"] as! String?
                        self.authFirebaseForPhoneRegistration(token: token, jsonData: jsonData)
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
