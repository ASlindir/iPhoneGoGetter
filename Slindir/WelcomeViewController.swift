    //
    //  WelcomeViewController.swift
    //  Slindir
    //
    //  Created by Batth on 13/09/17.
    //  Copyright © 2017 Batth. All rights reserved.
    //
    
    import UIKit
    import FBSDKCoreKit
    import FirebaseDatabase
    import FirebaseAuth
    import Firebase
    
    class WelcomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITabBarControllerDelegate {
        
        //MARK:-  IBOutlets , Variables and Constants
        
        @IBOutlet weak var imgViewBackground: UIImageView!
        
        @IBOutlet weak var lblName: UILabel!
        @IBOutlet weak var lblIntro: UILabel!
        @IBOutlet weak var lblDescription: UILabel!
        
        @IBOutlet weak var viewButtonsAndDesc: UIView!
        @IBOutlet weak var viewRequestActivities : UIView!
        let viewBlack: UIView = {
            let blackView = UIView()
            blackView.backgroundColor = .black
            blackView.alpha = 0.4
            blackView.translatesAutoresizingMaskIntoConstraints = false
            return blackView
        }()
        
        @IBOutlet weak var btnLetsStarted: UIButton!
        @IBOutlet weak var btnCancelMail: UIButton!
        @IBOutlet weak var btnSendMail: UIButton!
        @IBOutlet weak var btnClose: UIButton!
        
        @IBOutlet weak var collectonView: UICollectionView!
        
        @IBOutlet weak var topTapUntapLbl: NSLayoutConstraint!
        @IBOutlet weak var constraintLogoTop: NSLayoutConstraint!
        @IBOutlet weak var constraintLogoLeading: NSLayoutConstraint!
        @IBOutlet weak var constraintLogoTrailing: NSLayoutConstraint!
        
        var userDetails:Dictionary<String,Any>?
        var accesToken: AccessToken?
        var customAccessToken = ""
        var fbLoginType = 0
        var jsonDataFromPhoneLogin : Dictionary<String,Any>?
        
        var arrayTitles = [String]()
        var arrayImages = [UIImage]()
        var arraySelectedImages = [UIImage]()
        
        var selectedIndex = [String]()
        var selectedActivites: [String]?
        var animateCollectionView = false
        var fbName: String!
        var credential: AuthCredential!
        
        private lazy var ref: DatabaseReference = Database.database().reference()
        
        private lazy var friendRef: DatabaseReference = Database.database().reference().child("friends")
        
        var isPresent: Bool = false
        
        override func viewDidLoad() {
            super.viewDidLoad()
            //        ClientLog.WriteClientLog( msgType: "ios", msg:"welcomeloaded");
            
            if UIScreen.main.bounds.size.height >= 736 {
                self.topTapUntapLbl.constant = 140
                self.view.layoutIfNeeded()
            }
            
            addDataInArray()
            addTheRequestActivityView()
            //getDataFromFB()
            
            if isPresent{
                self.imgViewBackground.image = #imageLiteral(resourceName: "blurBackground")
                self.btnLetsStart(nil)
                self.btnClose.isHidden = false
                let image = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
                self.btnClose.setImage(image, for: .normal)
                self.btnClose.tintColor = UIColor(red: 0, green: 175/255, blue: 166/255, alpha: 1)
                self.lblIntro.text = "TAP / UNTAP TO EDIT YOUR 4 ACTIVITIES"
            }else{
                
                self.lblIntro.text = "PLEASE SELECT 4 ACTIVITIES"
                
                self.btnClose.isHidden = true
                if CustomClass.sharedInstance.isAudioPlay{
                    CustomClass.sharedInstance.stopAudio()
                }
                if (fbLoginType==0){ // fb, 1 phone, 2, registering
                    getDataFromFB();
                }
                else{
                    launchPhoneUser();
                }
                btnLetsStarted.alpha = 0
                lblDescription.alpha = 0
                collectonView.alpha = 0
                self.lblIntro.alpha = 0
            }
            if selectedActivites != nil{
                selectedIndex = selectedActivites!
                collectonView.reloadData()
            }
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            del.currentController = self
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            btnLetsStarted.layer.cornerRadius = btnLetsStarted.frame.size.height/2
        }
        
        //MARK:-  Memory Management
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        
        
        //MARK:-  Local Methoda
        
        func addTheRequestActivityView(){
            self.view.addSubview(viewBlack)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: [:], views: ["v0":viewBlack]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: [:], views: ["v0":viewBlack]))
            
            self.view.addSubview(viewRequestActivities)
            viewRequestActivities.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: viewRequestActivities, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: viewRequestActivities, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
            viewRequestActivities.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
            viewRequestActivities.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
            viewRequestActivities.shadow(0.8, 3, .black, CGSize(width: 1, height: 1))
            self.viewRequestActivities.alpha = 0
            self.viewBlack.alpha = 0
            self.view.sendSubviewToBack(viewRequestActivities)
            self.view.sendSubviewToBack(viewBlack)
            self.btnSendMail.shadowButton(0.4, 2, .black, CGSize(width: 3, height: 3))
            self.btnCancelMail.shadowButton(0.4, 2, .black, CGSize(width: 3, height: 3))
            
        }
        
        func showRequestActivityView(){
            self.view.bringSubviewToFront(viewBlack)
            self.view.bringSubviewToFront(viewRequestActivities)
            self.viewRequestActivities.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.viewRequestActivities.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.viewBlack.alpha = 0.5
                self.viewRequestActivities.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { (completed) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewRequestActivities.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.viewRequestActivities.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: { (completed) in
                        
                    })
                })
            }
        }
        
        @objc func animateActivityCollectionView(){
            UIView.animate(withDuration: 0.5, animations: {
                self.collectonView.setContentOffset(CGPoint(x: 0, y: 200), animated: false)
            }) { (completed) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.collectonView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }, completion: { (completed) in
                    self.collectonView.reloadData()
                })
            }
        }
        func hideRequestView(){
            UIView.animate(withDuration: 0.5, animations: {
                self.viewBlack.alpha = 0
                self.viewRequestActivities.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }) { (completed) in
                self.viewRequestActivities.alpha = 0
                self.viewBlack.alpha = 0
                self.view.sendSubviewToBack(self.viewRequestActivities)
                self.view.sendSubviewToBack(self.viewBlack)
            }
        }
        
        func addDataInArray(){
            arrayTitles = ["Archery","Badminton","Baseball","Basketball","Bowling","Boxing","Car Racing","Cycling","Extreme Sports","Fencing","Golf","Gym","Hiking","Hockey","Horse Riding","Motor Cycling","Mountain Biking","Paddling","Ping Pong","Rock Climbing","Rugby","Running","Sailing","Scuba Diving","Skater","Skiing","Snow Boarding","Soccer","Surfer","Swimming","Tennis","Triathlon","Volleyball","Water Polo","Water Sports","Wrestling","Yoga"]
            arrayImages = [#imageLiteral(resourceName: "archeryUnSel"),#imageLiteral(resourceName: "badmintonUnSel"),#imageLiteral(resourceName: "baseballUnSel"),#imageLiteral(resourceName: "basketballUnSel"),#imageLiteral(resourceName: "bowlingUnSel"),#imageLiteral(resourceName: "boxingUnSel"),#imageLiteral(resourceName: "carRacingUnSel"),#imageLiteral(resourceName: "cyclingUnSel"),#imageLiteral(resourceName: "extremeSportsUnSel"),#imageLiteral(resourceName: "fencingUnSel"),#imageLiteral(resourceName: "golfUnSel"),#imageLiteral(resourceName: "gymUnSel"),#imageLiteral(resourceName: "hikingUnSel"),#imageLiteral(resourceName: "hockeyUnSel"),#imageLiteral(resourceName: "horseRidingUnSel"),#imageLiteral(resourceName: "motorCyclingUnSel"),#imageLiteral(resourceName: "moutainBikingUnSel"),#imageLiteral(resourceName: "paddlingUnSel"),#imageLiteral(resourceName: "pingPongUnSel"),#imageLiteral(resourceName: "rockClimbingUnSel"),#imageLiteral(resourceName: "rugbyUnSel"),#imageLiteral(resourceName: "runningUnSel"),#imageLiteral(resourceName: "sailingUnSel"),#imageLiteral(resourceName: "scubaDivingUnSel"),#imageLiteral(resourceName: "skaterUnSel"),#imageLiteral(resourceName: "skiingUnSel"),#imageLiteral(resourceName: "snowBoardingUnSel"),#imageLiteral(resourceName: "soccerUnSel"),#imageLiteral(resourceName: "surferUnSel"),#imageLiteral(resourceName: "swimmingUnSel"),#imageLiteral(resourceName: "tennisUnSel"),#imageLiteral(resourceName: "triathlonUnSel"),#imageLiteral(resourceName: "volleyballUnSel"),#imageLiteral(resourceName: "waterPoloUnSel"),#imageLiteral(resourceName: "waterSportsUnSel"),#imageLiteral(resourceName: "wrestlingUnSel"),#imageLiteral(resourceName: "yogaUnSel")]
            
            arraySelectedImages = [#imageLiteral(resourceName: "archerySel"),#imageLiteral(resourceName: "badmintonSel"),#imageLiteral(resourceName: "baseballSel"),#imageLiteral(resourceName: "basketballSel"),#imageLiteral(resourceName: "bowlingSel"),#imageLiteral(resourceName: "boxingSel"),#imageLiteral(resourceName: "carracingSel"),#imageLiteral(resourceName: "cyclingSel"),#imageLiteral(resourceName: "extremesportsSel"),#imageLiteral(resourceName: "fencingSel"),#imageLiteral(resourceName: "golfSel"),#imageLiteral(resourceName: "gymSel"),#imageLiteral(resourceName: "hikingSel"),#imageLiteral(resourceName: "hockeySel"),#imageLiteral(resourceName: "horseridingSel"),#imageLiteral(resourceName: "motorcyclingSel"),#imageLiteral(resourceName: "mountainbikingSel"),#imageLiteral(resourceName: "paddlingSel"),#imageLiteral(resourceName: "pingpongSel"),#imageLiteral(resourceName: "rockclimbingSel"),#imageLiteral(resourceName: "rugbySel"),#imageLiteral(resourceName: "runningSel"),#imageLiteral(resourceName: "sailingSel"),#imageLiteral(resourceName: "scubadivingSel"),#imageLiteral(resourceName: "skaterSel"),#imageLiteral(resourceName: "skiingSel"),#imageLiteral(resourceName: "snowboardingSel"),#imageLiteral(resourceName: "soccerSel"),#imageLiteral(resourceName: "surferSel"),#imageLiteral(resourceName: "swimmingSel"),#imageLiteral(resourceName: "tennisSel"),#imageLiteral(resourceName: "triathlonSel"),#imageLiteral(resourceName: "volleyballSel"),#imageLiteral(resourceName: "waterpoloSel"),#imageLiteral(resourceName: "watersportsSel"),#imageLiteral(resourceName: "wrestlingSel"),#imageLiteral(resourceName: "yogaSel")]
            
        }
        
        func showDataOnLabel(_ name: String?){
            lblName.text = ""
            if let textName = name{
                LocalStore.store.saveName = textName
                LocalStore.store.login = true
                let nameText = "WELCOME, \(textName)"
                lblName.animate(newText: nameText, characterDelay: 0.1) { (completed:Bool) in
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    //                UIView.transition(with: self.imgViewBackground, duration: 1, options: .transitionCrossDissolve, animations: {
                    //                    //self.imgViewBackground.image = #imageLiteral(resourceName: "blurBackground")
                    //                }) { (completed: Bool) in
                    self.btnLetsStarted.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.lblDescription.transform = CGAffineTransform(scaleX: 0, y: 0)
                    // UIView.animate(withDuration: 0.4, animations: {
                    self.btnLetsStarted.transform = .identity
                    self.btnLetsStarted.alpha = 1
                    self.lblDescription.transform = .identity
                    // self.lblDescription.alpha = 1
                    //                    }, completion: { (completed: Bool) in
                    //
                    //   })
                    // }
                }
            }
        }
        
        func webServiceCall(_ email: String?){
            
        }
        
        func saveUserDetails(_ userId: String){
            
        }
        
        func doLoadUserWithUserDetails(jsonData : Dictionary<String, Any>, doBrains: Bool){
            Loader.stopLoader()
            DispatchQueue.main.async {
                if let userDetails = jsonData["userDetails"] as? Dictionary<String, Any> {
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
                    
                    if (doBrains){
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
                    }
                    //                                let del = UIApplication.shared.delegate as! AppDelegate
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                    let navigationController = UINavigationController(rootViewController: controller)
                    navigationController.interactivePopGestureRecognizer?.isEnabled = false
                    controller.isRootController = true
                    del.window?.rootViewController = navigationController
                }
            }
        }
        
        func doAnalytics(details: Dictionary<String, Any?>){
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-Signup",
                AnalyticsParameterItemName: "Signup"
                ])
            if details["gender"] as! String == "male" {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-GenderMale",
                    AnalyticsParameterItemName: String(format:"Gender: %@", details["gender"] as! CVarArg)
                    ])
            }
            else {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-GenderFemale",
                    AnalyticsParameterItemName: String(format:"Gender: %@", details["gender"] as! CVarArg)
                    ])
            }
            
            if self.calculateAge(birthday:details["dob"] as! String) < 25{
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Age-Under-25",
                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:details["dob"] as! String))
                    ])
            }
            else if self.calculateAge(birthday:details["dob"] as! String) >= 25 && self.calculateAge(birthday:details["dob"] as! String) <= 35{
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Age-25-To-35",
                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:details["dob"] as! String))
                    ])
            }
            else if self.calculateAge(birthday:details["dob"] as! String) >= 36 && self.calculateAge(birthday:details["dob"] as! String) <= 50{
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Age-36-To-50",
                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:details["dob"] as! String))
                    ])
            }
            else {
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Age-Over-50",
                    AnalyticsParameterItemName: String(format:"Age: %d",self.calculateAge(birthday:details["dob"] as! String))
                    ])
            }
            
        }
        
        //MARK:-  WebService Methods
        
        func loginWithFacebook(){
            let facebookID = LocalStore.store.getFacebookID()
            let facebookDetails = LocalStore.store.getFacebookDetails()
            print(facebookDetails as Any)
            var parameters = Dictionary<String, Any?>()
            
            parameters["profile_pic"] = ""
            if let picture = facebookDetails!["picture"] as? [String:Any]{
                if let data = picture["data"] as? [String: Any]{
                    if let url = data["url"] as? String{
                        parameters["profile_pic"] = url
                    }
                }
            }
            
            parameters["user_name"] = ""
            if let name = facebookDetails!["first_name"]{
                parameters["user_name"] = name as! String
            }else{
                if let fullName = facebookDetails!["name"]{
                    parameters["user_name"] = fullName as! String
                }
            }
            
            parameters["email"] = ""
            if let email = facebookDetails!["email"]{
                parameters["email"] = email as! String
            }
            
            parameters["gender"] = ""
            if let gender = facebookDetails!["gender"]{
                parameters["gender"] = gender as! String
            }
            
            parameters["education"] = ""
            if let education = facebookDetails!["education"] as? [[String: Any]]{
                if education.count > 0 {
                    let educationDict = education.last
                    print(educationDict!["school"] ?? "")
                    if let concentration = educationDict!["school"] as? NSDictionary{
                        parameters["education"] = concentration["name"] as! String
                    }
                }
            }
            
            parameters["work"] = ""
            if let work = facebookDetails!["work"] as? [[String: Any]]{
                if work.count > 0 {
                    let workDict = work.first
                    if let concentration = workDict!["employer"]  as? NSDictionary {
                        parameters["work"] = concentration["name"] as! String
                    }
                }
            }
            
            parameters["age_range"] = "20,40"
            if let age_range = facebookDetails!["age_range"] as? NSDictionary {
                let min = age_range["min"] as? Int
                parameters["age_range"] = String(format:"%d,%d",min!,min!+20 )
            }
            
            //if let location = facebookDetails!["location"] as? NSDictionary {
            //let name = location["name"] as! String
            // parameters["location"] = name
            //}else {
            // parameters["location"] = ""
            //}
            
            parameters["image1"] = ""
            parameters["image2"] = ""
            parameters["image3"] = ""
            parameters["image4"] = ""
            if let imagesDict = facebookDetails!["photos"] as? NSDictionary{
                if let images = imagesDict["data"] as? [[String: Any]] {
                    for i in 0..<4 {
                        if images.count > i {
                            let imgSources:[[String: Any]] = images[i]["images"] as! [[String : Any]]
                            parameters[String(format:"image%d",i+1)] = imgSources[0]["source"]
                        }
                        else {
                            parameters[String(format:"image%d",i+1)] = ""
                        }
                    }
                }
            }
            
            parameters["user_fb_id"] = facebookID
            
            parameters["dob"] = ""
            var dateOfBirth:Int = 0
            if let dob = facebookDetails!["birthday"] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
                dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
                let dateFormat1: Date? = dateFormatter.date(from: dob as! String)
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                df.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
                df.locale = Locale.init(identifier: "en_US_POSIX")
                let dateOfBirthStr: String = df.string(from: dateFormat1!)
                parameters["dob"] = dateOfBirthStr
                
                let ageComponents = Calendar.current.dateComponents([.year], from: dateFormat1!, to: Date())
                dateOfBirth = ageComponents.year!
            }
            else {
                Loader.stopLoader()
                let alertController = UIAlertController(title: NSLocalizedString("Warning", comment:""), message: "Please enter your date of birth. You will not be able to edit this field later, so it has to be accurate.", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Enter DOB: yyyy-MM-dd"
                })
                alertController.addAction(action(NSLocalizedString("Done", comment: ""), .default, actionHandler: { (alertAction) in
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    let textField = alertController.textFields?.first
                    if textField?.text?.count == 0 {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else if (df.date(from: (textField?.text)!)) == nil{
                        textField?.text = ""
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        
                        parameters["dob"] = textField?.text
                        
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        df.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
                        df.locale = Locale.init(identifier: "en_US_POSIX")
                        let ageComponents = Calendar.current.dateComponents([.year], from: df.date(from: (textField?.text)!) ?? Date(), to: Date())
                        dateOfBirth = ageComponents.year!
                        
                        if dateOfBirth > 70 || dateOfBirth < 18 {
                            Loader.stopLoader()
                            let alertController = UIAlertController(title: "", message: "We are sorry but you do not have a qualified age to join our service.", preferredStyle: UIAlertController.Style.alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        print("Parameters \(parameters)")
                        
                        WebServices.service.webServicePostRequest(.post, .user, .login, parameters as Dictionary<String, Any>, successHandler: { (response) in
                            let jsonData = response
                            let status = jsonData!["status"] as! String
                            
                            if status == "success"{
                                if let message = jsonData!["message"] as? String {
                                    if message == "User is already Registered" {
                                        self.doLoadUserWithUserDetails(jsonData : jsonData!, doBrains:  false)
                                    }
                                    else {
                                        self.doAnalytics(details: parameters)
                                        let del = UIApplication.shared.delegate as! AppDelegate
                                        if del.latitude != 0.0 && del.longitude != 0.0 {
                                            del.saveUserLocation()
                                        }
                                        else {
                                            del.startLocationManager()
                                        }
                                        Loader.stopLoader()
                                        self.getUserDetails(true)
                                        self.showDataOnLabel(self.fbName)
                                    }
                                }
                            }else{
                            }
                        }, errorHandler: { (error) in
                            Loader.stopLoader()
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if dateOfBirth > 70 || dateOfBirth < 18 {
                Loader.stopLoader()
                let alertController = UIAlertController(title: "", message: "We are sorry but you do not have a qualified age to join our service.", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    self.navigationController?.popViewController(animated: true)
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }//
            print("Parameters \(parameters)")
            
            WebServices.service.webServicePostRequest(.post, .user, .login, parameters as Dictionary<String, Any>, successHandler: { (response) in
                let jsonData = response
                let status = jsonData!["status"] as! String
                
                if status == "success"{
                    if let message = jsonData!["message"] as? String {
                        if message == "User is already Registered" {
                            self.doLoadUserWithUserDetails(jsonData : jsonData!, doBrains:  true)
                        }
                        else {
                            self.doAnalytics(details: parameters)
                            let del = UIApplication.shared.delegate as! AppDelegate
                            if del.latitude != 0.0 && del.longitude != 0.0 {
                                del.saveUserLocation()
                            }
                            else {
                                del.startLocationManager()
                            }
                            Loader.stopLoader()
                            
                            self.getUserDetails(true)
                            self.showDataOnLabel(self.fbName)
                        }
                    }
                }else{
                    Loader.stopLoader()
                }
            }, errorHandler: { (error) in
                Loader.stopLoader()
                self.navigationController?.popViewController(animated: true)
            })
            
        }
        
        func saveUserIntrests(_ intrests: [String]){
            let facebookID = LocalStore.store.getFacebookID()
            let interestString = intrests.joined(separator: ",")
            var parameters = Dictionary<String, Any?>()
            parameters["user_fb_id"] = facebookID
            parameters["activities"] = interestString
            print("Parameters \(parameters)")
            //        Loader.startLoader(true)
            Loader.sharedLoader.statLoader(true)
            //        DispatchQueue.global(qos: .background).async {
            WebServices.service.webServicePostRequest(.post, .user, .saveUserInterests, parameters as Dictionary<String, Any>, successHandler: { (response) in
                Loader.stopLoader()
                let jsonData = response
                let status = jsonData!["status"] as! String
                if status == "success"{
                    DispatchQueue.global(qos: .background).async {
                        self.getUserDetails(true)
                    }
                    DispatchQueue.main.async {
                        if self.isPresent{
                            self.dismiss(animated: true, completion: nil)
                        }else{
                            let editProfileController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                            self.navigationController?.pushViewController(editProfileController, animated: true)
                        }
                    }
                }else{
                    self.showAlertWithOneButton("Error!", "Please check your internet connection", "OK")
                }
            }, errorHandler: { (error) in
                Loader.stopLoader()
                self.showAlertWithOneButton("Error!", "Please check your internet connection", "OK")
            })
            //  }
        }
        
        
        //MARK:-  UICollectionView Data Source
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if animateCollectionView {
                return arrayTitles.count
            }
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WelcomeCollectionCell
            cell.layoutIfNeeded()
            cell.lblTitle.text = arrayTitles[indexPath.row]
            cell.imgViewCircle.layer.cornerRadius = cell.imgViewCircle.frame.size.width / 2
            
            if selectedIndex.contains(arrayTitles[indexPath.row]) {
                cell.imgViewCircle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                cell.lblTitle.isHidden = true
                cell.imgViewCircle.image = arraySelectedImages[indexPath.item]
            }else{
                cell.imgViewCircle.transform = CGAffineTransform(scaleX: 1, y: 1)
                cell.lblTitle.isHidden = false
                cell.imgViewCircle.image = arrayImages[indexPath.item]
            }
            
            return cell
        }
        
        //MARK:-  UICollection View Delegates
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if CustomClass.sharedInstance.isAudioPlay!{
                CustomClass.sharedInstance.stopAudio()
            }
            let cell = collectionView.cellForItem(at: indexPath) as! WelcomeCollectionCell
            if selectedIndex.contains(arrayTitles[indexPath.row]) {
                CustomClass.sharedInstance.playAudio(.popRed, .mp3)
                if let index = selectedIndex.index(of: arrayTitles[indexPath.row]) {
                    selectedIndex.remove(at: index)
                }
                cell.lblTitle.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    cell.imgViewCircle.transform = CGAffineTransform(scaleX: 1, y: 1)
                    cell.imgViewCircle.image = self.arrayImages[indexPath.item]
                    cell.lblTitle.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: { (completed: Bool) in
                })
                
            }else{
                CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
                if selectedIndex.count >= 4 {
                    showAlert(selectedIndex)
                    return
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    cell.imgViewCircle.transform = CGAffineTransform(scaleX: 1.45, y: 1.45)
                    cell.imgViewCircle.image = self.arraySelectedImages[indexPath.item]
                    cell.lblTitle.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                }, completion: { (completed: Bool) in
                    cell.lblTitle.isHidden = true
                })
                selectedIndex.append(arrayTitles[indexPath.row])
                if selectedIndex.count == 4 {
                    if !isPresent{
                        saveUserIntrests(selectedIndex)
                    }else{
                        showAlert(selectedIndex)
                    }
                }
            }
        }
        
        
        //MARK:-  UICollection View Flow Layout Delegates
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let size = collectionView.frame.size.width/3
            return CGSize(width: size, height: size)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        //MARK:-  UICollection View Footer View
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "ActivityCollectionReusableView", for: indexPath) as! ActivityCollectionReusableView
            footerView.btnRequestActivity.addTarget(self, action: #selector(requestActivities), for: .touchUpInside)
            footerView.btnContinue.addTarget(self, action: #selector(changeTheActivities), for: .touchUpInside)
            footerView.layoutIfNeeded()
            footerView.btnRequestActivity.layer.cornerRadius = footerView.btnRequestActivity.frame.size.height/2
            footerView.btnContinue.layer.cornerRadius = footerView.btnContinue.frame.size.height/2
            
            if !isPresent{
                footerView.btnContinue.isHidden = true
            }else{
                footerView.btnContinue.isHidden = false
            }
            return footerView
        }
        //MARK:-  Local Methods
        
        func launchPhoneUser(){
            self.doLoadUserWithUserDetails(jsonData : self.jsonDataFromPhoneLogin!, doBrains:  true)
            Loader.stopLoader()
            let userDetails = self.jsonDataFromPhoneLogin!["userDetails"] as! Dictionary<String, Any>
            let username = userDetails["user_name"] as! String
            self.getUserDetails(true)
            self.showDataOnLabel(username)
            //Firebase Login
        }
        @objc func requestActivities(){
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            self.showRequestActivityView()
        }
        
        @objc func changeTheActivities(){
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            if selectedIndex.count < 4{
        	        showAlertWithOneButton("Slindir", "Please Select four activities", "OK")
                return
            }
            saveUserIntrests(selectedIndex)
        }
        
        func showAlert(_ activities: [String]){
            let yesAction = action("YES", .default) { (action) in
                self.saveUserIntrests(self.selectedIndex)
            }
            let noAction = action("NO", .default) { (action) in
                
            }
            var activitiesString: String? = nil
            for activity in activities{
                if activitiesString == nil{
                    activitiesString = activity
                }else{
                    activitiesString = activitiesString! + ", \(activity)"
                }
            }
            showAlertWithCustomButtons("Selected Activities", "You have selected \(activitiesString!)", yesAction,noAction)
            
        }
        
        func getDataFromFB(){
            Loader.startLoader(true)
            //        Loader.startLoader(true)
            if let token = accesToken {
                GraphRequest(graphPath: "me", parameters: ["fields":"id,name,email,birthday,age_range,gender,first_name,friends,picture.type(large).width(1080).height(1080),photos{images}"], tokenString: token.tokenString, version: nil, httpMethod: .get).start(completionHandler: { (connection, result, error) in
                    if error == nil {
                        if let responseDictionary = result as? [String:Any]{
                            //print(responseDictionary)
                            let name = responseDictionary["first_name"] as! String
                            if let friends = responseDictionary["friends"] as? [String:Any]{
                                let summary = friends["summary"] as? [String:Any]
                                let total_count = summary!["total_count"] as? Int
                                if total_count! < 10 {
                                    Loader.stopLoader()
                                    
                                    let alertController = UIAlertController(title: "", message: "We are sorry but you do not have a qualified facebook account to join our service. Please try again with a verified Facebook account.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        //                                    let loginManager = LoginManager()
                                        //                                    loginManager.logOut()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    
                                    alertController.addAction(okAction)
                                    self.present(alertController, animated: true, completion: nil)
                                    return
                                }
                                else {
                                    //Firebase Login
                                    DispatchQueue.main.async {
                                        Auth.auth().signIn(with: self.credential, completion: { (user, error) in
                                            if let err = error{
                                                print("Error :- ",err)
                                            }else{
                                                DispatchQueue.main.async {
                                                    LocalStore.store.facebookID = user?.user.uid
                                                    LocalStore.store.facebookDetails = responseDictionary
                                                    FirebaseObserver.observer.observeFriendList()
                                                    FirebaseObserver.observer.observeFriendsRemoved()
                                                    self.fbName = name
                                                    self.loginWithFacebook()
                                                }
                                            }
                                        })
                                    }
                                    
                                    
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    Auth.auth().signIn(with: self.credential, completion: { (user, error) in
                                        if let err = error{
                                            print("Error :- ",err)
                                        }else{
                                            DispatchQueue.main.async {
                                                LocalStore.store.facebookID = user?.user.uid
                                                LocalStore.store.facebookDetails = responseDictionary
                                                FirebaseObserver.observer.observeFriendList()
                                                FirebaseObserver.observer.observeFriendsRemoved()
                                                self.fbName = name
                                                self.loginWithFacebook()
                                            }
                                        }
                                    })
                                }
                            }
                            
                        }
                    }
                })
            }
        }
        
        
        
        //MARK:-  IBAction Methods
        
        @IBAction func btnLetsStart(_ sender: Any?){
            self.collectonView.isHidden = true
            if !isPresent{
                CustomClass.sharedInstance.stopAudio()
                CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            }
            
            constraintLogoTop.constant = 15
            
            constraintLogoLeading.constant = 135
            constraintLogoTrailing.constant = 135
            
            if UIScreen.main.bounds.size.width == 320{
                constraintLogoLeading.constant = 110
                constraintLogoTrailing.constant = 110
            }
            
            
            viewButtonsAndDesc.backgroundColor = .white
            viewButtonsAndDesc.alpha = 0.4
            UIView.animate(withDuration: 3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            
            self.imgViewBackground.image = #imageLiteral(resourceName: "blurBackground")
            
            UIView.animate(withDuration: 0.8, animations: {
                self.viewButtonsAndDesc.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.viewButtonsAndDesc.alpha = 0
                
            }) { (completed: Bool) in
                UIView.animate(withDuration: 0.4, animations: {
                    self.lblIntro.alpha = 1
                })
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.collectonView.alpha = 1
                self.collectonView.transform = .identity
            }) { (completed: Bool) in
                self.animateCollectionView = true
                self.collectonView.reloadData()
                self.collectonView.isHidden = false
                self.perform(#selector(self.animateActivityCollectionView), with: nil, afterDelay: 0.1)
            }
        }
        
        @IBAction func btnSendMail(_ sender: Any?){
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            self.view.endEditing(true)
            self.hideRequestView()
            var parameters = Dictionary<String, Any?>()
            
            let txt1 = self.view.viewWithTag(100) as! CustomTextField
            let txt2 = self.view.viewWithTag(101) as! CustomTextField
            let txt3 = self.view.viewWithTag(102) as! CustomTextField
            let txt4 = self.view.viewWithTag(103) as! CustomTextField
            
            let facebookID = LocalStore.store.getFacebookID()
            
            parameters["request_from_fb_id"] = facebookID
            parameters["requesting_to"] = "slindirapp@gmail.com,houarim@gmail.com"
            parameters["activity1"] = txt1.text
            parameters["activity2"] = txt2.text
            parameters["activity3"] = txt3.text
            parameters["activity4"] = txt4.text
            print(parameters)
            
            WebServices.service.webServicePostRequest(.post, .user, .requestNewActivities, parameters as Dictionary<String, Any>, successHandler: { (response) in
                
                
            }, errorHandler: { (error) in
            })
        }
        
        @IBAction func btnCancelMail(_ sender: Any?){
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            self.view.endEditing(true)
            self.hideRequestView()
        }
        
        @IBAction func btnClose(_ sender: Any?){
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            if selectedIndex.count >= 4 {
                showAlert(selectedIndex)
                return
            }
            //self.view.endEditing(true)
            //self.dismiss(animated: true, completion: nil)
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
        
    }
    
    //MARK:-  Welcome UICollection View Cell Class
    class WelcomeCollectionCell: UICollectionViewCell {
        
        @IBOutlet weak var imgViewCircle: UIImageView!
        
        @IBOutlet weak var lblTitle: UILabel!
        
        
        override func awakeFromNib() {
            super.awakeFromNib()
            self.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: 0.6, animations: {
                self.alpha = 1
                self.contentView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }) { (completed: Bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: { (completed: Bool) in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.contentView.transform = .identity
                    })
                })
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            layoutIfNeeded()
            imgViewCircle.layer.cornerRadius = imgViewCircle.bounds.size.width / 2
        }
        
        
        
    }
