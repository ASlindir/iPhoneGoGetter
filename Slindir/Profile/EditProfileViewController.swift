//
//  EditProfileViewController.swift
//  Slindir
//
//  Created by Batth on 22/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import Photos
import AVKit
import MobileCoreServices
import Crashlytics
import FBSDKCoreKit
import SDWebImage
import AVFoundation
import UIImage_ImageCompress
import MessageUI

class EditProfileViewController: UIViewController, UITextFieldDelegate, GalleryViewControllerDelegates, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RecordVideoDelegate, ProfileViewControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate{
    
//MARK:-  IBOutlets, Variables and Constants
    
    var playerViewController:AVPlayerViewController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //@IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgViewLogo: UIImageView!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var imgViewRecord: UIImageView!
    @IBOutlet weak var imgViewSetting: UIImageView!
    @IBOutlet weak var imgViewArrowOne: UIImageView!
    @IBOutlet weak var imgViewArrowTwo: UIImageView!
    @IBOutlet weak var imgViewArrowThree: UIImageView!
    @IBOutlet weak var imgViewHaveFun: UIImageView!
    @IBOutlet weak var imgViewMeetNewPeople: UIImageView!
    @IBOutlet weak var imgViewRelationShip: UIImageView!
    @IBOutlet weak var imgViewStandard: UIImageView!
    @IBOutlet weak var imgViewMetric: UIImageView!
    
   // @IBOutlet weak var txtFldName: UITextField!
   // @IBOutlet weak var txtFldAge: UITextField!
   // @IBOutlet weak var txtFldAddress: UITextField!
    @IBOutlet weak var txtFldTeam1: UITextField!
    @IBOutlet weak var txtFldTeam2: UITextField!
    @IBOutlet weak var txtFldTeam3: UITextField!
    @IBOutlet weak var txtFldTeam4: UITextField!
    @IBOutlet weak var txtFldOccupation: UITextField!
    
    @IBOutlet weak var txtViewDesc: UITextView!

    @IBOutlet weak var switchKids: UISwitch!
    @IBOutlet weak var switchWantKids: UISwitch!
    @IBOutlet weak var switchNotifications: UISwitch!
    @IBOutlet weak var switchSound: UISwitch!
    
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnMan: UIButton!
    @IBOutlet weak var btnWomen: UIButton!
    @IBOutlet weak var btnSliderQuizz: UIButton!
    @IBOutlet weak var btnReminder: UIButton!
    @IBOutlet weak var btnGotIt: UIButton!
    @IBOutlet weak var btnWatchVideoTut: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnChangeActivities: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnDeleteAccount: UIButton!
    
    @IBOutlet weak var btnUpdateSettings: UIButton!
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var rangeSliderHeight: RangeSlider!
    @IBOutlet weak var milesSlider: UISlider!
    
    @IBOutlet weak var lblAgeStart: UILabel!
    @IBOutlet weak var lblAgeMax: UILabel!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblFirstComma: UILabel!
    @IBOutlet weak var lblSecondComma: UILabel!
    @IBOutlet weak var lblTapToEdit: UILabel!
    @IBOutlet weak var lblYourPhoto: UILabel!
    @IBOutlet weak var lblNameHide: UILabel!
    @IBOutlet weak var lblAgeHide: UILabel!
    @IBOutlet weak var lblLocationHide: UILabel!
    @IBOutlet weak var lblScrollForMore: UILabel!
    @IBOutlet weak var lblMoreSettings: UILabel!
    @IBOutlet weak var lblHeightMin: UILabel!
    @IBOutlet weak var lblHeightMax: UILabel!
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewMoreSetting: UIView!
    @IBOutlet weak var viewRecordVideo: UIView!
    @IBOutlet weak var viewNameLocation: UIView!
    @IBOutlet weak var viewWhite: UIView!
    @IBOutlet weak var viewVideoProfile: UIView!
    @IBOutlet weak var viewWorkOutBuddy: UIView!
    @IBOutlet weak var viewShortTermDating: UIView!
    @IBOutlet weak var viewLongTermDating: UIView!
    
    @IBOutlet weak var heightUpdateButton: NSLayoutConstraint!
    @IBOutlet weak var constraintViewWhiteHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintViewWhiteTop: NSLayoutConstraint!
    @IBOutlet weak var heightNavigation: NSLayoutConstraint!
    
    @IBOutlet weak var bottomUpdateButton: NSLayoutConstraint!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var stackViewTeams: UIStackView!
    @IBOutlet weak var stackViewOccupation: UIStackView!
    @IBOutlet weak var stackViewWhy: UIStackView!
    @IBOutlet weak var stackViewheight: UIStackView!
    @IBOutlet weak var stackViewDescription: UIStackView!
    @IBOutlet weak var stackViewUnit: UIStackView!
    @IBOutlet weak var stackViewBtn: UIStackView!

    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var heightSlider: CustomSlider!
    @IBOutlet var lblHeight: UILabel!
    
    @IBOutlet weak var vwVideo: UIView!
    @IBOutlet weak var lblAddVideo: UILabel!
    var isBackClicked:Bool = false
    
    var player: AVPlayer!
    var videoController = AVPlayerViewController()
    
    var isFirstTime = true
    var timer = Timer()
    
    var username = ""
    var ageStr = ""
    var locationStr = ""
    var genderPreferences = ""
    var agePreferences = ("18","25")
    var heightPreferences = ("5.0","6.0")
    var distancePreference = "10"
    var strSpeech = ""
    var selectedUnit = "Standard"
    var heightValue:String = "5.6"
    
    var personalDetail = Dictionary<String, Any>()
    
    var isRootController: Bool = false
    var isMoreSetting: Bool = true
    var workoutBool: Bool = false
    var shortTermBool: Bool = false
    var longTermBool: Bool = false
    var videoCompleted: Bool = false
    
    var stackViews = [UIStackView]()
    var profileImages:[Any?] = [#imageLiteral(resourceName: "steve"),UIImage(named: ""),UIImage(named: ""),UIImage(named: ""),UIImage(named: ""),UIImage(named: "")]
    var activitiesArray:[String]?
    
    var selectedIndexPath: IndexPath?
    var previousIndexPath: IndexPath?
    
    var olderContentOffSet: CGFloat?
    
    var isSound:Bool = false
    var isNotification:Bool = false
    
//    var targetSize: CGSize {
//        let scale = UIScreen.main.scale
//        return CGSize(width: UIScreen.main.bounds.width - 110 * scale,
//                      height: collectionView.bounds.height * scale)
//    }
    
    var arrayKids:[String] = []
    var lookingFor:[String] = []
    
    var isVideo:Bool = false
    var videoURL:String = ""
    
    @IBOutlet weak var scrollVwCamera: UIScrollView!
    
    @IBOutlet weak var widthVwCamera: NSLayoutConstraint!
    @IBOutlet weak var vwCamera1: UIView!
    @IBOutlet weak var vwCamera2: UIView!
    @IBOutlet weak var vwCamera3: UIView!
    @IBOutlet weak var vwCamera4: UIView!
    @IBOutlet weak var vwCamera5: UIView!
    
    var openCameraView1: OpenCameraView!
    var openCameraView2: OpenCameraView!
    var openCameraView3: OpenCameraView!
    var openCameraView4: OpenCameraView!
    var openCameraView5: OpenCameraView!
    
    @IBOutlet weak var lblVideoHeader: UILabel!
    var isVideoLabelBlinked:Bool = false
    
     override func viewDidLoad() {
        //self.indicator.isHidden = true
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("UpdateLocation")), object: nil)
        
        UserDefaults.standard.set(true, forKey: "updateSettings")
        UserDefaults.standard.synchronize()
        
        FirebaseObserver.observer.observeMessages()
        FirebaseObserver.observer.observeNewChat()
        
        openCameraView1 = Bundle.main.loadNibNamed("OpenCameraView", owner: self, options: nil)![0] as? OpenCameraView
        openCameraView2 = Bundle.main.loadNibNamed("OpenCameraView", owner: self, options: nil)![0] as? OpenCameraView
        openCameraView3 = Bundle.main.loadNibNamed("OpenCameraView", owner: self, options: nil)![0] as? OpenCameraView
        openCameraView4 = Bundle.main.loadNibNamed("OpenCameraView", owner: self, options: nil)![0] as? OpenCameraView
        openCameraView5 = Bundle.main.loadNibNamed("OpenCameraView", owner: self, options: nil)![0] as? OpenCameraView
        
        self.btnReminder.isHidden = true
        navigationController?.navigationBar.isHidden = true
        imgViewRecord.shadow(0.6, 4, .black, CGSize(width: 3, height: 3))
        viewMoreSetting.alpha = 0
        milesSlider.addTarget(self, action: #selector(self.onSliderValueChanged(_:event:)), for: .valueChanged)
        heightSlider.addTarget(self, action: #selector(self.onSliderValueChanged(_:event:)), for: .valueChanged)
        
        viewWhite.alpha = 0
        
        
        if !LocalStore.store.notFirstTime() {
//            LocalStore.store.appNotFirstTime = true
            scrollView.isScrollEnabled = false
            scrollView.isUserInteractionEnabled = false
//            txtFldName.isUserInteractionEnabled = false
//            txtFldAge.isUserInteractionEnabled = false
//            txtFldAddress.isUserInteractionEnabled = false
            viewWhite.isHidden = false
            viewWhite.alpha = 1
        }else{
            self.view.alpha = 0
            scrollView.isScrollEnabled = true
            scrollView.isUserInteractionEnabled = true
//            txtFldName.isUserInteractionEnabled = true
//            txtFldAge.isUserInteractionEnabled = true
//            txtFldAddress.isUserInteractionEnabled = true
            viewWhite.isHidden = true
            viewWhite.alpha = 0
        }
        let image = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        btnBack.setImage(image, for: .normal)
        btnBack.tintColor = UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)
        hideTheViews()
        addTheGestures()
        upTheKeyboard()
        
        if !UserDefaults.standard.bool(forKey: "likedNotification") && !UserDefaults.standard.bool(forKey: "matchedNotification") && !UserDefaults.standard.bool(forKey: "newMatchedNotification") && !UserDefaults.standard.bool(forKey: "chatNotification") {
            DispatchQueue.main.async {
                self.perform(#selector(self.goToProfileController), with: nil, afterDelay: 0.1)
            }
        }
        
        if UIScreen.main.bounds.size.height >= 812 {
            self.heightNavigation.constant = 100
        }
        self.widthVwCamera.constant = UIScreen.main.bounds.width - 110
        self.view.layoutIfNeeded()
    }
    
    @objc func goToProfileController(){
        self.view.alpha = 1
        
        if !isRootController {
            let del = UIApplication.shared.delegate as! AppDelegate
            del.registerForRemoteNotifications()
        }
        
        if genderPreferences == "" || lookingFor.count == 0 {
            return
        }
        if isRootController {
            self.getUserDetails(false)
            let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileController.profileDelegate = self
            profileController.isAlreadyLogin = true
            navigationController?.pushViewController(profileController, animated: false)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0..<5 {
            switch (i) {
            case 0:
                if !vwCamera1.subviews.contains(openCameraView1) {
                    vwCamera1.addSubview(openCameraView1)
                }
                break
            case 1:
                if !vwCamera2.subviews.contains(openCameraView2) {
                    vwCamera2.addSubview(openCameraView2)
                }
                break
            case 2:
                if !vwCamera3.subviews.contains(openCameraView3) {
                    vwCamera3.addSubview(openCameraView3)
                }
                break
            case 3:
                if !vwCamera4.subviews.contains(openCameraView4) {
                    vwCamera4.addSubview(openCameraView4)
                }
                break
            case 4:
                if !vwCamera5.subviews.contains(openCameraView5) {
                    vwCamera5.addSubview(openCameraView5)
                }
                break;
            default:
                break
            }
        }
        
        if UserDefaults.standard.bool(forKey: "updateSettings") {
            self.settingThePersonalDetail()
        }
        
        if UserDefaults.standard.bool(forKey: "likedNotification") || UserDefaults.standard.bool(forKey: "matchedNotification") || UserDefaults.standard.bool(forKey: "chatNotification") || UserDefaults.standard.bool(forKey: "newMatchedNotification") {
            DispatchQueue.main.async {
                self.goToProfileController()
            }
        }
        
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.currentController = self
        
        if isRootController {
            btnBack.isHidden = false
        }else{
            btnBack.isHidden = true
        }
        if LocalStore.store.isQuizDone() {
            btnBack.isHidden = false
            self.btnSliderQuizz.setTitle("Learn more about the Slindir personality match", for: .normal)
            self.btnSliderQuizz.setTitleColor(.black, for: .normal)
            self.btnReminder.isHidden = true
            self.btnSliderQuizz.backgroundColor = .clear//UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)
            self.btnUpdateSettings.isHidden = false
            self.heightUpdateButton.constant = 0
            self.bottomUpdateButton.constant = 20
            self.view.layoutIfNeeded()
        }else{
            btnBack.isHidden = true
            self.btnSliderQuizz.setTitle("LET’S GET STARTED!", for: .normal)
            self.btnSliderQuizz.backgroundColor = .red
            self.btnUpdateSettings.isHidden = true
            self.heightUpdateButton.constant = -45
            self.bottomUpdateButton.constant = 0
            self.view.layoutIfNeeded()
        }
        
        if LocalStore.store.isHeightSet() {
            self.heightSlider.isUserInteractionEnabled = false
        }
        else {
            self.heightSlider.isUserInteractionEnabled = true
        }
    }

    @objc func updateLocation() {
        if !LocalStore.store.notFirstTime() {
            return
        }
        personalDetail = LocalStore.store.getUserDetails()
         username = ""
        if let name = personalDetail["user_name"] as? String {
            username = name
        }
        var age = 25
        if let dob = personalDetail["dob"] as? String {
            if dob != "" {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                df.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
                df.locale = Locale.init(identifier: "en_US_POSIX")
                let birthdayDate = df.date(from: dob )
                let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
                let now = Date()
                let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
                age = calcAge.year!
            }
        }
        
        ageStr = String(format:"%d",age)
        if let location = personalDetail["location"] as? String{
                if location != "" {
                    //self.lblSecondComma.text = ","
                    lblName.text = String(format:"%@, %d, %@",username,age,location)
                }
                else {
                    lblName.text = String(format:"%@, %d",username,age)
                    //self.lblSecondComma.text = ""
                }
            locationStr = location
                //self.lblAddress.text = location
            }
    }
    
    @objc func settingThePersonalDetail(){
        UserDefaults.standard.set(false, forKey: "updateSettings")
        UserDefaults.standard.synchronize()
        personalDetail = LocalStore.store.getUserDetails()
        print(personalDetail)

        if let aboutme = personalDetail["about_me"] as? String {
            print("About Me :- ",aboutme)
            self.txtViewDesc.text = aboutme
        }
        
        var age = 25
        if let dob = personalDetail["dob"] as? String {
            if dob != "" {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                df.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
                df.locale = Locale.init(identifier: "en_US_POSIX")
                let birthdayDate = df.date(from: dob )
                let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
                let now = Date()
                let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
                age = calcAge.year!
            }
        }
        
        if let name = personalDetail["user_name"] as? String {
            if let location = personalDetail["location"] as? String{
                if !LocalStore.store.notFirstTime() {
                   // LocalStore.store.appNotFirstTime = true
                    settingNameAgeAddress(name, String(format: "%d",age), location)
                }
                else {
                    lblName.text = String(format:"%@, %d, %@",name,age,location)
//                    self.lblFirstComma.text = ","
//                    self.lblAge.text = String(format: "%d",age)
//                    self.lblSecondComma.text = ","
//                    self.lblAddress.text = location
                }
                username = name
                ageStr = String(format:"%d",age)
                locationStr = location
            }else{
                if !LocalStore.store.notFirstTime() {
                    //LocalStore.store.appNotFirstTime = true
                    //self.lblSecondComma.text = ""
                    //self.lblAddress.text = ""
                    settingNameAgeAddress(name, String(format: "%d",age), "")
                }
                else {
                    lblName.text = String(format:"%@, %d",name,age)
//                    self.lblFirstComma.text = ","
//                    self.lblAge.text = String(format: "%d",age)
//                    self.lblSecondComma.text = ""
//                    self.lblAddress.text = ""
                }
                username = name
                ageStr = String(format:"%d",age)
                locationStr = ""
            }
        }
        if let gender = personalDetail["looking_for"] as? String {
            print(gender)
            if gender == "Woman" {
                genderPreferences = "Woman"
                self.btnWomen.setImage(#imageLiteral(resourceName: "femaleSelected"), for: .normal)
                self.btnMan.setImage(#imageLiteral(resourceName: "manUnSelected"), for: .normal)

            }else if gender == "Man" {
                genderPreferences = "Man"
                self.btnMan.setImage(#imageLiteral(resourceName: "manSelected"), for: .normal)
                self.btnWomen.setImage(#imageLiteral(resourceName: "femaleUnSelected"), for: .normal)
            }
            else {
                genderPreferences = ""
                self.btnWomen.setImage(#imageLiteral(resourceName: "femaleUnSelected"), for: .normal)
                self.btnMan.setImage(#imageLiteral(resourceName: "manUnSelected"), for: .normal)
            }
        }
        else {
            genderPreferences = ""
            self.btnWomen.setImage(#imageLiteral(resourceName: "manUnSelected"), for: .normal)
            self.btnMan.setImage(#imageLiteral(resourceName: "manUnSelected"), for: .normal)
        }
        
        if let radius = personalDetail["location_radius"] as? String{
            if radius != "" {
                self.milesSlider.value = Float(radius)!
                self.lblMiles.text = radius
                distancePreference = radius
            }
        }
        if let height = personalDetail["height"] as? String{
            if height != "" {
                heightValue = height
                
                let arrHeight = height.components(separatedBy: ".")
                
                let strHeight = String(format:"%f",Float(Float(arrHeight[1])!/11))
                
                self.heightSlider.value = Float(String(format:"%@.%@",arrHeight[0],strHeight.components(separatedBy: ".")[1]))!

                self.lblHeight.text = String(format:"%@' %@\"",arrHeight[0],arrHeight[1])

            }
            else {
                heightValue = "5.6"
            }
        }
        else {
            heightValue = "5.6"
        }
        
        if let ageRange = personalDetail["age_range"] as? String{
            let range = ageRange.components(separatedBy: ",")
            if range.count == 2 {
                if range[0] != "" && range[1] != "" {
                    var maxAge = range[1] as NSString
                    if maxAge.intValue > 70 {
                        maxAge = "70"
                    }
                    let minAge = range[0] as NSString
                    self.lblAgeStart.text = String(format:"%d",minAge.intValue)
                    self.lblAgeMax.text = String(format:"%d",maxAge.intValue)
                    let miniValue = Float(range[0])
                    let maxValue = maxAge.floatValue
                    self.rangeSlider.selectedMin = CGFloat(Float(miniValue!))
                    self.rangeSlider.selectedMax = CGFloat(Float(maxValue))
                    self.rangeSlider.layoutSubviews()
                    agePreferences.0 = "\(Float(miniValue!))"
                    agePreferences.1 = "\(Float(maxValue))"
                }
            }
        }
        if let activitiesString = personalDetail["activities"] as? String{
            activitiesArray = [String]()
            if activitiesString == "" && (self.navigationController?.viewControllers[0].isKind(of: EditProfileViewController.self))! {
                let activityController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                activityController.isPresent = true
                activityController.selectedActivites = activitiesArray
                self.present(activityController, animated: true, completion: nil)
            }
            let activities = activitiesString.components(separatedBy: ",")
            activitiesArray = activities
        }
        if let work = personalDetail["work"] as? String{
            self.txtFldOccupation.text =  work
        }
        if let profile_video = personalDetail["profile_video"] as? String {
            if profile_video == ""{
                self.lblAddVideo.text = "ADD VIDEO"
                self.btnCamera.isHidden = false
            }else {
                self.lblAddVideo.text = "CHANGE VIDEO"
                isVideo = true
                playView(nil)
            }
        }
        if let favSport = personalDetail["fav_sport_team_1"] as? String{
            self.txtFldTeam1.text =  favSport
        }
        if let favSport = personalDetail["fav_sport_team_2"] as? String{
            self.txtFldTeam2.text =  favSport
        }
        if let favSport = personalDetail["fav_sport_team_3"] as? String{
            self.txtFldTeam3.text =  favSport
        }
        if let favSport = personalDetail["fav_sport_team_4"] as? String{
            self.txtFldTeam4.text =  favSport
        }
        
        arrayKids = []
        if let kids = personalDetail["kids"] as? String{
            let kidArray = kids.components(separatedBy: ",")
            if kidArray.contains("want"){
                self.switchWantKids.setOn(true, animated: true)
                arrayKids.append("want")
            }
            else {
                self.switchWantKids.setOn(false, animated: true)
            }
            if kidArray.contains("have"){
                self.switchKids.setOn(true, animated: true)
                arrayKids.append("have")
            }
            else {
                self.switchKids.setOn(false, animated: true)
            }
        }
        lookingFor = []
        imgViewHaveFun.image = #imageLiteral(resourceName: "unCheck")
        imgViewMeetNewPeople.image = #imageLiteral(resourceName: "unCheck")
        imgViewRelationShip.image = #imageLiteral(resourceName: "unCheck")
        if let iAmHere = personalDetail["iam_here_to"] as? String {
            let iAmHereArray = iAmHere.components(separatedBy: ",")
            if iAmHereArray.contains("workout"){
                lookingFor.append("workout")
                workoutBool = true
                imgViewHaveFun.image = #imageLiteral(resourceName: "check")
            }
            if iAmHereArray.contains("short-Term"){
                lookingFor.append("short-Term")
                shortTermBool = true
                imgViewMeetNewPeople.image = #imageLiteral(resourceName: "check")
            }
            if iAmHereArray.contains("longTerm"){
                lookingFor.append("longTerm")
                longTermBool = true
                imgViewRelationShip.image = #imageLiteral(resourceName: "check")
            }
        }
        
        if let heightRange = personalDetail["height_range"] as? String{
            if heightRange != "" {
                let range = heightRange.components(separatedBy: ",")
                if range.count == 2 {
                    let arrMinHeight = range[0].components(separatedBy: ".")
                    let arrMaxHeight = range[1].components(separatedBy: ".")
                    
                    let strMin = String(format:"%f",Float(Float(arrMinHeight[1])!/11))
                    let strMax = String(format:"%f",Float(Float(arrMaxHeight[1])!/11))
                    
                    self.rangeSliderHeight.selectedMin = CGFloat(Float(String(format:"%@.%@",arrMinHeight[0],strMin.components(separatedBy: ".")[1]))!)
                    self.rangeSliderHeight.selectedMax = CGFloat(Float(String(format:"%@.%@",arrMaxHeight[0],strMax.components(separatedBy: ".")[1]))!)
                    
                    self.lblHeightMin.text = String(format:"%@' %@\"",arrMinHeight[0],arrMinHeight[1])
                    self.lblHeightMax.text = String(format:"%@' %@\"",arrMaxHeight[0],arrMaxHeight[1])
                    self.rangeSliderHeight.layoutSubviews()
                    
                    heightPreferences.0 = range[0]
                    heightPreferences.1 = range[1]
                }
            }
        }
        
        
        
        if let notification = personalDetail["notification"] as? String{
            if notification == "1" {
                isNotification = true
                self.switchNotifications.setOn(true, animated: true)
            }
            else {
                isNotification = false
                self.switchNotifications.setOn(false, animated: true)
            }
        }
        else {
            isNotification = false
            self.switchNotifications.setOn(false, animated: true)
        }
        
        if let sound = personalDetail["sound"] as? String{
            if sound == "1" {
                LocalStore.store.soundOnOff = true
                isSound = true
                self.switchSound.setOn(true, animated: true)
            }
            else {
                LocalStore.store.soundOnOff = false
                isSound = false
                self.switchSound.setOn(false, animated: true)
            }
        }
        else {
            LocalStore.store.soundOnOff = false
            isSound = false
            self.switchSound.setOn(false, animated: true)
        }
        
        if UserDefaults.standard.bool(forKey: "UpdateImages") {
            UserDefaults.standard.set(false, forKey: "UpdateImages")
            UserDefaults.standard.synchronize()
            for i in 0..<5 {
                let vwCamera = self.scrollVwCamera.viewWithTag(i + 11)
                let openCameraView:OpenCameraView = vwCamera?.subviews[0] as! OpenCameraView
                
                openCameraView.btnPlay.isHidden = true
                openCameraView.viewVideoRecordRed.backgroundColor = UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)
                
                let gesture = UITapGestureRecognizer(target: self, action: #selector(btnCameraPic(_:)))
                openCameraView.viewVideoRecordRed.addGestureRecognizer(gesture)
                let sameGesture = UITapGestureRecognizer(target: self, action: #selector(btnCameraPic(_:)))
                openCameraView.imgViewCamera.addGestureRecognizer(sameGesture)
                openCameraView.btnCamera.isHidden = true
                openCameraView.imgViewCamera.image = #imageLiteral(resourceName: "cameraPlus")
                
                if i == 0 {
                    openCameraView.imgViewProfile.image = profileImages[i] as? UIImage
                    if let profile_pic = personalDetail[String(format:"profile_pic")] as? String {
                        if profile_pic == "" {
                            openCameraView.imgViewCamera.isHidden = false
                            openCameraView.imgViewProfile.isHidden = true
                            openCameraView.lblRecordVideo.text = "ADD PHOTO"
                        }
                        else {
                            openCameraView.imgViewProfile.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, personalDetail[String(format:"profile_pic")] as! String)), placeholderImage: UIImage.init(named: "placeholder"))
                            openCameraView.imgViewCamera.isHidden = true
                            openCameraView.imgViewProfile.isHidden = false
                            openCameraView.lblRecordVideo.text = "CHANGE PHOTO"
                        }
                    }else{
                        openCameraView.imgViewCamera.isHidden = false
                        openCameraView.imgViewProfile.isHidden = true
                        openCameraView.lblRecordVideo.text = "ADD PHOTO"
                        
                    }
                }
                else {
                    if let detail =  personalDetail[String(format:"image%d",i)] as? String {
                        if detail == "" {
                            if profileImages[i] != nil {
                                openCameraView.imgViewProfile.image = profileImages[i] as? UIImage
                                openCameraView.imgViewCamera.isHidden = true
                                openCameraView.imgViewProfile.isHidden = false
                                openCameraView.lblRecordVideo.text = "CHANGE PHOTO"
                            }
                            else {
                                openCameraView.imgViewCamera.isHidden = false
                                openCameraView.imgViewProfile.isHidden = true
                                openCameraView.lblRecordVideo.text = "ADD PHOTO"
                            }
                        }else{
                            openCameraView.imgViewProfile.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, detail)), placeholderImage: UIImage.init(named: "placeholder"))
                            openCameraView.imgViewCamera.isHidden = true
                            openCameraView.imgViewProfile.isHidden = false
                            openCameraView.lblRecordVideo.text = "CHANGE PHOTO"
                        }
                    }
                    else {
                        openCameraView.imgViewCamera.isHidden = false
                        openCameraView.imgViewProfile.isHidden = true
                        openCameraView.lblRecordVideo.text = "ADD PHOTO"
                    }
                    
                }
                openCameraView.viewVideoProfile.isHidden = true
                openCameraView.imgViewRecord.shadow(0.6, 4, .black, CGSize(width: 3, height: 3))
                openCameraView.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        
        if player != nil {
            player.replaceCurrentItem(with: nil)
            player = nil
            NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imgViewRecord.layer.cornerRadius = imgViewRecord.frame.size.width/2
        btnSliderQuizz.layer.cornerRadius = btnSliderQuizz.frame.size.height/2
        btnReminder.layer.cornerRadius = btnReminder.frame.size.height/2
        btnWatchVideoTut.layer.cornerRadius = btnWatchVideoTut.frame.size.height/2
        btnChangeActivities.layer.cornerRadius = btnChangeActivities.frame.size.height/2
        btnUpdateSettings.layer.cornerRadius = btnUpdateSettings.frame.size.height/2
        btnLogout.layer.cornerRadius = btnLogout.frame.size.height/2
        btnDeleteAccount.layer.cornerRadius = btnDeleteAccount.frame.size.height/2
        
        btnGotIt.layer.cornerRadius = btnGotIt.frame.size.height/2
        
        let width = UIScreen.main.bounds.width - 110
        let height = (width * 253)/210
        openCameraView1.frame = CGRect(x: -0.5, y: -10, width: width, height: height)
        openCameraView1.widthOpenCamera.constant = width
        openCameraView1.heightOpenCamera.constant = height
        openCameraView2.frame = CGRect(x: -0.5, y: -10, width: width, height: height)
        openCameraView2.widthOpenCamera.constant = width
        openCameraView2.heightOpenCamera.constant = height
        openCameraView3.frame = CGRect(x: -0.5, y: -10, width: width, height: height)
        openCameraView3.widthOpenCamera.constant = width
        openCameraView3.heightOpenCamera.constant = height
        openCameraView4.frame = CGRect(x: -0.5, y: -10, width: width, height: height)
        openCameraView4.widthOpenCamera.constant = width
        openCameraView4.heightOpenCamera.constant = height
        openCameraView5.frame = CGRect(x: -0.5, y: -10, width: width, height: height)
        openCameraView5.widthOpenCamera.constant = width
        openCameraView5.heightOpenCamera.constant = height
        
    }
    
//MARK:-  UIKeyboard Methdos
    func upTheKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(hideShowKeyboard(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideShowKeyboard(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func hideShowKeyboard(_ notification: Notification){
        
        if let userDetails = notification.userInfo{
            let keyboardRect = (userDetails[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            var keyboardHeight:CGFloat = 0
            keyboardHeight = notification.name == UIResponder.keyboardWillShowNotification ? (keyboardRect?.size.height)! : 0
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                self.scrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            }, completion: { (completed) in
                
            })
        }
    }
    
//MARK:-  UITextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == self.txtFldAddress {
//            return
//        }
    }

    //MARK:-  UITextView Delegates
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 302
    }
    
//MARK:-  Local Methods
    
    func hideTheViews(){
        lblTapToEdit.alpha = 0
        lblYourPhoto.alpha = 0
        lblNameHide.alpha = 0
        lblAgeHide.alpha = 0
        lblLocationHide.alpha = 0
        lblScrollForMore.alpha = 0
        imgViewArrowOne.alpha = 0
        imgViewArrowTwo.alpha = 0
        imgViewArrowThree.alpha = 0
        btnGotIt.alpha = 0
        viewWhite.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
//        constraintViewWhiteTop.constant = -UIScreen.main.bounds.size.height + (self.viewTop.frame.size.height)
        constraintViewWhiteTop.constant = self.viewTop.frame.size.height
        self.constraintViewWhiteHeight.constant = UIScreen.main.bounds.height - (self.viewTop.frame.size.height)
        self.view.layoutIfNeeded()
    }
    
    func addTheGestures(){
        
        let videoRecordTapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureRecordVideo(_ :)))
        viewRecordVideo.addGestureRecognizer(videoRecordTapGesture)
        
        let moreSettingsGesture = UITapGestureRecognizer(target: self, action: #selector(gestureMoreSettings(_ :)))
        viewMoreSetting.addGestureRecognizer(moreSettingsGesture)
        
        let workOutBuddyGesture = UITapGestureRecognizer(target: self, action: #selector(workOutBuddy))
        viewWorkOutBuddy.addGestureRecognizer(workOutBuddyGesture)
        
        let shortTermDatingGesture = UITapGestureRecognizer(target: self, action: #selector(shortTermDating))
        viewShortTermDating.addGestureRecognizer(shortTermDatingGesture)
        
        let longTermDatingShipGesture = UITapGestureRecognizer(target: self, action: #selector(longTermDating))
        viewLongTermDating.addGestureRecognizer(longTermDatingShipGesture)
        
        
        let standardImgViewGesture = UITapGestureRecognizer(target: self, action: #selector(standardUnitSelected))
        imgViewStandard.addGestureRecognizer(standardImgViewGesture)
        
        let metricImgViewGesture = UITapGestureRecognizer(target: self, action: #selector(metricUnitSelected))
        imgViewMetric.addGestureRecognizer(metricImgViewGesture)
    }
    
    func settingNameAgeAddress(_ name:String, _ age: String, _ location: String){
        lblName.text = ""
        lblName.animate(newText: String(format:"%@, %@, %@",name,age,location), characterDelay: 0.1) { (completed:Bool) in
            self.whiteViewAnimation()
            LocalStore.store.appNotFirstTime = true
            //self.lblFirstComma.text = ","
//            self.lblAge.animate(newText: age, characterDelay: 0.1, completed: { (completed:Bool) in
//                if location == ""{
//                    self.lblSecondComma.text = ""
//                    self.whiteViewAnimation()
//                }else{
//                    self.lblSecondComma.text = ","
//                    self.lblAddress.animate(newText: location, characterDelay: 0.1, completed: { (completed: Bool) in
//                        self.whiteViewAnimation()
//                    })
//                }
//            })
        }
    }
    
    func whiteViewAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.constraintViewWhiteTop.constant = 0//self.viewTop.frame.size.height + 10
            self.constraintViewWhiteHeight.constant = self.view.bounds.size.height - self.viewTop.bounds.size.height
            UIView.animate(withDuration: 2, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed: Bool) in
                self.showTheWhiteViewElements()
            })
        })

    }
    
    func showTheWhiteViewElements(){
        self.lblTapToEdit.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.8, animations: {
            self.lblTapToEdit.transform = .identity
            self.lblTapToEdit.alpha = 1
        }) { (completed: Bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                self.lblScrollForMore.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    self.btnGotIt.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    UIView.animate(withDuration: 0.4, animations: {
                        self.btnGotIt.alpha = 1
                        self.btnGotIt.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    }, completion: { (completed: Bool) in
                        UIView.animate(withDuration: 0.2, animations: {
                            self.btnGotIt.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        }, completion: { (completed: Bool) in
                            UIView.animate(withDuration: 0.1, animations: {
                                self.btnGotIt.transform = .identity
                            }, completion: { (completed: Bool) in
                                DispatchQueue.main.async {
                                    self.btnGotIt.transform = .identity
                                    self.viewWhite.isUserInteractionEnabled = true
                                    self.scrollView.isUserInteractionEnabled = true
                                }
                            })
                        })
                    })
            })
            
           /* self.lblYourPhoto.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.8, animations: {
                self.lblYourPhoto.transform = .identity
                self.lblYourPhoto.alpha = 1
            }) { (completed: Bool) in
                self.lblNameHide.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                UIView.animate(withDuration: 0.8, animations: {
                    self.lblNameHide.transform = .identity
                    self.lblNameHide.alpha = 1
                }) { (completed: Bool) in
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                   
                    self.imgViewArrowOne.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    UIView.animate(withDuration: 0.8, animations: {
                        self.imgViewArrowOne.transform = .identity
                        self.imgViewArrowOne.alpha = 1
                    }) { (completed: Bool) in
                        UIView.animate(withDuration: 0.2, animations: { 
                            let degree: Double = 0
                            self.imgViewArrowOne.transform = CGAffineTransform(rotationAngle: (CGFloat(degree * .pi/180)))
                        })
                        self.lblAgeHide.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                        UIView.animate(withDuration: 0.8, animations: {
                            self.lblAgeHide.transform = .identity
                            self.lblAgeHide.alpha = 1
                        }) { (completed: Bool) in
                            
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                            self.imgViewArrowTwo.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                            UIView.animate(withDuration: 0.8, animations: {
                                self.imgViewArrowTwo.transform = .identity
                                self.imgViewArrowTwo.alpha = 1
                            }) { (completed: Bool) in
                                
                                self.lblLocationHide.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                                UIView.animate(withDuration: 0.8, animations: {
                                    self.lblLocationHide.transform = .identity
                                    self.lblLocationHide.alpha = 1
                                }) { (completed: Bool) in
                                    
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                    self.imgViewArrowThree.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                                    UIView.animate(withDuration: 0.8, animations: {
                                        self.imgViewArrowThree.transform = .identity
                                        self.imgViewArrowThree.alpha = 1
                                    }) { (completed: Bool) in
                                        
                                        UIView.animate(withDuration: 0.3, animations: {
                                            let degree: Double = 0
                                            self.imgViewArrowThree.transform = CGAffineTransform(rotationAngle: (CGFloat(degree * .pi/180)))
                                        })
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: { 
                                            self.lblScrollForMore.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                                            UIView.animate(withDuration: 1, animations: {
                                                self.lblScrollForMore.transform = .identity
                                                self.lblScrollForMore.alpha = 1
                                            }) { (completed: Bool) in
                                                self.btnGotIt.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                                                UIView.animate(withDuration: 0.4, animations: {
                                                    self.btnGotIt.alpha = 1
                                                    self.btnGotIt.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                                                    
                                                }, completion: { (completed: Bool) in
                                                    UIView.animate(withDuration: 0.2, animations: { 
                                                        self.btnGotIt.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                                                        self.viewWhite.isUserInteractionEnabled = true
                                                    }, completion: { (completed: Bool) in
                                                        UIView.animate(withDuration: 0.1, animations: { 
                                                            self.btnGotIt.transform = .identity
                                                        }, completion: { (completed: Bool) in
                                                            self.scrollView.isUserInteractionEnabled = true
                                                        })
                                                    })
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }*/
            
            
        }
    }
    
    func saveUserPreferences(){
        
        let facebookId = LocalStore.store.getFacebookID()
        let ageRange = "\(agePreferences.0),\(agePreferences.1)"
        let heightRange = "\(heightPreferences.0),\(heightPreferences.1)"
        var parameters = Dictionary<String,Any>()
        parameters["user_fb_id"] = facebookId
        parameters["user_name"] = username//self.lblName.text
        parameters["about_me"] = self.txtViewDesc.text
        parameters["looking_for"] = genderPreferences
        parameters["age_range"] = ageRange
        parameters["height_range"] = heightRange
        parameters["height"] = heightValue
        parameters["location_radius"] = distancePreference
        parameters["location"] = locationStr//self.lblAddress.text
        parameters["kids"] = arrayKids.joined(separator: ",")
        parameters["iam_here_to"] = lookingFor.joined(separator: ",")
        parameters["fav_sport_team_1"] = self.txtFldTeam1.text
        parameters["fav_sport_team_2"] = self.txtFldTeam2.text
        parameters["fav_sport_team_3"] = self.txtFldTeam3.text
        parameters["fav_sport_team_4"] = self.txtFldTeam4.text
        parameters["work"] = self.txtFldOccupation.text
        if isNotification {
            parameters["notification"] =  "1"
        }
        else {
            parameters["notification"] = "0"
        }
        if isSound {
            parameters["sound"] =  "1"
        }
        else {
            parameters["sound"] = "0"
        }
        
        print(parameters)
        
        Loader.startLoader(true)
        WebServices.service.webServicePostRequest(.post, .user, .updateProfile, parameters, successHandler: { (response) in
            Loader.stopLoader()
            let jsonData = response
            let status = jsonData!["status"] as! String
            if status == "success"{
                DispatchQueue.main.async {
                    self.getUserDetails(false)
                }
                if !self.isBackClicked {
                    CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
                }
            }else{
                self.showAlertWithOneButton("Error", "Please check your internet connection.", "OK");
            }
        }, errorHandler: { (error) in
            Loader.stopLoader()
            self.showAlertWithOneButton("Error", "Please check your internet connection.", "OK");
        })
    }
        
    func showSettingAlert(){
        let settingAction = action("Settings", .default) { (action) in
            let path = Bundle.main.bundleIdentifier
            let urlString = "\(UIApplication.openSettingsURLString)+\(path!)"
            UIApplication.shared.open(URL(string: urlString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        let cancelAction = action("Cancel", .cancel) { (action) in
            
        }
        showAlertWithCustomButtons("Slindir does not have access to your photos or videos, tap Settings and turn on Photos.", nil, settingAction,cancelAction)
    }
    
    @objc func playVideo(){
        if self.profileImages[0] is AVPlayer{
            let player = self.profileImages[0] as! AVPlayer
            videoCompleted = false
            player.seek(to: CMTime.zero)
        }
    }

    func playView(_ url: URL!) {
        DispatchQueue.main.async {
            if url != nil {
                self.thumbnailFromVideoServerURL(url:url)
            }
            else {
                self.thumbnailFromVideoServerURL(url:URL(string:String(format:"%@%@", mediaUrl, self.personalDetail[String(format:"profile_video")] as! String))!)
                self.btnCamera.isHidden = false
                self.btnCamera.setImage(UIImage.init(named: "playIntroVideo"), for: .normal)
            }
            
        }
    }
    
    func postImageWithImage(image:UIImage, fileName:String, type:String) {
        let facebookID = LocalStore.store.getFacebookID()
        Loader.startLoader(true)
        var parameters = Dictionary<String, Any?>()
        parameters["user_fb_id"] = facebookID
        parameters["file_type"] = fileName
        let postData = image.jpegData(compressionQuality: 0.4)
      
        WebServices.service.webServicePostFileRequest(.post, .user, .uploadFile, type, postData!, parameters as Dictionary<String, Any>, successHandler: { (response) in
            print(response as Any)
            self.getUserDetails(false)
            Loader.stopLoader()
        }) { (error) in
            Loader.stopLoader()
            print(error?.localizedDescription as Any)
        }
    }
    
    func postVideoWithData(data:Data, imageData:Data) {
        let facebookID = LocalStore.store.getFacebookID()
        Loader.startLoader(true)
        var parameters = Dictionary<String, Any?>()
        parameters["user_fb_id"] = facebookID
        WebServices.service.webServicePostVideoFileAndThumbnailRequest(.post, .user, .uploadVideoAndThumbnail, data, imageData, parameters as Dictionary<String, Any>, successHandler: { (response) in
            self.getUserDetails(false)
            Loader.stopLoader()
        }) { (error) in
            Loader.stopLoader()
        }
        
//        WebServices.service.webServicePostFileRequest(.post, .user, .uploadFile, type, data, parameters, successHandler: { (response) in
//            self.getUserDetails(false)
//            Loader.stopLoader()
//
//        }) { (error) in
//            Loader.stopLoader()
//        }
    }
    
//MARK:-  UIGesture delegates
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
//MARK:-  Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK:-  Gestures
    
    @objc func swipeLeft(){
        CustomClass.sharedInstance.playAudio(.swipeLeft, .mp3)
    }
    
    @objc func swipeRight(){
        CustomClass.sharedInstance.playAudio(.swipeRight, .mp3)
    }
    
    
    @objc func gestureRecordVideo(_ gesture: UITapGestureRecognizer?){
        self.getGalleryImages()
        
        self.vwVideo.layer.borderColor = UIColor.clear.cgColor
        self.vwVideo.layer.borderWidth = 1
        
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
       
        let indexPath = IndexPath(row: 11, section: 0)
        selectedIndexPath = indexPath
        
        let actionSheet = UIAlertController(title: "Upload from current library", message: nil, preferredStyle: .actionSheet)
        let recordAction = UIAlertAction(title: "Take video", style: .default) { (action) in
//            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
//            let recordIntroController = self.storyboard?.instantiateViewController(withIdentifier: "RecordVideoController") as! RecordVideoController
//            recordIntroController.speechDelegate = self
//            self.present(recordIntroController, animated: true, completion: nil)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let controller = UIImagePickerController()
                controller.sourceType = .camera
                controller.allowsEditing = true
                controller.cameraDevice = .front
                controller.delegate = self
                controller.mediaTypes = [kUTTypeMovie as String]
                controller.videoMaximumDuration = 10.0
                self.present(controller, animated: true, completion: nil)
            }
            
        }
        let galleryAction = UIAlertAction(title: "Choose Video", style: .default) { (action) in
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            switch PHPhotoLibrary.authorizationStatus(){
            case .authorized:
                print("You can Access Photos.")
                
                let galleryController = self.storyboard?.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController!
                galleryController?.fetchResult = self.allPhotos
                galleryController?.galleryDelegate = self
                galleryController?.selectedIndex = 10
                self.present(galleryController!, animated: true, completion: nil)
            case .denied:
                self.showSettingAlert()
            case .notDetermined:
                print("Premission Alert Not Open.")
                self.getGalleryImages()
            case .restricted:
                print("Premissions Are resticted.")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)

        }
        
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(recordAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc func gestureMoreSettings(_ gesture: UITapGestureRecognizer){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        if isMoreSetting {
            isMoreSetting = false
            lblMoreSettings.text = "Less Settings"
        }
        else{
            lblMoreSettings.text = "More Settings"
            isMoreSetting = true
        }
    }
    
    @objc func workOutBuddy(){
        if workoutBool{
            CustomClass.sharedInstance.playAudio(.popRed, .mp3)
            imgViewHaveFun.image = #imageLiteral(resourceName: "unCheck")
            workoutBool = false
            if let index = lookingFor.index(of: "workout") {
                lookingFor.remove(at: index)
            }
        }else{
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            imgViewHaveFun.image = #imageLiteral(resourceName: "check")
            workoutBool = true
            lookingFor.append("workout")
        }
        self.imgViewHaveFun.layer.borderColor = UIColor.clear.cgColor
        self.imgViewHaveFun.layer.borderWidth = 1
        self.imgViewMeetNewPeople.layer.borderColor = UIColor.clear.cgColor
        self.imgViewMeetNewPeople.layer.borderWidth = 1
        self.imgViewRelationShip.layer.borderColor = UIColor.clear.cgColor
        self.imgViewRelationShip.layer.borderWidth = 1
    }
    
    @objc func shortTermDating(){
        if shortTermBool{
            CustomClass.sharedInstance.playAudio(.popRed, .mp3)
            imgViewMeetNewPeople.image = #imageLiteral(resourceName: "unCheck")
            shortTermBool = false
            if let index = lookingFor.index(of: "short-Term") {
                lookingFor.remove(at: index)
            }
        }else{
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            imgViewMeetNewPeople.image = #imageLiteral(resourceName: "check")
            shortTermBool = true
            lookingFor.append("short-Term")
        }
        self.imgViewHaveFun.layer.borderColor = UIColor.clear.cgColor
        self.imgViewHaveFun.layer.borderWidth = 1
        self.imgViewMeetNewPeople.layer.borderColor = UIColor.clear.cgColor
        self.imgViewMeetNewPeople.layer.borderWidth = 1
        self.imgViewRelationShip.layer.borderColor = UIColor.clear.cgColor
        self.imgViewRelationShip.layer.borderWidth = 1
    }
    
    @objc func longTermDating(){
        if longTermBool{
            CustomClass.sharedInstance.playAudio(.popRed, .mp3)
            imgViewRelationShip.image = #imageLiteral(resourceName: "unCheck")
            longTermBool = false
            if let index = lookingFor.index(of: "longTerm") {
                lookingFor.remove(at: index)
            }
        }else{
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            imgViewRelationShip.image = #imageLiteral(resourceName: "check")
            longTermBool = true
            lookingFor.append("longTerm")
        }
        self.imgViewHaveFun.layer.borderColor = UIColor.clear.cgColor
        self.imgViewHaveFun.layer.borderWidth = 1
        self.imgViewMeetNewPeople.layer.borderColor = UIColor.clear.cgColor
        self.imgViewMeetNewPeople.layer.borderWidth = 1
        self.imgViewRelationShip.layer.borderColor = UIColor.clear.cgColor
        self.imgViewRelationShip.layer.borderWidth = 1
    }
    
    @objc func standardUnitSelected(){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        selectedUnit = "Standard"
        imgViewStandard.image = #imageLiteral(resourceName: "standardSelected")
        imgViewMetric.image = #imageLiteral(resourceName: "matric")
    }
    
    @objc func metricUnitSelected(){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        selectedUnit = "Matric"
        imgViewStandard.image = #imageLiteral(resourceName: "standard")
        imgViewMetric.image = #imageLiteral(resourceName: "matricSelected")
    }
    
    
//MARK:-   IBAction Methods
    @IBAction func btnBack(_ sender: Any?){
//        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
    
      //  if let url = UserDefaults.standard.url(forKey: "videoURL") {
            if genderPreferences == "" {
                self.showAlertWithOneButton("", "Please select your gender preference above.", "Ok")
                self.btnMan.layer.borderColor = UIColor.red.cgColor
                self.btnMan.layer.borderWidth = 1
                self.btnWomen.layer.borderColor = UIColor.red.cgColor
                self.btnWomen.layer.borderWidth = 1
                self.scrollView.contentOffset = CGPoint(x: 0, y: 200)
                return
            }
            if lookingFor.count == 0 {
                self.showAlertWithOneButton("", "Please select what you are looking for.", "Ok")
                self.imgViewHaveFun.layer.borderColor = UIColor.red.cgColor
                self.imgViewHaveFun.layer.borderWidth = 1
                self.imgViewMeetNewPeople.layer.borderColor = UIColor.red.cgColor
                self.imgViewMeetNewPeople.layer.borderWidth = 1
                self.imgViewRelationShip.layer.borderColor = UIColor.red.cgColor
                self.imgViewRelationShip.layer.borderWidth = 1
                self.scrollView.contentOffset = CGPoint(x: 0, y: 1000)
                return
            }
        
        if !LocalStore.store.isHeightSet() {
            let alertController = UIAlertController(title: NSLocalizedString("Confirmation", comment:""), message: "Please make sure this is your correct height, as you will not be able to edit it later.", preferredStyle: .alert)
            alertController.addAction(action(NSLocalizedString("Ok", comment: ""), .default, actionHandler: { (alertAction) in
                LocalStore.store.heightDone = true
                self.isBackClicked = true
                self.saveUserPreferences()
                
                UserDefaults.standard.set(true, forKey: "updateSettings")
                UserDefaults.standard.synchronize()
                
                CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
                let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                profileController.profileDelegate = self
                profileController.isAlreadyLogin = true
                self.navigationController?.pushViewController(profileController, animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
            isBackClicked = true
            self.saveUserPreferences()
 
        UserDefaults.standard.set(true, forKey: "updateSettings")
        UserDefaults.standard.synchronize()
        
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileController.profileDelegate = self
            profileController.isAlreadyLogin = true
            navigationController?.pushViewController(profileController, animated: true)
       // }
//        else {
//            self.scrollView.contentOffset = CGPoint(x: 0, y: 2000)
//            self.vwVideo.layer.borderColor = UIColor.red.cgColor
//            self.vwVideo.layer.borderWidth = 1
//            self.showAlertWithOneButton("", "Please upload an activity video of you doing something fun.", "Ok")
//        }
        
    }
    
    func checkPhotos() -> Int {
        var count:Int = 0
        for i in 0..<5 {
            if i == 0 {
                if (personalDetail[String(format:"profile_pic")] as? String) != "" {
                    count = count + 1
                }
            }
            else {
                if let detail =  personalDetail[String(format:"image%d",i)] as? String {
                    if detail != "" {
                        count = count + 1
                    }
                }
            }
        }
        return count
    }
    
    @IBAction func btnRecordVideo(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        
       if let url = UserDefaults.standard.url(forKey: "videoURL") {
        let player =  AVPlayer(url:URL.init(fileURLWithPath: url.path))
        if FileManager.default.fileExists(atPath: url.path) {
            print("file exists")
        }
            let playerViewController = AVPlayerViewController()
        
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
        else if let detail = personalDetail["profile_video"] as? String {
            if detail == "" {
                gestureRecordVideo(nil)
            }else {
                //Play Video
                let videoURL = URL(string:String(format:"%@%@", mediaUrl, detail))!
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
        else {
            gestureRecordVideo(nil)
        }
    }
    
    @IBAction func btnCameraPic(_ sender: Any?){
        self.getGalleryImages()
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let isGesture = sender is UITapGestureRecognizer
         
        if isGesture {
            let gesture = sender as? UITapGestureRecognizer
            let vw = gesture?.view
            let vwCamera = vw?.superview?.superview
            let indexPath = IndexPath.init(row: (vwCamera?.tag)!, section: 0)
            selectedIndexPath  = indexPath
        }
    
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        
        let actionSheet = UIAlertController(title: "Choose profile photo or video or take it.", message: nil, preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            
            switch PHPhotoLibrary.authorizationStatus(){
            case .authorized:
                print("You can Access Photos.")
                
                let galleryController = self.storyboard?.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController!
                galleryController?.fetchResult = self.allPhotos
                galleryController?.galleryDelegate = self
                galleryController?.selectedIndex = self.selectedIndexPath!.item - 11
                self.present(galleryController!, animated: true, completion: nil)
            case .denied:
                self.showSettingAlert()
            case .notDetermined:
                print("Premission Alert Not Open.")
                self.getGalleryImages()
            case .restricted:
                print("Premissions Are resticted.")
            }
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.selectImageOrVideo()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(galleryAction)
//        if selectedIndexPath?.item != 0{
            actionSheet.addAction(cameraAction)
       // }
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func selectImageOrVideo(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let controller = UIImagePickerController()
            controller.sourceType = .camera
            controller.allowsEditing = true
            controller.delegate = self
            controller.cameraDevice = .front
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func switchKids(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        if switchKids.isOn {
            arrayKids.append("have")
        }else{
            if let index = arrayKids.index(of: "have") {
                arrayKids.remove(at: index)
            }
        }
    }
    
    @IBAction func switchWantKids(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        if switchWantKids.isOn {
            arrayKids.append("want")
        }else{
            if let index = arrayKids.index(of: "want") {
                arrayKids.remove(at: index)
            }
        }
    }
    
    @IBAction func btnMan(_ sender: Any?){
        self.btnMan.layer.borderColor = UIColor.clear.cgColor
        self.btnWomen.layer.borderColor = UIColor.clear.cgColor
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        genderPreferences = "Man"
        UIView.transition(with: btnMan, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.btnMan.setImage(#imageLiteral(resourceName: "manSelected"), for: .normal)
            self.btnWomen.setImage(#imageLiteral(resourceName: "femaleUnSelected"), for: .normal)
        }) { (completed:Bool) in
            
        }
        
    }
    
    @IBAction func btnWomen(_ sender: Any?){
        self.btnMan.layer.borderColor = UIColor.clear.cgColor
        self.btnWomen.layer.borderColor = UIColor.clear.cgColor
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        genderPreferences = "Woman"
        UIView.transition(with: btnWomen, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.btnWomen.setImage(#imageLiteral(resourceName: "femaleSelected"), for: .normal)
            self.btnMan.setImage(#imageLiteral(resourceName: "manUnSelected"), for: .normal)
        }) { (completed:Bool) in
            
        }
    }
    
    @IBAction func sliderAgeRange(_ sender: RangeSlider){
        if sender == rangeSlider {
            self.lblAgeStart.text = "\(Int(sender.selectedMin))"
            self.lblAgeMax.text = "\(Int(sender.selectedMax))"
            agePreferences.0 = "\(Float(sender.selectedMin))"
            agePreferences.1 = "\(Float(sender.selectedMax))"
        }else{
            var minWholeNumberPart: Double = 0.0
            let minFractionalPart = modf(Double(Float(sender.selectedMin)), &minWholeNumberPart)
           
            var maxWholeNumberPart: Double = 0.0
            let maxFractionalPart = modf(Double(Float(sender.selectedMax)), &maxWholeNumberPart)
            
            self.lblHeightMin.text = String(format:"%.0f' %.0f\"",minWholeNumberPart,minFractionalPart*11)
            self.lblHeightMax.text = String(format:"%.0f' %.0f\"",maxWholeNumberPart,maxFractionalPart*11)
            
            heightPreferences.0 = String(format:"%.0f.%.0f",minWholeNumberPart,minFractionalPart*11)
            heightPreferences.1 = String(format:"%.0f.%.0f",maxWholeNumberPart,maxFractionalPart*11)
        }
    }
    
    @IBAction func btnGotIt(_ sender: Any?) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
//        self.txtFldName.isUserInteractionEnabled = true
//        self.txtFldAge.isUserInteractionEnabled = true
//        self.txtFldAddress.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        constraintViewWhiteTop.constant = -UIScreen.main.bounds.size.height + (self.viewTop.frame.size.height)
        self.imgViewArrowOne.alpha = 0
        self.imgViewArrowTwo.alpha = 0
        self.imgViewArrowThree.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            
            self.lblScrollForMore.alpha = 0
            self.view.layoutIfNeeded()
            self.viewWhite.alpha = 0
        }) { (completed: Bool) in
            self.viewWhite.isHidden = true
        }
    }
    
    @IBAction func btnSliderQuizz(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        if !LocalStore.store.isQuizDone(){
            //if let url = UserDefaults.standard.url(forKey: "videoURL") {
                if genderPreferences == "" {
                    self.showAlertWithOneButton("", "Please select your gender preference above.", "Ok")
                    self.btnMan.layer.borderColor = UIColor.red.cgColor
                    self.btnMan.layer.borderWidth = 1
                    self.btnWomen.layer.borderColor = UIColor.red.cgColor
                    self.btnWomen.layer.borderWidth = 1
                    self.scrollView.contentOffset = CGPoint(x: 0, y: 200)
                    return
                }
                if lookingFor.count == 0 {
                    self.showAlertWithOneButton("", "Please select what you are looking for.", "Ok")
                    self.imgViewHaveFun.layer.borderColor = UIColor.red.cgColor
                    self.imgViewHaveFun.layer.borderWidth = 1
                    self.imgViewMeetNewPeople.layer.borderColor = UIColor.red.cgColor
                    self.imgViewMeetNewPeople.layer.borderWidth = 1
                    self.imgViewRelationShip.layer.borderColor = UIColor.red.cgColor
                    self.imgViewRelationShip.layer.borderWidth = 1
                    self.scrollView.contentOffset = CGPoint(x: 0, y: 1000)

                    return
                }
            
            if !LocalStore.store.isHeightSet() {
                let alertController = UIAlertController(title: NSLocalizedString("Confirmation", comment:""), message: "Please make sure this is your correct height, as you will not be able to edit it later.", preferredStyle: .alert)
                alertController.addAction(action(NSLocalizedString("Ok", comment: ""), .default, actionHandler: { (alertAction) in
                    LocalStore.store.heightDone = true
//                    self.isBackClicked = false
//                    self.saveUserPreferences()
//                    UserDefaults.standard.set(true, forKey: "updateSettings")
//                    UserDefaults.standard.synchronize()
//                    let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//                    profileController.profileDelegate = self
//
//                    //profileController.isSlindirQuiz = true
//                    self.navigationController?.pushViewController(profileController, animated: true)
                }))
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
                isBackClicked = false
                self.saveUserPreferences()
            UserDefaults.standard.set(true, forKey: "updateSettings")
            UserDefaults.standard.synchronize()
                let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                        profileController.profileDelegate = self
                
                //profileController.isSlindirQuiz = true
                self.navigationController?.pushViewController(profileController, animated: true)
//            }
//            else {
//                self.scrollView.contentOffset = CGPoint(x: 0, y: 2000)
//                self.vwVideo.layer.borderColor = UIColor.red.cgColor
//                self.vwVideo.layer.borderWidth = 1
//                self.showAlertWithOneButton("", "Please upload an activity video of you doing something fun.", "Ok")
//            }
        }else{
            if genderPreferences == "" {
                self.showAlertWithOneButton("", "Please select your gender preference above.", "Ok")
                self.btnMan.layer.borderColor = UIColor.red.cgColor
                self.btnMan.layer.borderWidth = 1
                self.btnWomen.layer.borderColor = UIColor.red.cgColor
                self.btnWomen.layer.borderWidth = 1
                self.scrollView.contentOffset = CGPoint(x: 0, y: 200)
                return
            }
            if lookingFor.count == 0 {
                self.showAlertWithOneButton("", "Please select what you are looking for.", "Ok")
                self.imgViewHaveFun.layer.borderColor = UIColor.red.cgColor
                self.imgViewHaveFun.layer.borderWidth = 1
                self.imgViewMeetNewPeople.layer.borderColor = UIColor.red.cgColor
                self.imgViewMeetNewPeople.layer.borderWidth = 1
                self.imgViewRelationShip.layer.borderColor = UIColor.red.cgColor
                self.imgViewRelationShip.layer.borderWidth = 1
                self.scrollView.contentOffset = CGPoint(x: 0, y: 1000)
                
                return
            }
            
            if !LocalStore.store.isHeightSet() {
                let alertController = UIAlertController(title: NSLocalizedString("Confirmation", comment:""), message: "Please make sure this is your correct height, as you will not be able to edit it later.", preferredStyle: .alert)
                alertController.addAction(action(NSLocalizedString("Ok", comment: ""), .default, actionHandler: { (alertAction) in
                    LocalStore.store.heightDone = true
                    self.saveUserPreferences()
                    UserDefaults.standard.set(true, forKey: "updateSettings")
                    UserDefaults.standard.synchronize()
                    let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    profileController.profileDelegate = self
                    profileController.showBrainGame = true
                    self.navigationController?.pushViewController(profileController, animated: true)
                }))
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            self.saveUserPreferences()
            UserDefaults.standard.set(true, forKey: "updateSettings")
            UserDefaults.standard.synchronize()
            let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileController.profileDelegate = self
            profileController.showBrainGame = true
            self.navigationController?.pushViewController(profileController, animated: true)
            //self.quizDone()
        }
    }
    
    @IBAction func btnReminderLater(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileController.profileDelegate = self
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    @objc func onSliderValueChanged(_ slider: UISlider, event: UIEvent){
        if let touchEvent = event.allTouches?.first{
            switch touchEvent.phase {
            case .began: break
                
            case .moved:
                if slider == self.heightSlider {
                    var minWholeNumberPart: Double = 0.0
                    let minFractionalPart = modf(Double(Float(slider.value)), &minWholeNumberPart)
                    self.lblHeight.text = String(format:"%.0f' %.0f\"",minWholeNumberPart,minFractionalPart*11)
                    heightValue = String(format:"%.0f.%.0f",minWholeNumberPart,minFractionalPart*11)
                    print(heightValue)
                }
                else {
                    self.lblMiles.text = "\(Int(slider.value))"
                    distancePreference = "\(Int(slider.value))"
                }
            case .ended:
                self.moreSettingAnimation()
            default: break
                
            }
        }
    }

    func quizDone(){
        let userId = LocalStore.store.getFacebookID()
        
//        if txtFldName.text?.characters.count == 0 || txtFldName.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
//            showAlertWithOneButton( "Alert!", "Please enter name", "OK")
//            return
//        }
//        else if txtFldAge.text?.characters.count == 0 || txtFldAge.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
//            showAlertWithOneButton( "Alert!", "Please enter Age", "OK")
//            return
//        }
        
        var parameters = Dictionary<String, Any>()
        parameters["userId"] = userId
        parameters["userName"] = lblName.text!
        parameters["dateOfBirth"] = lblAge.text!
        isBackClicked = false
        saveUserPreferences()
    }
    
    
    func moreSettingAnimation(){
        
        if isFirstTime {
            isFirstTime = false
            UIView.animate(withDuration: 0.4, animations: {
                self.viewMoreSetting.alpha = 1
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.timer.invalidate()
            })
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.rotateSettings), userInfo: nil, repeats: true)
        }
        print("Star Animation here")
    }
    
    @objc func rotateSettings(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.imgViewSetting.transform = self.imgViewSetting.transform.rotated(by: CGFloat(Double.pi))
        }) { (completed: Bool) in
        }
    }
    
    @IBAction func btnChangeActivities(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        personalDetail = LocalStore.store.getUserDetails()
        if let activitiesString = personalDetail["activities"] as? String{
            let activities = activitiesString.components(separatedBy: ",")
            activitiesArray = [String]()
            activitiesArray = activities
        }
        
        
        let activityController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        activityController.isPresent = true
        activityController.selectedActivites = activitiesArray
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func switchPushNotification(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        if switchNotifications.isOn{
            isNotification = true
        }else{
            isNotification = false
        }
    }
    
    @IBAction func switchSoundVibration(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)

        if switchSound.isOn{
            isSound = true
            LocalStore.store.soundOnOff = true
        }else{
            isSound = false
            LocalStore.store.soundOnOff = false
        }
    }
    
    @IBAction func updateSettingsButton(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        //  if let url = UserDefaults.standard.url(forKey: "videoURL") {
        if genderPreferences == "" {
            self.showAlertWithOneButton("", "Please select your gender preference above.", "Ok")
            self.btnMan.layer.borderColor = UIColor.red.cgColor
            self.btnMan.layer.borderWidth = 1
            self.btnWomen.layer.borderColor = UIColor.red.cgColor
            self.btnWomen.layer.borderWidth = 1
            self.scrollView.contentOffset = CGPoint(x: 0, y: 200)
            return
        }
        if lookingFor.count == 0 {
            self.showAlertWithOneButton("", "Please select what you are looking for.", "Ok")
            self.imgViewHaveFun.layer.borderColor = UIColor.red.cgColor
            self.imgViewHaveFun.layer.borderWidth = 1
            self.imgViewMeetNewPeople.layer.borderColor = UIColor.red.cgColor
            self.imgViewMeetNewPeople.layer.borderWidth = 1
            self.imgViewRelationShip.layer.borderColor = UIColor.red.cgColor
            self.imgViewRelationShip.layer.borderWidth = 1
            self.scrollView.contentOffset = CGPoint(x: 0, y: 1000)
            return
        }
        
        if !LocalStore.store.isHeightSet() {
            let alertController = UIAlertController(title: NSLocalizedString("Confirmation", comment:""), message: "Please make sure this is your correct height, as you will not be able to edit it later.", preferredStyle: .alert)
            alertController.addAction(action(NSLocalizedString("Ok", comment: ""), .default, actionHandler: { (alertAction) in
                LocalStore.store.heightDone = true
                self.isBackClicked = true
                self.saveUserPreferences()
                UserDefaults.standard.set(true, forKey: "updateSettings")
                UserDefaults.standard.synchronize()
                CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
                let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                profileController.profileDelegate = self
                profileController.isAlreadyLogin = true
                self.navigationController?.pushViewController(profileController, animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        isBackClicked = true
        self.saveUserPreferences()
        UserDefaults.standard.set(true, forKey: "updateSettings")
        UserDefaults.standard.synchronize()
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileController.profileDelegate = self
        profileController.isAlreadyLogin = true
        navigationController?.pushViewController(profileController, animated: true)
        // }
        //        else {
        //            self.scrollView.contentOffset = CGPoint(x: 0, y: 2000)
        //            self.vwVideo.layer.borderColor = UIColor.red.cgColor
        //            self.vwVideo.layer.borderWidth = 1
        //            self.showAlertWithOneButton("", "Please upload an activity video of you doing something fun.", "Ok")
        //        }
        
    }
    @IBAction func btnLogout(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let alertController = UIAlertController(title: NSLocalizedString("Confirmation", comment:""), message: "Are you sure you want to logout?", preferredStyle: .alert)
        alertController.addAction(action(NSLocalizedString("Yes", comment: ""), .destructive, actionHandler: { (alertAction) in
            self.callLogoutWebService()
           // LoginManager().logOut()
            LocalStore.store.clearDataAllData()
            FirebaseObserver.observer.firstLoad = false
            self.deleteOldVideoFromDocumentDirectory()
            let loginController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.setViewControllers([loginController], animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnDeleteAccount(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let alertController = UIAlertController(title: NSLocalizedString("Confirmation", comment:""), message: "Are you sure you want to delete your account? It will delete your account permanently.", preferredStyle: .alert)
        alertController.addAction(action(NSLocalizedString("Yes", comment: ""), .destructive, actionHandler: { (alertAction) in
            FirebaseObserver.observer.deleteFirebaseAccount()
            self.callDeleteAccountWebService()
          //  LoginManager().logOut()
            FirebaseObserver.observer.firstLoad = false
            self.deleteOldVideoFromDocumentDirectory()
            LocalStore.store.clearDataAllData()
            let loginController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.setViewControllers([loginController], animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func feedbackClicked(_ sender: Any?){
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["contact@slindir.com"])
        mailComposerVC.setSubject("Slindir feedback iOS")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
            sendMailErrorAlert.show()
        }
        
    }
    
    func callLogoutWebService() {
        let facebookId = LocalStore.store.getFacebookID()
        var parameters = Dictionary<String,Any>()
        parameters["user_fb_id"] = facebookId
        WebServices.service.webServicePostRequest(.post, .user, .logout, parameters, successHandler: { (response) in
            Loader.stopLoader()
            
        }, errorHandler: { (error) in
            
        })
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
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK:-  Document Directory Video
    func writeVideoToDocumentDirectory(_ compressedData: NSData) {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent("video.mov")
        UserDefaults.standard.set(imageURL, forKey: "videoURL")
        UserDefaults.standard.synchronize()
        do {
            try compressedData.write(to: imageURL, options: .atomic)
        }
        catch {
            
        }
    }
    
//MARK:-  Record Controller Delegate
    func speechText(_ text: String , _ url : URL) {
        print("Recorded Text :- ",text)
        strSpeech = text
        self.txtViewDesc.text = strSpeech
        
        self.imgViewProfile.image = self.thumbnailForVideoAtURL(url: url)
        //self.btnCamera.isHidden = true
        //self.indicator.isHidden = false
        //self.indicator.startAnimating()
        
        videoURL = url.absoluteString
        
 /* fhc       do {
            let videoData = try Data(contentsOf:url)
          //  self.postVideoWithData(data: videoData, fileName: "profile_video", type: "video")
        } catch  {
            print("exception catch at block - while uploading video")
        } end fhc */
    }
    
//MARK:-  Profile Delegate
    func showMoreSettings() {
        moreSettingAnimation()
    }
    
//MARK:-  UIImagePickerController Delegates
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)]
        if let type = mediaType{
            if type is String{
                let stringType = type as! String
                if stringType == kUTTypeMovie as String{
                    let urlOfVideo =  info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL
                    if let url = urlOfVideo{
                        DispatchQueue.main.async {
                            self.playView(url)
                            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
                            self.compressVideo(inputURL: url as URL,asset: nil, outputURL: compressedURL) { (exportSession) in
                                guard let session = exportSession else {
                                    return
                                }
                                
                                switch session.status {
                                case .unknown:
                                    break
                                case .waiting:
                                    break
                                case .exporting:
                                    break
                                case .completed:
                                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                                        return
                                    }
                                    
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        // Bounce back to the main thread to update the UI
                                        DispatchQueue.main.async {
                                            self.deleteOldVideoFromDocumentDirectory()
                                            self.writeVideoToDocumentDirectory(compressedData)
                                            self.postVideoWithData(data: compressedData as Data, imageData: self.imgViewProfile.image!.jpegData(compressionQuality: 1.0)!)
                                        }
                                    }
                                    print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                                case .failed:
                                    break
                                case .cancelled:
                                    break
                                }
                            }

                        }
                    }
                }else{
                    self.imgViewProfile.isHidden = false
                    self.viewVideoProfile.isHidden = true
                    let vwCamera:UIView = self.scrollVwCamera.viewWithTag((selectedIndexPath?.row)!)!
                    let openViewCamera:OpenCameraView = vwCamera.subviews[0] as! OpenCameraView
                    openViewCamera.imgViewProfile.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
                    openViewCamera.lblRecordVideo.text = "CHANGE PHOTO"
                    if (self.selectedIndexPath?.item)! - 11 == 0 {
                         DispatchQueue.main.async {
                            self.postImageWithImage(image: info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage, fileName: "profile_pic", type: "image")
                            self.personalDetail["profile_pic"] = ""
                        }
                    }
                    else {
                         DispatchQueue.main.async {
                            self.postImageWithImage(image: info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage, fileName: String(format:"image%d",(self.selectedIndexPath?.item)!-11), type: "image")
                            self.personalDetail[String(format:"image%d",(self.selectedIndexPath?.item)! - 11)] = ""
                        }
                    }
                    
                    profileImages[(selectedIndexPath!.item) - 12] = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
//MARK:-  Gallery Methods(Get image permission and Gallery Controller Delegates)
    var galleryImages = [Any?]()
    var allPhotos: PHFetchResult<PHAsset>!
    
    func getGalleryImages(){
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        PHPhotoLibrary.shared().register(self)
    }
    
    func selectedAsset(_ asset: PHAsset!) {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        if #available(iOS 11.0, *) {
            switch asset.playbackStyle {
            case .unsupported:
                let alertController = UIAlertController(title: NSLocalizedString("Unsupported Format", comment:""), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)

            case .image :
                print("Array Profile :- ",self.profileImages)
                self.setImage(asset)
            case .livePhoto:
                print("Live Image")
                self.setImage(asset)
            case .imageAnimated:
                print("Image Animated")
                self.setImage(asset)
            case .video:
                if asset != nil {
                    selectedVideo(asset)
                }
                else {
                    let alertController = UIAlertController(title: NSLocalizedString("Asset Error", comment:""), message: "Selected asset is nil", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            case .videoLooping:
                print("Video Looping")
                if asset != nil {
                    selectedVideo(asset)
                }
                else {
                    let alertController = UIAlertController(title: NSLocalizedString("Asset Error", comment:""), message: "Selected asset is nil", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            switch asset.mediaType{
            case .audio:
                let alertController = UIAlertController(title: NSLocalizedString("Unsupported Format", comment:""), message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            
            case .video:
                if asset != nil {
                    selectedVideo(asset)
                }
                else {
                    let alertController = UIAlertController(title: NSLocalizedString("Asset Error", comment:""), message: "Selected asset is nil", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            case .unknown:
                print("UNKnown")
            case .image:
                self.setImage(asset)
            }
        }
    }
    
    func setImage(_ asset: PHAsset){
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, details, orientations, info) in
            guard let imageData = data else { return }
            let image = UIImage(data: imageData)
            if let selectedImage = image{
                self.profileImages[(self.selectedIndexPath!.item) - 11] = selectedImage
                
                DispatchQueue.main.async {
//                    let cell: SettingCollectionViewCell = self.collectionView.cellForItem(at: self.selectedIndexPath!) as! SettingCollectionViewCell
                    let vwCamera:UIView = self.scrollVwCamera.viewWithTag((self.selectedIndexPath?.row)!)!
                    let openViewCamera:OpenCameraView = vwCamera.subviews[0] as! OpenCameraView
                    openViewCamera.lblRecordVideo.text = "CHANGE PHOTO"
                    openViewCamera.imgViewProfile.image = selectedImage
                    openViewCamera.imgViewCamera.isHidden = true
                    openViewCamera.imgViewProfile.isHidden = false
                    if (self.selectedIndexPath?.item)! - 11 == 0 {
                        self.postImageWithImage(image: selectedImage, fileName: "profile_pic", type: "image")
                    }
                    else {
                        self.postImageWithImage(image: selectedImage, fileName: String(format:"image%d",(self.selectedIndexPath?.item)! - 11), type: "image")
                        
                        self.personalDetail[String(format:"image%d",(self.selectedIndexPath?.item)!-12)] = ""

                    }
                }
            }
        }
    }

    func selectedVideo(_ asset: PHAsset!) {
//        self.indicator.isHidden = false
//        self.indicator.startAnimating()
//        self.btnCamera.isHidden = true
        self.btnCamera.setImage(UIImage.init(named: "playIntroVideo"), for: .normal)

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .mediumQualityFormat
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { (asset, mix, nil) in
            if let myAsset = asset as? AVURLAsset {
                DispatchQueue.main.async {
                    self.imgViewProfile.image = self.thumbnailForVideoASSet(asset: myAsset)
                    self.videoURL = myAsset.url.absoluteString
                    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
                    self.compressVideo(inputURL: nil,asset: myAsset, outputURL: compressedURL) { (exportSession) in
                        guard let session = exportSession else {
                            return
                        }
                        
                        switch session.status {
                        case .unknown:
                            break
                        case .waiting:
                            break
                        case .exporting:
                            break
                        case .completed:
                            guard let compressedData = NSData(contentsOf: compressedURL) else {
                                return
                            }
                            DispatchQueue.global(qos: .userInitiated).async {
                                // Bounce back to the main thread to update the UI
                                DispatchQueue.main.async {
                                    self.deleteOldVideoFromDocumentDirectory()
                                    self.writeVideoToDocumentDirectory(compressedData)
                                    
                                    self.postVideoWithData(data: compressedData as Data, imageData: self.imgViewProfile.image!.jpegData(compressionQuality: 1.0)!)
                                }
                            }
                            print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                        case .failed:
                            break
                        case .cancelled:
                            break
                        }
                    }

                }
                //self.btnCamera.isHidden = true
            }
            else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: NSLocalizedString("Asset URL Error", comment:""), message: "Asset url is nil", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification){
        //let indexPath = IndexPath(item: 0, section: 0)
        videoCompleted = true
      //  collectionView.reloadItems(at: [indexPath])
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func thumbnailFromVideoServerURL(url:URL) {
        let asset = AVURLAsset(url: url, options: nil)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
        let maxSize = CGSize(width: 320, height: 180)
        generator.maximumSize = maxSize
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: thumbTime)], completionHandler: { (requestedTime, im, actualTime, result, error) in
            if result != .succeeded {
                print("couldn't generate thumbnail, error:\(error ?? "" as! Error)")
                DispatchQueue.main.async {
                    //self.thumbnailFromVideoServerURL(url: url)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.imgViewProfile.image = UIImage(cgImage: im!)
                    self.lblAddVideo.text = "CHANGE VIDEO"
                }
            }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollVwCamera.contentSize = CGSize(width:scrollVwCamera.contentSize.width, height:scrollVwCamera.frame.size.height);
        if scrollView == self.scrollVwCamera{
            self.swipeLeft()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.scrollView.contentOffset.y > 1500 && self.scrollView.contentOffset.y < 2000 {
            if !isVideoLabelBlinked {
                isVideoLabelBlinked = true
                UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                    self.lblVideoHeader.alpha = 0
                }, completion: { (completed) in
                    UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                        self.lblVideoHeader.alpha = 1
                    }, completion: { (completed) in
                        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                            self.lblVideoHeader.alpha = 0
                        }, completion: { (completed) in
                            UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                                self.lblVideoHeader.alpha = 1
                            }, completion: { (completed) in
                                
                            })
                        })
                    })
                })
            }
        }
    }
    func compressVideo(inputURL: URL?, asset: AVURLAsset?, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent("video.mov")
        UserDefaults.standard.set(imageURL, forKey: "videoURL")
        UserDefaults.standard.synchronize()
        
        var urlAsset:AVURLAsset!
        if inputURL != nil {
            urlAsset = AVURLAsset(url: inputURL!, options: nil)
        }
        else {
            urlAsset = asset
        }
        
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

extension EditProfileViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allPhotos){
                allPhotos = changeDetails.fetchResultAfterChanges
                print(allPhotos)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
