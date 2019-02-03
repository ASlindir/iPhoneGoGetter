//
//  ProfileDetaiViewController.swift
//  Slindir
//
//  Created by DeftDeskSol on 04/10/1939 Saka.
//  Copyright © 1939 Batth. All rights reserved.
//

import UIKit
import Koloda
import AVFoundation
import AVKit
import DACircularProgress

class ProfileDetaiViewController: UIViewController, CardsViewDelegates, UITableViewDataSource, UIScrollViewDelegate {
    func undoDemoCard() {
        
    }
    
    func profileDemoCard() {
        
    }
    
    func undoPreviousCard() {
        
    }
    
let personalDetail = LocalStore.store.getUserDetails()
    
    @IBOutlet var imgVwVideoThumb: UIImageView!
    @IBOutlet var btnPlayVideo: UIButton!
    
    @IBOutlet weak var constraintScrollViewTop: NSLayoutConstraint!
    @IBOutlet weak var constraintScrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet      var heightPersonalityView: NSLayoutConstraint!
    @IBOutlet weak var heightNavigation: NSLayoutConstraint!
    
    @IBOutlet weak var viewTopNavigation: UIView!

    @IBOutlet weak var viewBottom : BottomView!
    @IBOutlet weak var viewSliderKoloda: UIView!
    @IBOutlet weak var viewScrollContent: UIView!
    @IBOutlet weak var viewCards: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var viewEditPreferences: UIView!
    
    @IBOutlet weak var btnBlockAndReport: UIButton!
    @IBOutlet weak var btnShareUserScroll: UIButton!
    @IBOutlet weak var btnInviteAFriend: UIButton!
    
    @IBOutlet weak var lblNameScroll: UILabel!
    @IBOutlet weak var lblWorkScroll: UILabel!
    @IBOutlet weak var lblAddressScroll: UILabel!
    @IBOutlet weak var lblAboutScroll: UILabel!
    @IBOutlet weak var lblHeightScroll: UILabel!
    @IBOutlet weak var lblActivities: UILabel!
    
    @IBOutlet weak var imgViewHasKidsScroll: UIImageView!
    @IBOutlet weak var imgViewWantKidsScroll: UIImageView!
    @IBOutlet weak var imgViewLineUpper: UIImageView!
    @IBOutlet weak var imgViewLineLower: UIImageView!
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    @IBOutlet weak var scrollViewBottom: UIScrollView!
    
    @IBOutlet weak var stackViewScroll: UIStackView!
    
    @IBOutlet var lblLookingFor: UILabel!
    
    @IBOutlet var lblBrainGame: UILabel!
    @IBOutlet var vwBrain: UIView!
    @IBOutlet var btnOkBrainGame: UIButton!
    @IBOutlet var lbl1Brain: UILabel!
    @IBOutlet var lbl2Brain: UILabel!
    @IBOutlet var lbl3Brain: UILabel!
    @IBOutlet var lbl4Brain: UILabel!
    @IBOutlet var vwPersonality: UIView!
    @IBOutlet weak var vwCompatibilityScroll: DACircularProgressView!
    @IBOutlet weak var lblCompatibilityPercentageScroll: UILabel!
    @IBOutlet weak var btnLearnMore: UIButton!
    @IBOutlet weak var scrollVwFullImage: UIScrollView!
    @IBOutlet weak var vwScrollImage: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lineBelowPersonality: UIImageView!
    @IBOutlet weak var tableViewFavTeams: UITableView!
    @IBOutlet weak var btnBack: UIButton!

    @IBOutlet weak var heightRatioVideoVw: NSLayoutConstraint!
    @IBOutlet weak var heightVideoVw: NSLayoutConstraint!

    var selectedCardScrollVw = UIScrollView()
    var selectedCardVw = CardsView()

    var showBrainGame:Bool = false
    var videoUrl:String = ""
    var swipedUserDict = [String: Any]()
    var activities = [String]()
    var favoriteTeamArray:[String] = []
    var strBrainGame:String!
    
    var user_id:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if UIScreen.main.bounds.size.height >= 812 {
            self.heightNavigation.constant = 100
            self.view.layoutIfNeeded()
        }
        
        let image = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        btnBack.setImage(image, for: .normal)
        
        tableViewFavTeams.estimatedRowHeight = 44
        tableViewFavTeams.rowHeight = UITableView.automaticDimension
        self.constraintScrollViewTop.constant = UIScreen.main.bounds.height
        self.constraintScrollViewBottom.constant = -UIScreen.main.bounds.height
        scrollViewBottom.scrollIndicatorInsets = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
        viewTopNavigation.shadow(0.2, 0.5, .black, CGSize(width: 1, height: 1))
        viewBottom.shadow(0.9, 20, .black, CGSize(width: 1, height: 1))
        self.view.layoutIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.currentController = self
        self.getDetailOfUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnBlockAndReport.layer.cornerRadius = btnBlockAndReport.frame.size.height/2
        btnLearnMore.layer.cornerRadius = btnLearnMore.frame.size.height/2
        btnOkBrainGame.layer.cornerRadius = btnOkBrainGame.frame.size.height/2
        btnClose.layer.cornerRadius = btnClose.frame.size.height/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDetailOfUser() {
        var parameters = Dictionary<String, Any>()
        parameters["end_user_fb_id"] = self.user_id
        parameters["loggedin_fb_id"] = LocalStore.store.getFacebookID()
        WebServices.service.webServicePostRequest(.post, .user, .endUserDetail, parameters, successHandler: { (response) in
            let jsonData = response
            let status = jsonData!["status"] as! String
            if status == "success"{
                
                self.swipedUserDict = (jsonData!["user_details"] as? Dictionary<String, Any>)!
                DispatchQueue.main.async {
                    self.settingTheView()
                }
                
            }else{
                
            }
        }, errorHandler: { (error) in
        })
    }
    
    @IBAction func btnBack(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:-  UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteTeamArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TeamCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TeamCell
        cell.lblTeam.text = favoriteTeamArray[indexPath.row]
        return cell
    }
    
    @IBAction func btnOkBrain(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 1, animations: {
                self.vwBrain?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                self.vwBrain.alpha = 0
            }, completion: { (completed: Bool) in
                self.view.sendSubviewToBack(self.vwBrain)
            })
        }
    }
    
    @IBAction func learnMore(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        showBrainGameView()
    }

    @IBAction func btnSharePerson(_ sender: Any){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        // text to share
        let text = "Hey, I’m on this new dating app called Slindir (for active, like-minded singles)  and I came across this person who I thought would be a great match for you! Check it out.  It’s free to start so you’ve got nothing to lose!  Download the app at: \n http://slindir.com/"
        
        // set up activity view controller
       // let objectsToShare:URL = URL(string: "http://slindir.com/")!

        
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func playVideo(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        if videoUrl == "" {
        }else {
            let player = AVPlayer(url:URL(string:videoUrl)!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    @IBAction func blockAndReport(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Block", style: .destructive) { (action: UIAlertAction) in
            let alert = UIAlertController(title:String(format:"Are you sure you want to block %@?",self.swipedUserDict["user_name"] as! CVarArg), message: nil, preferredStyle: .alert)
            let no = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction) in
                
            }
            alert.addAction(no)
            let yes = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction) in
                let userId = LocalStore.store.getFacebookID()
                let blocked_user = self.swipedUserDict["user_fb_id"] as! String
                let parameters = ["user_fb_id": userId , "block_user_fb_id":blocked_user, "type":"block"]
                
                WebServices.service.webServicePostRequest(.post, .user, .blockUser, parameters, successHandler: { (response) in
                    let jsonDict = response
                    let status = jsonDict!["status"] as! String
                    if status == "success"{
                    }else{
                        //let message = jsonDict!["message"] as! String
                        // self.showAlertWithOneButton("", message, "Ok")
                    }
                }) { (error) in
                }
                self.hideTheBottomView(nil)
                
            }
            alert.addAction(yes)
            self.present(alert, animated: true, completion: nil)
        }
        actionSheet.addAction(action)
        
        let action1 = UIAlertAction(title: "Report", style: .default) { (action: UIAlertAction) in
            let reportSheet = UIAlertController(title: "Reason of report:", message: nil, preferredStyle: .actionSheet)
            let slindir = UIAlertAction(title: "Not Slindir Material", style: .default) { (action: UIAlertAction) in
                self.reportUser(reason: "Not Slindir Material")
            }
            reportSheet.addAction(slindir)
            let inappropriate = UIAlertAction(title: "Inappropriate photos", style: .default) { (action: UIAlertAction) in
                self.reportUser(reason: "Inappropriate photos")
            }
            reportSheet.addAction(inappropriate)
            let spam = UIAlertAction(title: "Inappropriate messages", style: .default) { (action: UIAlertAction) in
                self.reportUser(reason: "Inappropriate messages")
            }
            reportSheet.addAction(spam)
            let other = UIAlertAction(title: "Other", style: .default) { (action: UIAlertAction) in
                self.reportUser(reason: "Other")
            }
            reportSheet.addAction(other)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
                
            }
            reportSheet.addAction(cancel)
            self.present(reportSheet, animated: true, completion: nil)
            
        }
        actionSheet.addAction(action1)
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
        }
        actionSheet.addAction(action2)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showBrainGameView() {
        self.view.bringSubviewToFront(self.vwBrain)
        lbl1Brain.alpha = 0
        lbl2Brain.alpha = 0
        lbl3Brain.alpha = 0
        lbl4Brain.alpha = 0
        btnOkBrainGame.alpha = 0        
        self.vwBrain?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        self.vwBrain.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 1, animations: {
                self.vwBrain?.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.vwBrain.alpha = 1
            }, completion: { (completed: Bool) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.lbl1Brain.alpha = 1
                }, completion: { (completed: Bool) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.lbl2Brain.alpha = 1
                    }, completion: { (completed: Bool) in
                        UIView.animate(withDuration: 0.5, animations: {
                            self.lbl3Brain.alpha = 1
                        }, completion: { (completed: Bool) in
                            UIView.animate(withDuration: 0.5, animations: {
                                self.lbl4Brain.alpha = 1
                            }, completion: { (completed: Bool) in
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.btnOkBrainGame.alpha = 1
                                }, completion: { (completed: Bool) in
                                    self.btnAnimation(button: self.btnOkBrainGame)
                                })
                            })
                        })
                    })
                })
            })
            
        }
    }
    
    func btnAnimation(button:UIButton){
        button.rotate(10, 0.05, finished: { (completed: Bool) in
            button.rotate(-10, 0.05, finished: { (completed: Bool) in
                button.rotate(10, 0.05, finished: { (completed: Bool) in
                    button.rotate(-10, 0.05, finished: { (completed: Bool) in
                        button.rotate(10, 0.05, finished: { (completed:Bool) in
                            button.rotate(-10, 0.05, finished: { (completed: Bool) in
                                button.rotate(8, 0.05, finished: { (completed: Bool) in
                                    button.rotate(-8, 0.05, finished: { (completed: Bool) in
                                        button.rotate(6, 0.1, finished: { (completed:Bool) in
                                            button.rotate(-6, 0.1, finished: { (completed:Bool) in
                                                button.rotate(2, 0.2, finished: { (completed:Bool) in
                                                    button.rotate(-2, 0.1, finished: { (completed:Bool) in
                                                        button.rotate(0, 0.1, finished: { (completed:Bool) in
                                                            button.layer.cornerRadius = button.frame.size.height/2
                                                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.5, execute: {
                                                                UIView.animate(withDuration: 0.5, animations: {
                                                                    //self.btnRemindMeLater.alpha = 1
                                                                })
                                                            })
                                                        })
                                                    })
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
    
    func reportUser(reason: String) {
        let userId = LocalStore.store.getFacebookID()
        let report_user = self.swipedUserDict["user_fb_id"] as! String
        let parameters = ["user_fb_id": userId , "report_user_fb_id":report_user, "reason":reason, "reporting_to": "slindirapp@gmail.com"]
        
        WebServices.service.webServicePostRequest(.post, .report, .reportUser, parameters, successHandler: { (response) in
            let jsonDict = response
            let status = jsonDict!["status"] as! String
            if status == "success"{
            }else{
                //let message = jsonDict!["message"] as! String
                //self.showAlertWithOneButton("", message, "Ok")
            }
        }) { (error) in
        }
        self.hideTheBottomView(nil)
    }
    
    @objc func hideTheBottomView(_ gesture: UITapGestureRecognizer!){
        self.constraintScrollViewTop.constant = UIScreen.main.bounds.height
        self.constraintScrollViewBottom.constant = -UIScreen.main.bounds.height
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc  func showBottomView(_ viewCard: CardsView) {
        CustomClass.sharedInstance.playAudio(.bottomView, .mp3)
        self.scrollViewBottom.contentOffset = CGPoint(x: 0, y: 0)
        self.updateTheDetails(self.swipedUserDict)
        self.tableViewFavTeams.reloadData()
        self.constraintScrollViewTop.constant = 0
        self.constraintScrollViewBottom.constant = 0
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed: Bool) in
            
        })
    }
    
    func settingTheView() {
        
        
        let view = Bundle.main.loadNibNamed("Cards", owner: self, options: nil)![0] as? CardsView
        view?.frame = self.viewSliderKoloda.bounds
        view?.cardDelegate = self
        view?.imgViewGold.isHidden = true
        view?.undoCard.isHidden = true
        let angle = CGFloat(Double.pi/2)
        view?.pageControl.transform = CGAffineTransform(rotationAngle: angle)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(showImagesInFullView(_:)))
        view?.scrollVw.addGestureRecognizer(tapGesture)
        
        let userDetails = self.swipedUserDict
        
        let age = String(format:"%d", self.calculateAge(birthday: userDetails["dob"] as! String))

        view?.lblName.text = String(format:"%@, %@",userDetails["user_name"] as! CVarArg, age)
        view?.lblWork.text = String(format:"%@",userDetails["work"] as! CVarArg)
        
        // Used this imgVw to store the images in the cache
        //let imgVwDummy = UIImageView()
        for i in 0..<6 {
            let imgVwDummy = view?.viewWithTag(i+1) as? UIImageView
            if i == 0 {
                if let detail =  userDetails["profile_pic"] as? String {
                    if detail != "" {
                        view?.arrayImages.append(detail)
                        imgVwDummy?.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, detail)), placeholderImage: UIImage.init(named: "placeholder"))
                    }
                }
            }
            else {
                print(userDetails[String(format:"image%d",i)] ?? "")
                if let detail =  userDetails[String(format:"image%d",i)] as? String {
                    if detail != "" {
                        view?.arrayImages.append(detail)
                        imgVwDummy?.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, detail)), placeholderImage: UIImage.init(named: "placeholder"))
                    }
                }
            }
        }
        
        
        if let count = view?.arrayImages.count {
            view?.pageControl.numberOfPages = count
            
            if count > 30{
                view?.pageControlConstant.constant = 400
            }else if count > 20 {
                view?.pageControlConstant.constant = 240
            }else if count > 10{
                view?.pageControlConstant.constant = 180
            }else{
                view?.pageControlConstant.constant = 90
            }
        }else{
            
        }
        view?.btnOpenScroll.addTarget(self, action: #selector(showBottomView(_:)), for: .touchUpInside)
        if let intrests = userDetails["activities"] as?  String{
            let intrestsArray = intrests.components(separatedBy: ",")
            // print("Intrests :- ",intrestsArray)
            if intrestsArray.count > 0{
                activities = intrestsArray
            }
        }
        
        var activitiesArray = [String]()
        
        if let activitiesString = personalDetail["activities"] as? String{
            let activities = activitiesString.components(separatedBy: ",")
            activitiesArray = activities
        }
        
        let btns = [view?.btnInterestOne,view?.btnInterestTwo,view?.btnInterestThree,view?.btnInterestFour]
        for (index,activity) in activities.enumerated(){
            let imageName = activity.lowercased()
            var imageFullName = imageName + "Sel"
            if activitiesArray.contains(activity) {
                imageFullName = imageName + "Gold"
            }
            imageFullName = imageFullName.replacingOccurrences(of: " ", with: "")
            let btn = btns[index]
            let image = UIImage(named: imageFullName)
            btn?.setImage(image, for: .normal)
            btn?.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        }
        
        
        if let brain = userDetails["brain"] as? String {
            if let brainGame = personalDetail["brain"] as? String{
                if brain != brainGame {
                    if let activities = userDetails["activities"] as? String {
                        if let userActivities = personalDetail["activities"] as? String{
                            let myActivities = activities.components(separatedBy: ",")
                            let userActivitesArr = userActivities.components(separatedBy: ",")
                            var activitiesCount = 0
                            for i in 0..<myActivities.count {
                                if userActivitesArr.contains(myActivities[i]) {
                                    activitiesCount = activitiesCount + 1
                                }
                            }
                            if activitiesCount == 4 {
                                view?.imgViewGold.isHidden = false
                            }
                        }
                    }
                }
                else {
                    
                }
            }
        }
        
        if let compatibility = userDetails["compability"] as? Int {
            view?.compatibilityProgress.progressTintColor = UIColor.green
            view?.compatibilityProgress.trackTintColor = UIColor.clear
            view?.compatibilityProgress.roundedCorners = 0
            view?.compatibilityProgress.thicknessRatio = 2.0
            view?.compatibilityProgress.clockwiseProgress = 1
            
            if compatibility == 0 {
                view?.compatibilityProgress.setProgress(0.0, animated: true)
            }
            else {
                view?.compatibilityProgress.setProgress(CGFloat(compatibility)/100, animated: true)
            }
        }
        
        //view?.collectionView.reloadData()
        self.viewSliderKoloda.addSubview(view!)
        
    }
    
    func updateTheDetails(_ details:[String: Any]){
        let name = details["user_name"] as! String
        lblNameScroll.text = name
        
        if let profile_pic = details["profile_pic"] as? String {
            imgViewProfile.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl,profile_pic)), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        if let work = details["work"] as? String{
            lblWorkScroll.text = work
        }
        else{
            if let education = details["education"] as? String{
                lblWorkScroll.text = education
            }
        }
        if let address = details["location"] as? String{
            lblAddressScroll.text = address
        }
        if let aboutUser = details["about_me"] as? String{
            lblAboutScroll.text = aboutUser
            self.stackViewScroll.isHidden = false
        }else{
            lblAboutScroll.text = ""
        }
        if let intrests = details["activities"] as?  String{
            let intrestsArray = intrests.components(separatedBy: ",")
            print("Intrests :- ",intrestsArray)
            if intrestsArray.count > 0{
                activities = intrestsArray
                self.lblActivities.text = activities.joined(separator: ", ")
            }
        }
        
        self.imgVwVideoThumb.image = UIImage()
        /* pre jasvir
        if let detail = details["profile_video"] as? String {
            if detail == "" {
            }
            else {
                videoUrl = String(format:"%@%@", mediaUrl, detail)
                // self.perform(#selector(self.thumbnailFromVideoServerURL(url:)), with: URL(string:self.videoUrl)!, afterDelay: 0.1)
                self.imgVwVideoThumb.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl,(details["profile_thumbnail"] as? String)!)), placeholderImage: nil)
            }
        }
        else {
        }*/
        
 // jasvir changes
        if let detail = details["profile_video"] as? String, !detail.isEmpty{
//        if let detail = details["profile_video"] as? String {
            self.heightVideoVw.isActive = false
            self.heightRatioVideoVw.isActive = true
            videoUrl = String(format:"%@%@", mediaUrl, detail)
            // self.perform(#selector(self.thumbnailFromVideoServerURL(url:)), with: URL(string:self.videoUrl)!, afterDelay: 0.1)
            self.imgVwVideoThumb.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl,(details["profile_thumbnail"] as? String)!)), placeholderImage: nil)
            self.viewVideo.isHidden = false
        }
        else {
            self.viewVideo.isHidden = true
            self.heightVideoVw.isActive = true
            self.heightRatioVideoVw.isActive = false
            self.heightVideoVw.constant = 0
            self.view.layoutIfNeeded()
        }
// end jasvir change
         

        
        self.favoriteTeamArray = [String]()
        if let favSport = details["fav_sport_team_1"] as? String{
            if favSport != "" {
                self.favoriteTeamArray.append(favSport)
            }
        }
        if let favSport = details["fav_sport_team_2"] as? String{
            if favSport != "" {
                self.favoriteTeamArray.append(favSport)
            }
            
        }
        if let favSport = details["fav_sport_team_3"] as? String{
            if favSport != "" {
                self.favoriteTeamArray.append(favSport)
            }
        }
        if let favSport = details["fav_sport_team_4"] as? String{
        	    if favSport != "" {
                self.favoriteTeamArray.append(favSport)
            }
        }
        
        DispatchQueue.main.async {
            self.constraintTableViewHeight.constant = CGFloat(44 * self.favoriteTeamArray.count)
            self.view.layoutIfNeeded()
//            if let brain = details["brain"] as? String {
//                if let brainGame = self.personalDetail["brain"] as? String{
//                    if brain != brainGame {
                        self.heightPersonalityView.constant = 100
                        self.vwPersonality.isHidden = false
                        self.lineBelowPersonality.isHidden = false
                        self.view.layoutIfNeeded()
                  //  }
//                    else {
//                        self.vwPersonality.isHidden = true
//                        self.lineBelowPersonality.isHidden = true
//                        self.heightPersonalityView.constant = 0
//                        self.view.layoutIfNeeded()
//                    }
//                }
//            }
            
            if let compatibility = details["compability"] as? Int {
                self.vwCompatibilityScroll.progressTintColor = UIColor.green
                self.vwCompatibilityScroll.trackTintColor = UIColor.clear
                self.vwCompatibilityScroll.roundedCorners = 0
                self.vwCompatibilityScroll.thicknessRatio = 2.0
                self.vwCompatibilityScroll.clockwiseProgress = 1
                
                self.lblCompatibilityPercentageScroll.text = String(format:"%d%%",compatibility)
                
                if compatibility == 0 {
                    self.vwCompatibilityScroll.setProgress(0.0, animated: true)
                }
                else {
                    self.vwCompatibilityScroll.setProgress(CGFloat(compatibility)/100, animated: true)
                }
            }
        }
        
        self.tableViewFavTeams.reloadData()
        
        if let kids = details["kids"] as? String{
            let kidArray = kids.components(separatedBy: ",")
            if kidArray.contains("want"){
                self.imgViewWantKidsScroll.image = #imageLiteral(resourceName: "checkLogo")
            }
            else {
                self.imgViewWantKidsScroll.image = #imageLiteral(resourceName: "xLogo")
            }
            if kidArray.contains("have"){
                self.imgViewHasKidsScroll.image = #imageLiteral(resourceName: "checkLogo")
            }
            else {
                self.imgViewHasKidsScroll.image = #imageLiteral(resourceName: "xLogo")
            }
        }
        if let iAmHere = details["iam_here_to"] as? String{
            var lookingFor:[String] = []
            if iAmHere.contains("longTerm"){
                lookingFor.append("Long-term dating")
            }
            if iAmHere.contains("short-Term"){
                lookingFor.append("Short-term dating")
            }
            if iAmHere.contains("workout"){
                lookingFor.append("Workout buddy")
            }
            self.lblLookingFor.text = lookingFor.joined(separator: ", ")
        }
        
        if let brain = details["brain"] as? String{
            //self.lblBrainGame.text = brain
            strBrainGame = brain
        }
        
        if let height = details["height"] as? NSString{
            if height != "" {
                let arrHeight = height.components(separatedBy: ".")
                self.lblHeightScroll.text = String(format:"%@' %@\"",arrHeight[0],arrHeight[1])
            }
        }
    }
    
    @objc func showImagesInFullView(_ gesture: UITapGestureRecognizer) {
        let scrollVw = gesture.view as? UIScrollView
        selectedCardScrollVw = scrollVw!
        let index = Int(scrollVw!.contentOffset.y/scrollVw!.frame.size.height)
        let vwCard = scrollVw?.superview as? CardsView
        selectedCardVw = vwCard!
        let count:Int = (vwCard?.arrayImages.count)!
        for i in 0..<count {
            let imgVw = self.view.viewWithTag(i + 201) as! UIImageView
            imgVw.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, (vwCard?.arrayImages[i])!)), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        self.scrollVwFullImage.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: self.scrollVwFullImage.frame.size.height * CGFloat(count))
        self.scrollVwFullImage.contentOffset = CGPoint(x: 0, y: self.scrollVwFullImage.frame.size.height * CGFloat(index))
        self.view.bringSubviewToFront(self.vwScrollImage)
    }
    
    @IBAction func closeScrollVw(_ sender: Any) {
        self.view.sendSubviewToBack(self.vwScrollImage)
    }
    
    @objc func thumbnailFromVideoServerURL(url:URL) {
        if let cacheImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.imgVwVideoThumb.image = cacheImage
            }
        }
        else {
            let asset = AVURLAsset(url: url, options: nil)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let thumbTime: CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 30)
            let maxSize = CGSize(width: 320, height: 320)
            generator.maximumSize = maxSize
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: thumbTime)], completionHandler: { (requestedTime, im, actualTime, result, error) in
                if result != .succeeded {
                    print("couldn't generate thumbnail, error:\(error ?? "" as! Error)")
                    // self.thumbnailFromVideoServerURL(url: url)
                }
                else {
                    DispatchQueue.main.async {
                        imageCache.setObject(UIImage(cgImage: im!), forKey: url as AnyObject)
                        self.imgVwVideoThumb.image = UIImage(cgImage: im!)
                    }
                }
            })
        }
    }
    
    //MARK:-  UIScrollView Delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == scrollViewBottom{
            if scrollViewBottom.contentOffset.y < -90 {
                self.constraintScrollViewTop.constant = UIScreen.main.bounds.height
                self.constraintScrollViewBottom.constant = -UIScreen.main.bounds.height
                UIView.animate(withDuration: 1, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            if scrollViewBottom.contentOffset.y >  scrollViewBottom.contentSize.height - scrollViewBottom.bounds.height{
                scrollViewBottom.contentOffset.y = scrollViewBottom.contentSize.height - scrollViewBottom.bounds.height
            }
        }
        else if scrollView == self.scrollVwFullImage {
            let index = Int(self.scrollVwFullImage!.contentOffset.y/self.scrollVwFullImage!.frame.size.height)
            self.selectedCardScrollVw.contentOffset = CGPoint(x: 0, y: self.selectedCardScrollVw.frame.size.height * CGFloat(index))
            self.selectedCardVw.pageControl.progress = Double(scrollView.contentOffset.y/scrollView.frame.size.height)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let index = Int(self.scrollVwFullImage.contentOffset.y/scrollView.frame.size.height)
        let imageView = self.view.viewWithTag(201 + index) as! UIImageView
        return imageView
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
