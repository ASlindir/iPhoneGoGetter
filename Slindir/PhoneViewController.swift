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
    
    private func registerFirebaseForPhoneLogin(token: String?, userDetails: String?) {
        // TODO: Firebase auth and save token.
        
        self.outAlertSuccess(message: "Congrats!!! Firebase auth and save token!", compliteHandler: {
            // save token and etc
            let welcomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
            welcomeViewController?.customAccessToken = token!
            welcomeViewController?.fbLoginType = 1
            welcomeViewController?.userDetails = userDetails
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = welcomeViewController
        })
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
                print("Error :- ",err)
            }
            else{
                let status = jsonData!["status"] as! String
                
                if status == "success"{
                    if let message = jsonData!["message"] as? String {
                        if message == "User is already Registered" {
                            Loader.stopLoader()
                            DispatchQueue.main.async {
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
                                    
                                    //                                let del = UIApplication.shared.delegate as! AppDelegate
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                                    let navigationController = UINavigationController(rootViewController: controller)
                                    navigationController.interactivePopGestureRecognizer?.isEnabled = false
                                    controller.isRootController = true
                                    del.window?.rootViewController = navigationController
                            }
                        }
                        else {
                            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                AnalyticsParameterItemID: "id-Signup",
                                AnalyticsParameterItemName: "Signup"
                                ])
                            if userDetails["gender"] as! String == "male" {
                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                    AnalyticsParameterItemID: "id-GenderMale",
                                    AnalyticsParameterItemName: String(format:"Gender: %@", userDetails["gender"] as! CVarArg)
                                    ])
                            }
                            else {
                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                    AnalyticsParameterItemID: "id-GenderFemale",
                                    AnalyticsParameterItemName: String(format:"Gender: %@", userDetails["gender"] as! CVarArg)
                                    ])
                            }
                            
                            if self.calculateAge(birthday:userDetails["dob"] as! String) < 25{
                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                    AnalyticsParameterItemID: "id-Age-Under-25",
                                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:userDetails["dob"] as! String))
                                    ])
                            }
                            else if self.calculateAge(birthday:userDetails["dob"] as! String) >= 25 && self.calculateAge(birthday:userDetails["dob"] as! String) <= 35{
                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                    AnalyticsParameterItemID: "id-Age-25-To-35",
                                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:userDetails["dob"] as! String))
                                    ])
                            }
                            else if self.calculateAge(birthday:userDetails["dob"] as! String) >= 36 && self.calculateAge(birthday:userDetails["dob"] as! String) <= 50{
                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                    AnalyticsParameterItemID: "id-Age-36-To-50",
                                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:userDetails["dob"] as! String))
                                    ])
                            }
                            else {
                                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                                    AnalyticsParameterItemID: "id-Age-Over-50",
                                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:userDetails["dob"] as! String))
                                    ])
                            }
                            let del = UIApplication.shared.delegate as! AppDelegate
                            if del.latitude != 0.0 && del.longitude != 0.0 {
                                del.saveUserLocation()
                            }
                            else {
                                del.startLocationManager()
                            }
                            Loader.stopLoader()
                            self.getUserDetails(true)
//                            self.showDataOnLabel(self.fbName)
                        }
                    }
                    
                    let welcomeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController
                    welcomeViewController?.customAccessToken = token!
                    welcomeViewController?.fbLoginType = 1
                    welcomeViewController?.userDetails = userDetails
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
                    self.startThisUser(jsonData:jsonData, token:token)
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
