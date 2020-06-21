//
//  ProfileViewController.swift
//  GoGetter
//
//  Created by Batth on 15/09/17.
//  Copyright © 2017 Batth. All rights reserved.de
//

import UIKit
import Koloda
import MessageUI
import AVFoundation
import AVKit
import pop
import DACircularProgress
import Firebase
import SwiftyStoreKit

protocol ProfileViewControllerDelegate {
    func showMoreSettings()
    func showMoreProfiles()
    func getCurrentProfileViewController() -> ProfileViewController?
}

class ProfileViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, CardsViewDelegates, MFMessageComposeViewControllerDelegate, PurchaseViewControllerDelegate {
    
//MARK:-  IBOutlets, Variables and Constraints
 
    private let cardResetAnimationSpringBounciness: CGFloat = 10.0
    private let cardResetAnimationSpringSpeed: CGFloat = 20.0
    private let cardResetAnimationKey = "resetPositionAnimation"
    private let cardResetAnimationDuration: TimeInterval = 0.2
    internal var cardSwipeActionAnimationDuration: TimeInterval = DragSpeed.default.rawValue
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var animationDirectionY: CGFloat = 1.0
    private var dragBegin = false
    private var dragDistance = CGPoint.zero
    private var swipePercentageMargin: CGFloat = 0.0
    public var rotationMax: CGFloat = 1.0
    public var rotationAngle  = CGFloat(Double.pi) / 10.0
    public var scaleMin: CGFloat = 0.8
    
    private var currentViewCount = 0
    
    var videoUrl:String = ""
    @IBOutlet var imgVwVideoThumb: UIImageView!
    @IBOutlet var btnPlayVideo: UIButton!
    var profileDelegate: ProfileViewControllerDelegate?
    
    @IBOutlet weak var lblActiveCenterY: NSLayoutConstraint!
    @IBOutlet weak var vwMatch: UIView!
    
    @IBOutlet weak var imgLogoMatch: UIImageView!
    @IBOutlet weak var imgLogoMatchWhite: UIImageView!
    @IBOutlet weak var imgGetterBlack: UIImageView!

    @IBOutlet weak var leadingMatchCurrent: NSLayoutConstraint!
    @IBOutlet weak var trailingMatchOther: NSLayoutConstraint!
    @IBOutlet weak var btnSayHello: UIButton!
    @IBOutlet      var btnMayBeLater: UIButton!
    @IBOutlet weak var imgVwMatchOther: UIImageView!
    @IBOutlet weak var lblMatchOther: UILabel!
    @IBOutlet weak var imgVwMatchCurrent: UIImageView!
    @IBOutlet weak var lblMatchCurrent: UILabel!
    @IBOutlet weak var constraintTopViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintLogoLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintLogoTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintLogoCenter: NSLayoutConstraint!
    @IBOutlet weak var constraintSRight: NSLayoutConstraint!
    @IBOutlet weak var constraintTopViewTop: NSLayoutConstraint!
    @IBOutlet weak var constraintTopViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintScrollViewTop: NSLayoutConstraint!
    @IBOutlet weak var constraintScrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet      var heightPersonalityView: NSLayoutConstraint!
    @IBOutlet weak var heightNavigation: NSLayoutConstraint!
    @IBOutlet weak var topViewFrontConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var heightRatioVideoVw: NSLayoutConstraint!
    @IBOutlet weak var heightVideoVw: NSLayoutConstraint!
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurViewSetting: UIVisualEffectView!
    @IBOutlet weak var blurViewLogo: UIVisualEffectView!
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewFront: UIView!
    @IBOutlet weak var viewLblBackground: UIView!
    @IBOutlet weak var viewTopFront: UIView!
    @IBOutlet weak var viewBottom : BottomView!
    @IBOutlet weak var viewTopNavigation: UIView!
    @IBOutlet weak var viewInnerSlide: UIView!
    @IBOutlet weak var viewSliderKoloda: KolodaView!
    @IBOutlet weak var viewScrollContent: UIView!
    @IBOutlet weak var viewCards: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var viewEditPreferences: UIView!

    @IBOutlet weak var tableViewQuestions: UITableView!
    @IBOutlet weak var tableViewFavTeams: UITableView!
    
    @IBOutlet weak var collectionViewIntrests: UICollectionView!
    
    @IBOutlet weak var lblAreUSure: UILabel!
    @IBOutlet weak var lblActive: UILabel!
    @IBOutlet weak var lblFeelingGood: UILabel!
    @IBOutlet weak var lblQuizDesc: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameScroll: UILabel!
    @IBOutlet weak var lblWorkScroll: UILabel!
    @IBOutlet weak var lblAddressScroll: UILabel!
    @IBOutlet weak var lblAboutScroll: UILabel!
    @IBOutlet weak var lblHeightScroll: UILabel!
    @IBOutlet weak var lblActivities: UILabel!
    
    @IBOutlet weak var btnLetsStart : UIButton!
    @IBOutlet weak var btnOkLetsStart: UIButton!
    @IBOutlet weak var btnRemindMeLater: UIButton!
    @IBOutlet weak var btnBlockAndReport: UIButton!
    @IBOutlet weak var btnShareUserScroll: UIButton!
    @IBOutlet weak var btnInviteAFriend: UIButton!
    
    @IBOutlet weak var imgViewSetting: UIImageView!
    @IBOutlet weak var imgViewBlur: UIImageView!
    @IBOutlet weak var imgViewBackground: UIImageView!
    @IBOutlet weak var imgViewS: UIImageView!
    @IBOutlet weak var imgViewMoreSettings: UIImageView!
    @IBOutlet weak var imgViewHasKidsScroll: UIImageView!
    @IBOutlet weak var imgViewWantKidsScroll: UIImageView!
    @IBOutlet weak var imgViewLineUpper: UIImageView!
    @IBOutlet weak var imgViewLineLower: UIImageView!
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    @IBOutlet weak var scrollViewBottom: UIScrollView!
    
    @IBOutlet weak var stackViewScroll: UIStackView!
    @IBOutlet weak var stackViewCollection: UIStackView!
    
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
    
    @IBOutlet weak var vwAlert: UIView!
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var btnGotIt: UIButton!
    
    var oppUserFBId = ""
    var oppUserName  = ""
    var oppUserImg = ""
    var selectedCardScrollVw = UIScrollView()
    var selectedCardVw = CardsView()
    
    var greenQuestions = [UIImage]()
    var redQuestions = [UIImage]()
    var selectedQuestions = [Int]()
    var name = ["John","Miller","James","Murfy","Smith"]
    var cardsArray = [[String:Any]]()
    var selectedQuestionDict = [String: String]()
    var activities = [String]()
    var nameIndex = 1
    
    var rotateSettingTimer: Timer?
    var rotateMoreSettings: Timer?
    
    var index = 0

    var isFirstTime = true
    
    var isAlreadyLogin = false
    var isSlindirQuiz = false
    
    var favoriteTeamArray:[String] = []
    
    var swipedUserDict = [String: Any]()
    var showBrainGame:Bool = false
    var strBrainGame:String!
    
    var cardIndex:Int = 0
    
    var tipArray:[String]!
    
    var vwCardRight = CardsView()
    var vwCardLeft = CardsView()
    var vwCardMessage = CardsView()
    var vwCardProfile = CardsView()
    var vwCardUndo = CardsView()
    
    var vwCardSelected = CardsView()
    
    var isMessageDemoCard:Bool = false
    
    @IBOutlet weak var btnUndoCard: UIButton!
    
    var cardViewArray = [CardsView]()
    
    // purchase
    var purchase: [PurchaseViewController.PurchaseItem] = []
    var purchasePrompt: String? = nil
    var purchaseScreenAction: Int = 0
    var purchaseConvoId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Intilize and Change the neccessary things
        //let userName = LocalStore.store.getData()
       // lblAreUSure.text = "ARE YOU SURE \(userName)"
        
        
        tipArray = ["Because sweaty is sexy","Because it’s fun to meet like-minded people","Because flirting is allowed here","Growth begins when you step outside your comfort zone.  Go on, try something new.","Conversation is easy when you share common interests.  What are you waiting for?","Action separates the timid from the bold. Go on, give someone a compliment.","Always keep a positive mindset and good things will happen.","No one is looking for anyone perfect, just someone perfect for them.","Like anything, you will only see results if you put the effort in.","Like attracts like. Be positive & dress attractive just like you would want from someone else.","Are your photos any good? Ask a friend of the opposite sex to help you choose the most attractive photos. Remember, it’s what THEY think, not what YOU think.","Dating is legal (and highly encouraged!).  Now pack the pipeline!  We recommend at least 1 date per week.","Grab a HOT drink for your date: Studies show that people who held a hot beverage while meeting someone perceived the other person as warmer, more social, happier and generous","Choose the Cushion: People sitting in hard chairs held a perception of strictness, rigidity, and stability while people sitting on a sofa had a more positive overall impression of the other person","Reasons for an ACTIVE date: Experiencing adrenaline producing activities together, such as exercise or even going to a comedy club can actually attribute the arousal and happiness of the event to their partner. Good to know!","Reasons for an ACTIVE date: Adrenaline producing activities have a greater imprint on the brain making the date more memorable. A great way to start!","Date someone who gives you that same feeling of when you see your food coming at a restaurant.","INTELLIGENCE is the most attractive quality stated by both men and women. You can’t convey this in a photo, be sure to get out and meet in person!"]
        
        self.btnClose.backgroundColor = UIColor.black
        
        NotificationCenter.default.addObserver(self, selector: #selector(matchNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("matchedNotification")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMatchNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("newMatchedNotification")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(likeNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("likedNotification")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(chatNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("chatNotification")), object: nil)
        
        matchScreenUIUpdate()
        startTheFirstAnimations()
        addImagesInArray()
        imgViewMoreSettings.alpha = 0
        smallChangesButNeccessary()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(back))
        imgViewSetting.addGestureRecognizer(tapGesture)
        
        let chatGesture = UITapGestureRecognizer(target: self, action: #selector(chatController))
        imgViewS.addGestureRecognizer(chatGesture)
        addKolodaView()
        
        viewEditPreferences.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editPrefernces)))
        
        tableViewQuestions.estimatedRowHeight = 212
        tableViewQuestions.rowHeight = UITableView.automaticDimension
        
        let tapGestureBottomView = UITapGestureRecognizer(target: self, action: #selector(hideTheBottomView(_ :)))
        viewScrollContent.addGestureRecognizer(tapGestureBottomView)
        navigationController?.navigationBar.isHidden = true
        viewInnerSlide.isHidden = true
        if showBrainGame {
            //DispatchQueue.global(qos: .background).async {
//                self.checkViewCountAndShowMatches()
           // }
            self.viewTopFront.isHidden = true
            self.viewFront.isHidden = true
            self.viewTop.isHidden = true
            showBrainGameView()
        }
        else if LocalStore.store.isQuizDone() {
            if isSlindirQuiz{

                constraintTopViewTop.constant = -UIScreen.main.bounds.size.height
                constraintTopViewBottom.constant = UIScreen.main.bounds.size.height
                self.view.layoutIfNeeded()
                
                self.settingShadowToTopView()
                self.lblActive.alpha = 0
                self.lblFeelingGood.alpha = 0
                self.lblActive.layer.backgroundColor = UIColor.black.cgColor
                self.lblFeelingGood.layer.backgroundColor = UIColor.black.cgColor
                self.viewLblBackground.alpha = 0
                self.viewTopFront.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.gettingTheSelectedQuiz()
                    self.animateTableView()
                }
            }
            else if isAlreadyLogin {
                self.viewTopFront.isHidden = true
                self.viewFront.isHidden = true
                self.viewTop.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startSettingIconRotation()
                }
                self.startProfileViewAnimation()
                self.view.bringSubviewToFront(self.viewCards)
                Loader.startLoader(true)
                self.checkViewCountAndShowMatches()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.gettingTheSelectedQuiz()
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                self.gettingTheSelectedQuiz()
            }
            
            if isSlindirQuiz {
                constraintTopViewTop.constant = -UIScreen.main.bounds.size.height
                constraintTopViewBottom.constant = UIScreen.main.bounds.size.height
                self.view.layoutIfNeeded()
                self.settingShadowToTopView()
                self.lblActive.alpha = 0
                self.lblActive.layer.backgroundColor = UIColor.black.cgColor
                self.lblFeelingGood.alpha = 0
                self.lblFeelingGood.layer.backgroundColor = UIColor.black.cgColor
                self.viewLblBackground.alpha = 0
                self.viewTopFront.isHidden = true
                self.animateTableView()
            }
        }
        
        viewEditPreferences.shadow(0.3, 2, .black, CGSize(width: 2, height: 2))
        btnInviteAFriend.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        
        imgViewProfile.layer.borderColor = UIColor.white.cgColor
        imgViewProfile.layer.borderWidth = 1.5
        imgViewProfile.clipsToBounds = true
        
//Adding the keys in Selected Question Dict.
        for i in 1...15 {
            let key = "\(i)"
            selectedQuestionDict[key] = "0"
        }
        
        if UIScreen.main.bounds.size.height == 736 {
            self.topViewFrontConstraint.constant = 120
            self.lblActiveCenterY.constant = 55
            self.view.layoutIfNeeded()
        }
        else if UIScreen.main.bounds.size.height >= 812 {
            self.topViewFrontConstraint.constant = 140
            self.lblActiveCenterY.constant = 40
            self.heightNavigation.constant = 100
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnLetsStart.layer.cornerRadius = btnLetsStart.frame.size.height/2
        btnOkLetsStart.layer.cornerRadius = btnOkLetsStart.frame.size.height/2
        btnRemindMeLater.layer.cornerRadius = btnRemindMeLater.frame.size.height/2
        btnBlockAndReport.layer.cornerRadius = btnBlockAndReport.frame.size.height/2
        viewEditPreferences.layer.cornerRadius = viewEditPreferences.frame.size.height/2
        btnInviteAFriend.layer.cornerRadius = btnInviteAFriend.frame.size.height/2
        btnOkBrainGame.layer.cornerRadius = btnOkBrainGame.frame.size.height/2
        btnLearnMore.layer.cornerRadius = btnLearnMore.frame.size.height/2
        self.btnClose.layer.cornerRadius = btnClose.frame.size.height/2
        self.btnGotIt.layer.cornerRadius = 15

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.set(true, forKey: "updateSettings")
        UserDefaults.standard.synchronize()
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.currentController = self
        del.startLocationManager()
        self.perform(#selector(remoteNotification), with: nil, afterDelay: 5)
        self.getUserDetails(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            if UserDefaults.standard.bool(forKey:"likedNotification") {
                self.likeNotificationRecived()
            }
            else if UserDefaults.standard.bool(forKey: "matchedNotification") {
                self.matchNotificationRecived()
            }
            else if UserDefaults.standard.bool(forKey: "newMatchedNotification") {
                if UserDefaults.standard.bool(forKey: "newMatchedNotificationClicked") {
                    let data = UserDefaults.standard.object(forKey:"newMatchedUser")
                    if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
                        let alert = UIAlertController.init(title: "New Match:", message: (requiredData["message"] as! String), preferredStyle: .alert)
                        let action = UIAlertAction.init(title: "Say Hello", style: .default, handler: { (action) in
                            self.newMatchNotificationRecived()
                        })
                        let action1 = UIAlertAction.init(title: "Maybe Later", style: .default, handler:{ (action) in
                            UserDefaults.standard.set(false, forKey: "newMatchedNotification")
                            UserDefaults.standard.synchronize()
                        })
                        alert.addAction(action)
                        alert.addAction(action1)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    self.newMatchNotificationRecived()
                }
            }
            else if UserDefaults.standard.bool(forKey: "chatNotification") {
                self.chatNotificationRecived()
            }
        }
    }

    @objc func remoteNotification() {
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.registerForRemoteNotifications()
    }
    
    //MARK:-  Notification functions
    @objc func matchNotificationRecived() {
        DispatchQueue.main.async {
            self.showMatchingProfileView();
            self.doConvoMatched();
//            self.doConvoMatched();
//            self.showMatchingProfileView()
        }
    }
    
    @objc func newMatchNotificationRecived() {
        // verify that we have created a convo
        let listController = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController")
        navigationController?.pushViewController(listController!, animated: true)
    }
    
    @objc func likeNotificationRecived() {
        UserDefaults.standard.set(false, forKey: "likedNotification")
        UserDefaults.standard.synchronize()
        
        let data = UserDefaults.standard.object(forKey:"LikedUser")
        if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
            let alert = UIAlertController.init(title: "", message: (requiredData["message"] as! String), preferredStyle: .alert)
            let action = UIAlertAction.init(title: "View Profile", style: .default, handler: { (action) in
                DispatchQueue.main.async {
                    let userDict = requiredData["sender"]  as? [String: Any]
                    if self.viewSliderKoloda.currentCardIndex != 0 && self.viewSliderKoloda.currentCardIndex < self.cardsArray.count{
                        self.cardsArray.removeFirst(self.viewSliderKoloda.currentCardIndex)
                        self.cardsArray.insert(userDict!, at: 0)
                        self.viewSliderKoloda.resetCurrentCardIndex()
                    }
                    else {
                        self.cardsArray.insert(userDict!, at: 0)
                        self.viewSliderKoloda.reloadData()
                    }
                    
                }
            })
            let action1 = UIAlertAction.init(title: "Cancel", style: .default, handler:nil)
            alert.addAction(action)
            alert.addAction(action1)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    @objc func chatNotificationRecived() {
        self.chatController()
    }
    
//MARK:-  Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showBrainGameView() {
        self.view.bringSubviewToFront(self.vwBrain)
        lbl1Brain.alpha = 0
        lbl2Brain.alpha = 0
        lbl3Brain.alpha = 0
        lbl4Brain.alpha = 0
        btnOkBrainGame.alpha = 0
        if showBrainGame {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
            }
        }
        else {
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
    }
    
    func matchScreenUIUpdate() {
        self.imgVwMatchCurrent.transform = CGAffineTransform(rotationAngle: CGFloat(12.48))
        self.lblMatchCurrent.transform = CGAffineTransform(rotationAngle: CGFloat(12.46))
        self.imgVwMatchOther.transform = CGAffineTransform(rotationAngle: CGFloat(12.65))
        self.lblMatchOther.transform = CGAffineTransform(rotationAngle: CGFloat(12.67))
        self.btnSayHello.layer.cornerRadius = 16
        self.btnSayHello.clipsToBounds = true
        self.btnMayBeLater.layer.cornerRadius = 16
        self.btnMayBeLater.clipsToBounds = true
    }
    
    @objc func showMatchingProfileView() {
        self.vwMatch.isHidden = false
        self.view.bringSubviewToFront(self.vwMatch)
        
        let data = UserDefaults.standard.object(forKey:"matchedUser")
        if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
            let userOtherDict = requiredData["request_to"] as? [String: Any]
            let userCurrentDict = LocalStore.store.getUserDetails()
            oppUserFBId = userOtherDict?["user_fb_id"] as! String
            oppUserName = userOtherDict?["user_name"] as! String
            oppUserImg = userOtherDict?["profile_pic"] as! String
            
            if let username = userOtherDict!["user_name"] as? String {
                self.lblMatchOther.text = username
            }
            if let profilePic = userOtherDict!["profile_pic"] as? String {
                self.imgVwMatchOther.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profilePic)), placeholderImage: UIImage.init(named: "placeholder"))
            }

            if let username = userCurrentDict["user_name"] as? String {
                self.lblMatchCurrent.text = username
            }
            if let profilePic = userCurrentDict["profile_pic"] as? String {
                self.imgVwMatchCurrent.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profilePic)), placeholderImage: UIImage.init(named: "placeholder"))
            }
            
            self.animateTitle()
            //self.doConvoMatched();

            self.btnSayHello?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.btnSayHello.alpha = 0
            
            self.btnMayBeLater?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.btnMayBeLater.alpha = 0
            
            
            UIView.animate(withDuration: 0.6, animations: {
                self.leadingMatchCurrent.constant = 30
                self.trailingMatchOther.constant = 30
                
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.leadingMatchCurrent.constant = -30
                    self.trailingMatchOther.constant = -30
                    
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.leadingMatchCurrent.constant = 1
                        self.trailingMatchOther.constant = 1
                        
                        self.view.layoutIfNeeded()
                    }, completion: { (completed) in
                        UIView.animate(withDuration: 0.4, animations: {
                            
                            self.btnSayHello?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                            self.btnSayHello.alpha = 1
                        }, completion: { (completed) in
                            self.btnSayHello?.transform = CGAffineTransform(scaleX: 1, y: 1)
                            
                            self.animateSayHelloBtn()
                        })
                    })
                })
            })
        }
        
    }
    
    func animateTitle(){
        //        imgViewS.isHidden = true
        imgLogoMatch.isHidden = true
        
        imgLogoMatchWhite.isHidden = false
        imgGetterBlack.isHidden = false
        
        let centerWhite = self.imgLogoMatchWhite.center.x
        let centerGo = self.imgGetterBlack.center.x
        
        self.imgLogoMatchWhite.center.x -= self.view.bounds.width
        self.imgGetterBlack.center.x += self.view.bounds.width
        
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
            self.imgLogoMatchWhite.center.x = centerWhite
            self.imgGetterBlack.center.x = centerGo
        }, completion: nil)
    }
    
    func animateSayHelloBtn() {
        self.btnSayHello.rotate(10, 0.05, finished: { (completed: Bool) in
            self.btnSayHello.rotate(-10, 0.05, finished: { (completed: Bool) in
                self.btnSayHello.rotate(10, 0.05, finished: { (completed: Bool) in
                    self.btnSayHello.rotate(-10, 0.05, finished: { (completed: Bool) in
                        self.btnSayHello.rotate(10, 0.05, finished: { (completed:Bool) in
                            self.btnSayHello.rotate(-10, 0.05, finished: { (completed: Bool) in
                                self.btnSayHello.rotate(8, 0.05, finished: { (completed: Bool) in
                                    self.btnSayHello.rotate(-8, 0.05, finished: { (completed: Bool) in
                                        self.btnSayHello.rotate(6, 0.1, finished: { (completed:Bool) in
                                            self.btnSayHello.rotate(-6, 0.1, finished: { (completed:Bool) in
                                                self.btnSayHello.rotate(2, 0.2, finished: { (completed:Bool) in
                                                    self.btnSayHello.rotate(-2, 0.1, finished: { (completed:Bool) in
                                                        self.btnSayHello.rotate(0, 0.1, finished: { (completed:Bool) in
                                                            self.btnMayBeLater?.transform = CGAffineTransform(scaleX: 1, y: 1)
                                                            self.btnMayBeLater.alpha = 1
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
    
    func gettingTheSelectedQuiz(){
        //Get the Marked Questions
        let fbid = LocalStore.store.getFacebookID()
        let paramters = ["user_fb_id": fbid]
        WebServices.service.webServicePostRequest(.post, .quiz, .fetchUserQuiz, paramters, successHandler: { (response) in
            let jsonDict = response
            if let status = jsonDict!["status"] as? String{
                if status == "success"{
                    self.tableViewQuestions.reloadData()
                    if let quizAnswers = jsonDict!["quiz_values"] as? [String: String]{
                        for (key, answer) in quizAnswers{
                            if answer == "1"{
                                if let intKey = Int(key){
                                    self.selectedQuestionDict[key] = "1"
                                    self.selectedQuestions.append(intKey - 1)
                                    let indexPath = IndexPath(item: intKey - 1, section: 0)
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1 , execute: {
                                        self.btnLetsStart.setTitle("ALL DONE!", for: .normal)
                                        self.tableViewQuestions.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                                    })
                                }
                            }
                        }
                        if self.selectedQuestions.count > 0 {
                            LocalStore.store.quizDone = true
                        }
                    }
                    
                }
            }
        }, errorHandler: { (error) in
            self.showAlertWithOneButton("GoGetter!", "Please check your internet connection.", "OK")
        })
    }
    
    @objc func doMatchingProfiles(){
        let facebookId = LocalStore.store.getFacebookID()
        let parameters = ["user_fb_id":facebookId]
        WebServices.service.webServicePostRequest(.post, .match, .fetchMatchedProfile, parameters, successHandler: { (response) in
            DispatchQueue.main.async {
                Loader.stopLoader()
                var jsonDict = response
                print(jsonDict ?? "")
                let status = jsonDict!["status"] as! String
                if status == "success"{
                    if let matchingFriendsArray = jsonDict!["matchedProfiles"] as? [Dictionary<String, Any>]{
                        if matchingFriendsArray.count > 0 {
                            self.cardsArray = matchingFriendsArray
                            var randomCount = 0
                            if matchingFriendsArray.count > 10 {
                                randomCount = 3
                            }
                            else if matchingFriendsArray.count > 5 {
                                randomCount = 2
                            }
                            else if matchingFriendsArray.count > 2 {
                                randomCount = 1
                            }
                            if randomCount != 0 {
                                let arr = self.uniqueRandoms(numberOfRandoms: randomCount, minNum: 0, maxNum: UInt32(matchingFriendsArray.count))
                                //Generate random number and add tip card
                                var first = arr[0] //Int(arc4random_uniform(UInt32(self.cardsArray.count)))
                                //Int(arc4random_uniform(UInt32(self.cardsArray.count)))
                                //Int(arc4random_uniform(UInt32(self.cardsArray.count)))
                                
                                
                                let tip = ["tipText":self.tipArray[Int(arc4random_uniform(UInt32(self.tipArray.count)))]]
                                if matchingFriendsArray.count > 2 {
                                    if first == matchingFriendsArray.count {
                                        first = first - 1
                                    }
                                    if first == 0 {
                                        first = 1
                                    }
                                    print("tip",tip)
                                    print("first",first)
                                    self.cardsArray.insert(tip, at: first)
                                }
                                let tip1 = ["tipText":self.tipArray[Int(arc4random_uniform(UInt32(self.tipArray.count - 1)))]]
                                if matchingFriendsArray.count > 5 {
                                    var second = arr[1]
                                    if second == matchingFriendsArray.count {
                                        second = second - 1
                                    }
                                    if second == 0 {
                                        second = 1
                                    }
                                    self.cardsArray.insert(tip1, at: second)
                                }
                                let tip2 = ["tipText":self.tipArray[Int(arc4random_uniform(UInt32(self.tipArray.count)))]]
                                if matchingFriendsArray.count > 10 {
                                    var third = arr[2]
                                    if third == matchingFriendsArray.count {
                                        third = third - 1
                                    }
                                    if third == 0 {
                                        third = 1
                                    }
                                    self.cardsArray.insert(tip2, at: third)
                                }
                            }
                            self.viewSliderKoloda.reloadData()
                        }
                    } else{
                        self.btnUndoCard.isHidden = true
                        self.viewInnerSlide.isHidden = false
                    }
                }else{
                    if jsonDict!["message"] as? String == "No Matched Users Available!" {
                        self.btnUndoCard.isHidden = true
                        self.viewInnerSlide.isHidden = false
                    }
                    
                    Loader.stopLoader()
                }
                if !self.isAlreadyLogin {
                    self.addDemoSwipableViews()
                }
            }
        }) { (error) in
            Loader.stopLoader()
            self.showAlertWithOneButton("Error", error?.localizedDescription, "Ok")
            print("Error :- ",error!.localizedDescription)
        }
    }
    
//      func webServicePostRequest(_ servcieType: ServiceType,_ model: Model, _ methods:Services ,_ parameters: Dictionary<String, Any>?, successHandler success:@escaping (_ response: Dictionary<String, Any>?) -> Void, errorHandler serviceError:@escaping (_ error: Error?) -> Void){
          
    
     func checkDailyLimit(successHandler success:@escaping (_ response: Bool) -> Void) {
        let facebookID = LocalStore.store.getFacebookID()
        
        if !facebookID.isEmpty {
            var parameters = Dictionary<String, Any?>()
            parameters["user_fb_id"] = facebookID
            WebServices.service.webServicePostRequest(.post, .user, .queryViewCount, parameters as Dictionary<String, Any>, successHandler: { (response) in
                Loader.stopLoader()
                let jsonData = response
                let status = jsonData!["status"] as! String
                self.currentViewCount = jsonData!["view_count"] as! Int
                if status == "success"{
                    if self.currentViewCount <= 0 {
                        success(false)
//                        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
                    }
                    else{
                        success(true)
                    }
                }
            }, errorHandler: { (error) in
                success(true)
            })
        }
    }
    
    func outAlert(title: String, message: String, completeHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default) { (action:UIAlertAction) in
            completeHandler?()
        })
        
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func checkViewCountAndShowMatches(){
        // first check view count
        checkDailyLimit(successHandler: { (response) in
           if (response == false){
            self.viewInnerSlide.isHidden = false
            self.btnUndoCard.isHidden = true
            self.outAlert(title: "Sorry!", message: "out of views for today, check back in, in 24 hours", completeHandler : nil)
           }
           else{
            self.doMatchingProfiles()
           }
       })
    }
    
    func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: UInt32) -> [Int] {
        var uniqueNumbers = Set<Int>()
        while uniqueNumbers.count < numberOfRandoms {
            uniqueNumbers.insert(Int(arc4random_uniform(maxNum)) + minNum)
        }
        return Array(uniqueNumbers)
    }
    
    func addDemoSwipableViews() {
        self.imgViewS.isUserInteractionEnabled = false
        self.imgViewSetting.isUserInteractionEnabled = false
        
        let angle = CGFloat(Double.pi/2)
        self.vwCardRight = Bundle.main.loadNibNamed("Cards", owner: self, options: nil)![0] as! CardsView
        self.vwCardRight.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 80)
        if UIScreen.main.bounds.size.height == 812  {
            self.vwCardRight.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 100)
        }
        self.vwCardRight.cardDelegate = self
        self.vwCardRight.imgViewGold.isHidden = true
        self.vwCardRight.pageControlRight.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardRight.pageControl.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardRight.pageControlLeft.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardRight.pageControlMessage.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardRight.pageControlProfileDetail.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardRight.pageControlUndo.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardRight.bringSubviewToFront(self.vwCardRight.vwRight)
        
        let rightGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognized(_:)))
        self.vwCardRight.addGestureRecognizer(rightGesture)
        
        self.vwCardMessage = Bundle.main.loadNibNamed("Cards", owner: self, options: nil)![0] as! CardsView
        self.vwCardMessage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 80)
        if UIScreen.main.bounds.size.height == 812  {
            self.vwCardMessage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 100)
        }
        self.vwCardMessage.cardDelegate = self
        self.vwCardMessage.imgViewGold.isHidden = true
        self.vwCardMessage.pageControlMessage.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardMessage.pageControlRight.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardMessage.pageControlLeft.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardMessage.pageControl.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardMessage.pageControlProfileDetail.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardMessage.pageControlUndo.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardMessage.bringSubviewToFront(self.vwCardMessage.vwMessage)

        
        self.vwCardLeft = Bundle.main.loadNibNamed("Cards", owner: self, options: nil)![0] as! CardsView
        self.vwCardLeft.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 80)
        if UIScreen.main.bounds.size.height == 812  {
            self.vwCardLeft.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 100)
        }
        self.vwCardLeft.cardDelegate = self
        self.vwCardLeft.imgViewGold.isHidden = true
        self.vwCardLeft.pageControlLeft.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardLeft.pageControlRight.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardLeft.pageControlMessage.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardLeft.pageControl.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardLeft.pageControlProfileDetail.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardLeft.pageControlUndo.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardLeft.bringSubviewToFront(self.vwCardLeft.vwLeft)

        let leftGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognized(_:)))
        self.vwCardLeft.addGestureRecognizer(leftGesture)
        
        self.vwCardProfile = Bundle.main.loadNibNamed("Cards", owner: self, options: nil)![0] as! CardsView
        self.vwCardProfile.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 80)
        if UIScreen.main.bounds.size.height == 812  {
            self.vwCardProfile.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 100)
        }
        self.vwCardProfile.cardDelegate = self
        self.vwCardProfile.imgViewGold.isHidden = true
        self.vwCardProfile.pageControlLeft.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardProfile.pageControlRight.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardProfile.pageControlMessage.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardProfile.pageControl.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardProfile.pageControlProfileDetail.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardProfile.pageControlUndo.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardProfile.bringSubviewToFront(self.vwCardProfile.vwProfileDetail)
        
        self.vwCardUndo = Bundle.main.loadNibNamed("Cards", owner: self, options: nil)![0] as! CardsView
        self.vwCardUndo.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 80)
        if UIScreen.main.bounds.size.height == 812  {
            self.vwCardUndo.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height - 100)
        }
        self.vwCardUndo.cardDelegate = self
        self.vwCardUndo.imgViewGold.isHidden = true
        self.vwCardUndo.pageControlLeft.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardUndo.pageControlRight.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardUndo.pageControlMessage.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardUndo.pageControl.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardUndo.pageControlProfileDetail.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardUndo.pageControlUndo.transform = CGAffineTransform(rotationAngle: angle)
        self.vwCardUndo.bringSubviewToFront(self.vwCardUndo.vwUndo)

        
        self.vwCardLeft.isUserInteractionEnabled = false
        self.vwCardMessage.isUserInteractionEnabled = false
        self.vwCardProfile.isUserInteractionEnabled = false
        self.vwCardUndo.isUserInteractionEnabled = false
        
        self.viewSliderKoloda.addSubview(self.vwCardUndo)
        self.viewSliderKoloda.addSubview(self.vwCardProfile)
        self.viewSliderKoloda.addSubview(self.vwCardMessage)
        self.viewSliderKoloda.addSubview(self.vwCardLeft)
        self.viewSliderKoloda.addSubview(self.vwCardRight)
        
        
    let personalDetail = LocalStore.store.getUserDetails()
        if let gender = personalDetail["looking_for"] as? String {
            if gender == "Woman" {
                self.vwCardRight.imgVwDemoRight.image = #imageLiteral(resourceName: "andrea")
                self.vwCardLeft.imgVwDemoLeft.image = #imageLiteral(resourceName: "andrea")
                self.vwCardMessage.imgVwDemoMessage.image = #imageLiteral(resourceName: "andrea")
                self.vwCardProfile.imgVwDemoProfile.image = #imageLiteral(resourceName: "andrea")
                self.vwCardUndo.imgVwDemoUndo.image = #imageLiteral(resourceName: "andrea")
                
                self.vwCardRight.lblDemoRight.text = "Andrea, 33"
                self.vwCardLeft.lblDemoLeft.text = "Andrea, 33"
                self.vwCardMessage.lblDemoMessage.text = "Andrea, 33"
                self.vwCardProfile.lblDemoProfile.text = "Andrea, 33"
                self.vwCardUndo.lblDemoUndo.text = "Andrea, 33"
            }
            else {
                self.vwCardRight.imgVwDemoRight.image = #imageLiteral(resourceName: "mike")
                self.vwCardLeft.imgVwDemoLeft.image = #imageLiteral(resourceName: "mike")
                self.vwCardMessage.imgVwDemoMessage.image = #imageLiteral(resourceName: "mike")
                self.vwCardProfile.imgVwDemoProfile.image = #imageLiteral(resourceName: "mike")
                self.vwCardUndo.imgVwDemoUndo.image = #imageLiteral(resourceName: "mike")
                
                self.vwCardRight.lblDemoRight.text = "Mike, 34"
                self.vwCardLeft.lblDemoLeft.text = "Mike, 34"
                self.vwCardMessage.lblDemoMessage.text = "Mike, 34"
                self.vwCardProfile.lblDemoProfile.text = "Mike, 34"
                self.vwCardUndo.lblDemoUndo.text = "Mike, 34"
            }
        }
    }
    func addKolodaView(){
        viewSliderKoloda.delegate = self
        viewSliderKoloda.dataSource = self
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
//MARK:-  UICollectionView Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileActivitiesCell", for: indexPath) as! ProfileActivitiesCell
        let name = activities[indexPath.item]
        cell.lblName.text = name.capitalizingFirstLetter()
        
        let imageName = activities[indexPath.item].lowercased()
        var imageFullName = imageName + "Sel"
        imageFullName = imageFullName.replacingOccurrences(of: " ", with: "")
        print(imageFullName)
        cell.imgViewActivity.image = UIImage(named: imageFullName)
        return cell
    }
    
//MARK:-  UICollectionView Flow Layout Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 134)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
//MARK:-  UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewQuestions {
            return greenQuestions.count
        }else{
            return favoriteTeamArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if  tableView == tableViewQuestions {
            let cellIdentifier = "Cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! QuestionTableViewCell
            if selectedQuestions.count > 0 {
                if selectedQuestions.contains(indexPath.row) {
                    cell.imgViewQuestion.image = greenQuestions[indexPath.row]
                    cell.imgViewQuestion.transform = .identity
                }else{
                    cell.imgViewQuestion.image = redQuestions[indexPath.row]
                    cell.imgViewQuestion.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            }
            else {
                cell.imgViewQuestion.image = redQuestions[indexPath.row]
                cell.imgViewQuestion.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            
            cell.selectionStyle = .none
            
            return cell
        }else{
            let cellIdentifier = "TeamCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TeamCell
            
            cell.lblTeam.text = favoriteTeamArray[indexPath.row]
            
            return cell
        }
    }
    
//MARK:-  UITableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tableViewQuestions {
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            let key = "\(indexPath.row + 1)"
            selectedQuestionDict[key] = "1"
            let cell = tableView.cellForRow(at: indexPath) as! QuestionTableViewCell
            selectedQuestions.append(indexPath.row)
            cell.imgViewQuestion.image = greenQuestions[indexPath.row]
            UIView.animate(withDuration: 0.3) {
                cell.imgViewQuestion.transform = .identity
            }
        }else{
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if tableView == tableViewQuestions {
            CustomClass.sharedInstance.playAudio(.popRed, .mp3)
            
            let cell = tableView.cellForRow(at: indexPath) as! QuestionTableViewCell
            if let index = selectedQuestions.index(of: indexPath.row){
                
                let key = "\(indexPath.row + 1)"
                selectedQuestionDict[key] = "0"
                
                selectedQuestions.remove(at: index)
                cell.imgViewQuestion.image = redQuestions[indexPath.row]
                UIView.animate(withDuration: 0.3, animations: {
                    cell.imgViewQuestion.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            }
        }else{
            
        }
    }
    
    var gettingTheTableViewHeight: CGFloat{
        tableViewFavTeams.layoutIfNeeded()
        return tableViewFavTeams.contentSize.height
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
        }else if scrollView == tableViewQuestions{
            if tableViewQuestions.contentOffset.y > scrollView.contentSize.height - tableViewQuestions.bounds.height{
                tableViewQuestions.contentOffset.y = tableViewQuestions.contentSize.height - tableViewQuestions.bounds.height
                if isFirstTime{
                    UIView.animate(withDuration: 0.7, animations: {
                        self.imgViewMoreSettings.alpha = 1
                    }, completion: { (completed) in
                        self.isFirstTime = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            if self.rotateMoreSettings != nil {
                                self.rotateMoreSettings?.invalidate()
                                self.rotateMoreSettings = nil
                            }
                        })
                        if self.rotateMoreSettings == nil{
                            self.rotateMoreSettings = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.animateMoreSettingIcon), userInfo: nil, repeats: true)
                        }
                    })
                }
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
    
    
    
//MARK:-  Card Controller Delegates
   @objc  func showBottomView(_ viewCard: CardsView) {
        CustomClass.sharedInstance.playAudio(.bottomView, .mp3)
        self.scrollViewBottom.contentOffset = CGPoint(x: 0, y: 0)
        self.updateTheDetails(self.cardsArray[self.cardIndex])
        self.tableViewFavTeams.reloadData()
        self.constraintScrollViewTop.constant = 0
        self.constraintScrollViewBottom.constant = 0
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed: Bool) in
            
        })
    }
    
    @objc func undoPreviousCard() {
       self.viewSliderKoloda.revertAction()
    }
    
    func undoDemoCard() {
        self.vwCardSelected = self.vwCardUndo
        self.startAnimationOfCards("undo")
        // fhc convenient place to make sure we ahve notifications up on registration
        self.remoteNotification()
    }
    
    func profileDemoCard() {
        self.vwCardSelected = self.vwCardProfile
        self.startAnimationOfCards("profile")
    }
    
//MARK:-  Local Methods & Animation Functions
    
    @objc func back(){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        self.profileDelegate?.showMoreSettings()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func hideTheBottomView(_ gesture: UITapGestureRecognizer!){
        self.constraintScrollViewTop.constant = UIScreen.main.bounds.height
        self.constraintScrollViewBottom.constant = -UIScreen.main.bounds.height
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func smallChangesButNeccessary(){
        btnOkLetsStart.shadowButton(0.3, 3, .black, CGSize(width: 2, height: 2))
        btnRemindMeLater.shadowButton(0.2, 2, .black, CGSize(width: 2, height: 2))
        
        tableViewQuestions.estimatedRowHeight = 154
        tableViewQuestions.rowHeight = UITableView.automaticDimension
        tableViewFavTeams.estimatedRowHeight = 44
        tableViewFavTeams.rowHeight = UITableView.automaticDimension
        
        self.constraintScrollViewTop.constant = UIScreen.main.bounds.height
        self.constraintScrollViewBottom.constant = -UIScreen.main.bounds.height
        scrollViewBottom.scrollIndicatorInsets = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
        viewTopNavigation.shadow(0.2, 0.5, .black, CGSize(width: 1, height: 1))
        viewBottom.shadow(0.9, 20, .black, CGSize(width: 1, height: 1))
    }
    
    func addImagesInArray(){
        greenQuestions = [#imageLiteral(resourceName: "Question1g"),#imageLiteral(resourceName: "Question2g"),#imageLiteral(resourceName: "Question3g"),#imageLiteral(resourceName: "Question4g"),#imageLiteral(resourceName: "Question5g"),#imageLiteral(resourceName: "Question6g"),#imageLiteral(resourceName: "Question7g"),#imageLiteral(resourceName: "Question8g"),#imageLiteral(resourceName: "Question9g"),#imageLiteral(resourceName: "Question10g"),#imageLiteral(resourceName: "Question11g"),#imageLiteral(resourceName: "Question12g"),#imageLiteral(resourceName: "Question13g"),#imageLiteral(resourceName: "Question14g"),#imageLiteral(resourceName: "Question15g")]
        redQuestions = [#imageLiteral(resourceName: "Question1r"),#imageLiteral(resourceName: "Question2r"),#imageLiteral(resourceName: "Question3r"),#imageLiteral(resourceName: "Question4r"),#imageLiteral(resourceName: "Question5r"),#imageLiteral(resourceName: "Question6r"),#imageLiteral(resourceName: "Question7r"),#imageLiteral(resourceName: "Question8r"),#imageLiteral(resourceName: "Question9r"),#imageLiteral(resourceName: "Question10r"),#imageLiteral(resourceName: "Question11r"),#imageLiteral(resourceName: "Question12r"),#imageLiteral(resourceName: "Question13r"),#imageLiteral(resourceName: "Question14r"),#imageLiteral(resourceName: "Question15r")]
    }
    
    func startTheFirstAnimations(){
        lblQuizDesc.alpha = 0
        btnOkLetsStart.alpha = 0
        btnRemindMeLater.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: { 
                self.lblQuizDesc.alpha = 1
            }, completion: { (completed: Bool) in
                UIView.animate(withDuration: 0.5, animations: { 
                    self.btnOkLetsStart.alpha = 1
                }, completion: { (completed: Bool) in
                    self.btnAnimation(button: self.btnOkLetsStart)
                })
            })
        }
    }
    
    func settingShadowToTopView(){
        self.viewTop.shadow(1, 50, .white, CGSize(width: 1, height: 1))
    }
//
//    func continueAnimation(){
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            self.constraintTopViewHeight.constant = UIScreen.main.bounds.height
//            UIView.animate(withDuration: 0.4, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: { (completed) in
//                self.hideTheLogo()
//            })
//        }
//    }
    
    
    
    func startTitleLogoAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.constraintTopViewHeight.constant = UIScreen.main.bounds.height
            if UIScreen.main.bounds.size.height == 736 {
                self.constraintLogoCenter.constant = -10
            }
            else {
                self.constraintLogoCenter.constant = -40
            }
            self.constraintLogoLeading.constant = 112
            self.constraintLogoTrailing.constant = 112
            self.viewLblBackground.layer.backgroundColor = UIColor.white.cgColor
            self.viewLblBackground.alpha = 1
           // self.imgViewS.tintColor = .darkGray
            UIView.animate(withDuration: 0.4, animations: {
                self.imgViewBlur.alpha = 0
                self.viewFront.layer.backgroundColor = UIColor.white.cgColor
                self.viewTop.layer.backgroundColor = UIColor.clear.cgColor

            })
            UIView.animate(withDuration: 1, animations: { 
                self.viewFront.alpha = 0
            })
            UIView.animate(withDuration: 3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed: Bool) in
                self.imgViewBackground.alpha = 0
            })
        }
        ClientLog.WriteClientLog( msgType: "feelgood", msg:"before");

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.constraintLogoLeading.constant = 85
            self.constraintLogoTrailing.constant = 85
            UIView.animate(withDuration: 4, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed: Bool) in
            })
           
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 3, animations: {
                self.lblActive.alpha = 1
                self.lblFeelingGood.alpha = 1
            }, completion: { (completed:Bool) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.lblActive.layer.backgroundColor = UIColor.clear.cgColor
                    self.lblFeelingGood.layer.backgroundColor = UIColor.clear.cgColor
                })
                UIView.animate(withDuration: 1.8, animations: {
                    self.blurView.alpha = 0
                    ClientLog.WriteClientLog( msgType: "feelgood", msg:"hide logo");
                    self.hideTheLogo()
                })
            })
        }
    }
    
    func animateTableView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.tableViewQuestions.setContentOffset(CGPoint(x: 0, y: 200), animated: false)
        }) { (completed) in
            UIView.animate(withDuration: 0.5, animations: {
                self.tableViewQuestions.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }, completion: { (completed) in
                
            })
        }
    }
    
    func hideTheLogo(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.lblActive.alpha = 0
            self.lblFeelingGood.alpha = 0
            self.viewLblBackground.alpha = 0
            self.viewTop.backgroundColor = .white
            self.constraintLogoCenter.constant = 20

            UIView.animate(withDuration: 1, animations: {
                ClientLog.WriteClientLog( msgType: "sonar", msg:"post 1 second layout if needed");
                self.view.layoutIfNeeded()
            }, completion: { (completed: Bool) in
                self.constraintLogoCenter.constant = -UIScreen.main.bounds.height/2
                self.constraintTopViewHeight.constant = 0
                ClientLog.WriteClientLog( msgType: "sonar not seen here", msg:"before 2 sec animation fails if only log");

                UIView.animate(withDuration: 2, animations: {
                    self.view.layoutIfNeeded()
                    self.viewTop.alpha = 0
                }, completion: { (completed: Bool) in
                })
//                ClientLog.WriteClientLog( msgType: "feelgood", msg:"hide logo - animate");

                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//                    ClientLog.WriteClientLog( msgType: "sonar", msg:"hide logo - animate after");
                    self.startSettingIconRotation()
                })
                UIView.animate(withDuration: 3, animations: { 
                    
                }, completion: { (completed: Bool) in
//                    ClientLog.WriteClientLog( msgType: "sonar", msg:"hide logo - animate complete");

                    self.startProfileViewAnimation()
//                    ClientLog.WriteClientLog( msgType: "sonar", msg:"already logged in");

                    if !self.isAlreadyLogin {
//                        ClientLog.WriteClientLog( msgType: "feelgood", msg:"already logged in - anim swipe cards");
                        self.animateSwipeCards(15, 90, self.vwCardRight, (self.vwCardRight.trailingRight)!)
                    }
                })
            })
        }
    }
    
    func startSettingIconRotation(){
        rotateSettingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(animateSettingIcon), userInfo: nil, repeats: false)
        //DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
           // self.rotateSettingTimer?.invalidate()
        //}
        
    }
    
    func startProfileViewAnimation(){
       // self.imgViewS.tintColor = .darkGray
        UIView.animate(withDuration: 3, delay: 0, options: .curveLinear, animations: {
            self.blurViewSetting.alpha = 0
        }) { (completed: Bool) in
            self.constraintSRight.constant = -(UIScreen.main.bounds.width - UIScreen.main.bounds.width/2 - 65)
            self.blurViewSetting.isHidden = true
            self.blurViewSetting.alpha = 1

            UIView.animate(withDuration: 1, animations: {
                self.view.layoutIfNeeded()
                self.blurViewLogo.alpha = 0
            }, completion: { (completed: Bool) in
                ClientLog.WriteClientLog( msgType: "feelgood", msg:"startProfileViewAnimation complete");

                self.blurViewLogo.isHidden = true
                self.blurViewLogo.alpha = 1
            })
        }
    }
    
    @objc func animateSettingIcon(){
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            self.imgViewSetting.transform = self.imgViewSetting.transform.rotated(by: CGFloat(Double.pi))
        }) { (completed: Bool) in
             self.rotateSettingTimer?.invalidate()
        }
    }
    
    @objc func animateMoreSettingIcon(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.imgViewMoreSettings.transform = self.imgViewMoreSettings.transform.rotated(by: CGFloat(Double.pi))
        }) { (completed: Bool) in
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
    
    
    func saveSelectedQuestions(){
        Loader.startLoader(true)
        let fb_id = LocalStore.store.getFacebookID()
        let paramters = ["user_fb_id": fb_id,"quiz_answers":selectedQuestionDict] as [String : Any]
        WebServices.service.webServicePostRequest(.post, .quiz, .saveUserQuiz, paramters, successHandler: { (response) in
            Loader.stopLoader()
            let jsonDict = response
            if let status = jsonDict!["status"] as? String{
                if status == "success"{
                    DispatchQueue.main.async {
                        self.checkViewCountAndShowMatches()
                    }
                    self.startTitleLogoAnimation()
                }else{
                    self.showAlertWithOneButton("GoGetter!", "Please check your internet connection.", "OK")
                }
            }
        }, errorHandler: { (error) in
            Loader.stopLoader()
            self.showAlertWithOneButton("GoGetter!", "Please check your internet connection.", "OK")
        })
    }
    
    
//MARK:-  IBAction Methods
    
    @objc func chatController(){
        if isMessageDemoCard {
            self.vwCardSelected = self.vwCardMessage
            self.startAnimationOfCards("message")
            return
        }
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
       let listController = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController")
        navigationController?.pushViewController(listController!, animated: true)
    }
    
    @IBAction func btnBrainGame(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        showAlertWithOneButton("Your Brain Game result indicates you may be left-brained, Right-brained or Balanced brain", "", "Ok")
    }
    
    @IBAction func btnLetsStart(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        LocalStore.store.quizDone = true
        saveSelectedQuestions()
    }
    @IBAction func btnOkayLetsStart(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        
        constraintTopViewTop.constant = -UIScreen.main.bounds.size.height
        constraintTopViewBottom.constant = UIScreen.main.bounds.size.height
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.view.layoutIfNeeded()
        }) { (completed:Bool) in
            //self.imgViewS.tintColor = .darkGray
            self.settingShadowToTopView()
            self.lblActive.alpha = 0
            self.lblActive.layer.backgroundColor = UIColor.black.cgColor
            self.lblFeelingGood.alpha = 0
            self.lblFeelingGood.layer.backgroundColor = UIColor.black.cgColor
            self.viewLblBackground.alpha = 0
            self.viewTopFront.isHidden = true
            self.animateTableView()
        }
    }
    
    @IBAction func btnReminderMeLater(){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        constraintTopViewTop.constant = -UIScreen.main.bounds.size.height
        constraintTopViewBottom.constant = UIScreen.main.bounds.size.height
        self.viewFront.alpha = 0
        self.imgViewBlur.alpha = 0
        self.viewTop.alpha = 0
        self.viewLblBackground.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (completed:Bool) in
            self.view.bringSubviewToFront(self.viewCards)
            self.startSettingIconRotation()
            self.startProfileViewAnimation();
            self.viewTopFront.alpha = 0
        }
    }
    
    @IBAction func btnSharePerson(_ sender: Any){        
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        // text to share
        let text = "Hey, I’m on this new dating app called GoGetter (for active, like-minded singles)  and I came across this person who I thought would be a great match for you! Check it out.  It’s free to start so you’ve got nothing to lose!  Download the app at: \n http://slindir.com/"
        
        // set up activity view controller
        
      //  let objectsToShare:URL = URL(string: "http://slindir.com/")!
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func editPrefernces(){
        self.back()
    }
    
    @IBAction func btnInviteAFriend(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        //https://itunes.apple.com/us/app/slindir-dating-for-active-lifestylers/id1167292687?ls=1&mt=8
        // text to share
        let text = "I’m on this new dating app called GoGetter and there are great people on here. Check it out… \n http://slindir.com/"
        
        // set up activity view controller
        
      //  let objectsToShare:URL = URL(string: "http://slindir.com/")!

        let textToShare = [ text ] 
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func doConvoMatched(){
            let data = UserDefaults.standard.object(forKey:"matchedUser")
            
            if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
                let userOtherDict = requiredData["request_to"] as? [String: Any]
                let userTo = userOtherDict?["user_fb_id"] as! String
                
                var parameters = Dictionary<String, Any>()
                parameters["userId"] = LocalStore.store.getFacebookID();
                parameters["otherUserId"] = userTo;
                
                Loader.startLoader(true)
                
                WebServices.service.webServicePostRequest(.post, .conversation, .doQueryConversationForPurchase, parameters, successHandler: { (response) in
                    Loader.stopLoader()
                    let jsonDict = response
                    
                    if let convoId = jsonDict!["convoId"] as? Int {
                        self.purchaseConvoId = convoId
                        self.purchasePrompt = jsonDict!["prompt"] as? String
                        if self.purchase.count  == 0 {
                            if let _products = jsonDict!["products"] as? [Dictionary<String, Any?>] {
                                for product in _products {
                                    self.purchase.append(PurchaseViewController.PurchaseItem(
                                        Productid: product["id"] as? String,
                                        ProductName: product["productName"] as? String,
                                        Description: product["description"] as? String,
                                        Price: product["price"] as? String,
                                        CoinsPurchased: product["coinsPurchased"] as? String,
                                        AppleStoreID: product["iTunesProductID"] as? String,
                                        GoogleStoreID: product["googleProductID"] as? String)
                                    )
                                }
                            }
                        }
                        
                        if let screenAction = jsonDict!["screenAction"] as? Int {
                            self.purchaseScreenAction = screenAction
                        }
                        
                    } else {
                        Loader.stopLoader()
                        self.outAlertError(message: "Error: Convo Id is null")
                        UserDefaults.standard.set(false, forKey: "matchedNotification")
                    }
                }) { (error) in
                    Loader.stopLoader()
                    self.outAlertError(message: "Error: \(error.debugDescription)")
                    UserDefaults.standard.set(false, forKey: "matchedNotification")
                }
            }
    }
/*    @objc func doConvoQueryToCreate(){
            let data = UserDefaults.standard.object(forKey:"matchedUser")
            
            if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
                let userOtherDict = requiredData["request_to"] as? [String: Any]
                let userTo = userOtherDict?["user_fb_id"] as! String
                
                var parameters = Dictionary<String, Any>()
                parameters["userId"] = LocalStore.store.getFacebookID();
                parameters["otherUserId"] = userTo;
                
                Loader.startLoader(true)
                
                WebServices.service.webServicePostRequest(.post, .conversation, .doQueryConversation, parameters, successHandler: { (response) in
                    Loader.stopLoader()
                    let jsonDict = response
                    
                    if let convoId = jsonDict!["convoId"] as? Int {
                        // we are good convo exists
                    } else {
                        Loader.stopLoader()
                        self.outAlertError(message: "Error: Convo Id is null in doConvoQueryToCreate")
                        UserDefaults.standard.set(false, forKey: "matchedNotification")
                    }
                }) { (error) in
                    Loader.stopLoader()
                    self.outAlertError(message: "Error: \(error.debugDescription)")
                    UserDefaults.standard.set(false, forKey: "matchedNotification")
                }
            }
    }*/

    func DoPurchaseConversation(){
      if self.purchaseScreenAction == PurchasesConst.ScreenAction.BUY_CONVO.rawValue {
           Loader.startLoader(true)
           
           let parameters = [
               "userId": LocalStore.store.getFacebookID(),
               "convoId": self.purchaseConvoId
               ] as [String : Any]
           
           WebServices.service.webServicePostRequest(.post, .conversation, .doPurchaseConversation, parameters, successHandler: { (response) in
               Loader.stopLoader()
               
               let jsonDict = response
               var isSuccess = false
               
               if let convoId = jsonDict!["convoId"] as? Int {
                   let prompt = jsonDict!["prompt"] as? String
                   
                   if let screenAction = jsonDict!["screenAction"] as? Int {
                       isSuccess = true
                       
                       switch screenAction {
                       case PurchasesConst.ScreenAction.WAIT_FOR_MATCH_TO_PAY.rawValue:
                           self.outAlert(title: "Good Choice", message: prompt)
                           CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
                           self.vwMatch.isHidden = true
                           self.view.sendSubviewToBack(self.vwMatch)
                           UserDefaults.standard.set(false, forKey: "matchedNotification")
                           UserDefaults.standard.synchronize()
                           break
                       case PurchasesConst.ScreenAction.READY_TO_CHAT.rawValue:
                           self.openChatList()
                           break
                       default:
                           self.outAlertError(message: prompt ?? "Error")
                       }
                   }
               }
               
               if !isSuccess {
                   self.outAlertError(message: "Error: doPurchaseConversation failed")
               }
           }) { (error) in
               Loader.stopLoader()
               self.outAlertError(message: "Error: \(error.debugDescription)")
           }
       }
      
      /* beleived to be obsolete fhc...
 else if self.purchaseScreenAction == PurchasesConst.ScreenAction.BUY_COINS.rawValue {
           let controller = PurchaseViewController.loadFromNib()
           controller.delegate = self
           controller.products = self.purchase
           controller.prompt = self.purchasePrompt
           controller.convoId = self.purshaseConvoId
           controller.userId = LocalStore.store.getFacebookID()
           self.present(controller, animated: true, completion: nil)
       }*/

    }
//                let controller = ReservePurchaseViewController.loadFromNib()
//                controller.userId = LocalStore.store.getFacebookID()
//                controller.didGoHandler = {userId in
//                    self.purchaseScreenAction = PurchasesConst.ScreenAction.BUY_CONVO.rawValue
//                    self.DoPurchaseConversation();
//                    // get
//                //    self.openChat(userNewId: userId)
//                }f
//                // go screen
//                self.present(controller, animated: true, completion: nil)
//
//    //    fhc        self.outAlertError(message: "conv purchased in test Your good!")
//                CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
//                self.vwMatch.isHidden = true
//                self.view.sendSubviewToBack(self.vwMatch)
//                UserDefaults.standard.set(false, forKey: "matchedNotification")
//                UserDefaults.standard.synchronize()
    
    @IBAction func btnSayHello(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        if self.purchaseScreenAction == PurchasesConst.ScreenAction.BUY_CONVO.rawValue && !LocalStore.store.getCoinFreebie(){
            let controller = ReservePurchaseViewController.loadFromNib()
            controller.oppUserFBId = oppUserFBId
            controller.oppUserName = oppUserName
            controller.oppUserImg = oppUserImg
            controller.purchaseConvoId = self.purchaseConvoId
            controller.didGoHandler = {userId in
                // get
            //    self.openChat(userNewId: userId)
            }
            // go screen
               self.navigationController?.pushViewController(controller, animated: true)
//            self.present(controller, animated: true, completion: nil)

//    fhc        self.outAlertError(message: "conv purchased in test Your good!")
            CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
            self.vwMatch.isHidden = true
            self.view.sendSubviewToBack(self.vwMatch)
            UserDefaults.standard.set(false, forKey: "matchedNotification")
            UserDefaults.standard.synchronize()
        } else if self.purchaseScreenAction == PurchasesConst.ScreenAction.BUY_COINS.rawValue || LocalStore.store.getCoinFreebie(){
            self.dismiss(animated: true, completion:{
                let purchaseViewController = PurchaseViewController.loadFromNib()
                purchaseViewController.delegate = self
                purchaseViewController.products = self.purchase
                purchaseViewController.prompt = self.purchasePrompt
                purchaseViewController.convoId = self.purchaseConvoId
                purchaseViewController.oppUserFBId = self.oppUserFBId
                purchaseViewController.oppUserImg = self.oppUserImg
                purchaseViewController.oppUserName = self.oppUserName
                purchaseViewController.profileDelegate = self.profileDelegate
                purchaseViewController.chatListViewController = nil
                self.navigationController?.pushViewController(purchaseViewController, animated: true)
                self.vwMatch.isHidden = true
                self.view.sendSubviewToBack(self.vwMatch)
                UserDefaults.standard.set(false, forKey: "matchedNotification")
                UserDefaults.standard.synchronize()
            })
        }

//        self.doConvoMatched();
    }
    
    @IBAction func btnMayBeLater(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        self.vwMatch.isHidden = true
        self.view.sendSubviewToBack(self.vwMatch)
        UserDefaults.standard.set(false, forKey: "matchedNotification")
        UserDefaults.standard.synchronize()
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
                self.viewSliderKoloda?.swipe(.left)

            }
            alert.addAction(yes)
            self.present(alert, animated: true, completion: nil)
        }
        actionSheet.addAction(action)
        
        let action1 = UIAlertAction(title: "Report", style: .default) { (action: UIAlertAction) in
            let reportSheet = UIAlertController(title: "Reason of report:", message: nil, preferredStyle: .actionSheet)
            let slindir = UIAlertAction(title: "Not GoGetter Material", style: .default) { (action: UIAlertAction) in
                self.reportUser(reason: "Not GoGetter Material")
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
    
    func reportUser(reason: String) {
        let userId = LocalStore.store.getFacebookID()
        let report_user = self.swipedUserDict["user_fb_id"] as! String
        let parameters = ["user_fb_id": userId , "report_user_fb_id":report_user, "reason":reason, "reporting_to": "slindirapp@gmail.com"]
        print(parameters)
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
        self.viewSliderKoloda?.swipe(.left)
    }
    
    @IBAction func btnOkBrain(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)

        if showBrainGame {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UIView.animate(withDuration: 1, animations: {
                    self.vwBrain?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    self.vwBrain.alpha = 0
                }, completion: { (completed: Bool) in
                    self.view.sendSubviewToBack(self.vwBrain)
                })
            }
        }
    }
    
    @IBAction func learnMore(_ sender: Any) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        showBrainGame = false
        showBrainGameView()
    }
    
    @IBAction func GotItAlert(_ sender: Any) {
        if self.vwCardSelected == self.vwCardRight {
            swipeAction(.right, self.vwCardRight)
            self.vwCardLeft.isUserInteractionEnabled = true
            self.animateSwipeCards(15, 90, self.vwCardLeft, (self.vwCardLeft.leadingLeft)!)
        }
        else if self.vwCardSelected == self.vwCardLeft {
            swipeAction(.left, self.vwCardLeft)
            isMessageDemoCard = true
            self.imgViewS.isUserInteractionEnabled = true
            self.imgViewSetting.isUserInteractionEnabled = false
            self.vwCardMessage.isUserInteractionEnabled = true
            self.animateMessageSwipeCards()
        }
        else if self.vwCardSelected == self.vwCardMessage{
            swipeAction(.left, self.vwCardMessage)
            self.vwCardProfile.isUserInteractionEnabled = true
            self.imgViewS.isUserInteractionEnabled = false
            isMessageDemoCard = false
            self.animateProfileDetailSwipeCards()
        }
        else if self.vwCardSelected == self.vwCardUndo {
            swipeAction(.left, self.vwCardUndo)
            self.imgViewS.isUserInteractionEnabled = true
            self.imgViewSetting.isUserInteractionEnabled = true
        }
        else if self.vwCardSelected == self.vwCardProfile {
            swipeAction(.left, self.vwCardProfile)
            self.vwCardUndo.isUserInteractionEnabled = true
            self.animateUndoImgVwSwipeCards()
        }
        
        self.vwAlert.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.vwAlert.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (completion) in
            UIView.animate(withDuration: 0.2, animations: {
                self.vwAlert.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (completion) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.vwAlert.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }) { (completion) in
                    self.view.sendSubviewToBack(self.vwAlert)
                }
            }
        }
    }
    
    @IBAction func undoAction(_ sender: Any) {
        self.viewSliderKoloda.revertAction()
    }
    
    
    //MARK:-  Message Controller Delegates
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue:
            print("Message Cancelled.")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message Failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message Sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
//MARK:-   Facebook Share Method
//    func showAppInviteDialoge(for appInvite: AppInvite){
//        do{
//            try AppInvite.Dialog.show(from: self, invite: appInvite, completion: { (result) in
//                switch result{
//                case .success(let result):
//                    print("App Invite sent with result \(result)")
//                case .failed(let error):
//                    print("Failed to send invite with error \(error)")
//                }
//            })
//        }catch let error{
//            print("Failed to show app invite dialog with error \(error)")
//        }
//    }
    
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
    
}
//MARK:-  Extensions 
extension ProfileViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        viewInnerSlide.isHidden = false
        self.btnUndoCard.isHidden = false
        koloda.reloadData()
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.4
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        if self.currentViewCount <= 0{
            DispatchQueue.main.async {
                self.outAlert(title: "Sorry!", message: "out of views for today, check back in, in 24 hours", completeHandler : {
                    self.viewInnerSlide.isHidden = false
                    self.btnUndoCard.isHidden = true
                })
            }
            return false
        }
        else{
            return true
        }
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        return true
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .right{
            if let tip = self.cardsArray[index]["tipText"] as? String {
                print(tip)
            }
            else {
                sendOrDeclineRequest(cardsArray[index])
            }
        }
        else {
            if let tip = self.cardsArray[index]["tipText"] as? String {
                print(tip)
            }
            else {
                dislikeUser(cardsArray[index])
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        print("Index :- ",index)
        DispatchQueue.main.async {
            self.cardIndex = index
        }
        self.swipedUserDict = cardsArray[index]
    }

    //MARK:-  Purchase delegates
    
    func didSuccessPurchase(userId: String?) {
/*        switch screenAction {
        case PurchasesConst.ScreenAction.WAIT_FOR_MATCH_TO_PAY.rawValue:
            self.outAlertError(message: prompt ?? "Error")
            break
        case PurchasesConst.ScreenAction.READY_TO_CHAT.rawValue:*/
            let controller = ReservePurchaseViewController.loadFromNib()
            controller.oppUserFBId = userId
            controller.didGoHandler = {userId in
                self.purchaseScreenAction = PurchasesConst.ScreenAction.BUY_CONVO.rawValue
                self.DoPurchaseConversation();
                // get
//                self.openChat(userNewId: userId)
            }
            self.present(controller, animated: true, completion: nil)
/*            break
        default:
            self.outAlertError(message: prompt ?? "Error")
        }*/
    }
    
    private func openChatList(userNewId: String? = nil) {
        self.vwMatch.isHidden = true
        self.view.sendSubviewToBack(self.vwMatch)
        
        let listController = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ChatListViewController
        listController.userNewId = userNewId
        navigationController?.pushViewController(listController, animated: true)
    }
    
//MARK:-  WebServices Methods
    func sendOrDeclineRequest(_ details: [String: Any]){
        let userId = LocalStore.store.getFacebookID()
        let reciver_ID = details["user_fb_id"] as! String
        let parameters = ["user_fb_id": userId , "receiving_user_fb_id":reciver_ID]
//        let parameters = ["user_fb_id": userId , "receiving_user_fb_id":"NVqSplSj9QUQrgcmn4Mdwn3f1ao2"]
//        let parameters = ["user_fb_id": userId , "receiving_user_fb_id":"OEhKFyfFVsW7e7ERYbRSjIpf3oU2"]
        
        // for test load user
//        WebServices.service.webServicePostRequest(.post, .user, .userDetails, ["user_fb_id":parameters["receiving_user_fb_id"]], successHandler: { (response) in
//            let jsonData = response
//            let status = jsonData!["status"] as! String
//            if status == "success"{
//                let userDetails = jsonData!["user_details"] as? Dictionary<String, Any>
//                var requiredData = LocalStore.store.getUserDetails()
//                requiredData["request_to"] = userDetails
//
//                let dictData = NSKeyedArchiver.archivedData(withRootObject: requiredData)
//                UserDefaults.standard.setValue(dictData, forKey: "matchedUser")
//                UserDefaults.standard.set(true, forKey: "matchedNotification")
//                UserDefaults.standard.synchronize()
//                self.matchNotificationRecived()
//            }
//        }, errorHandler: {error in
//            print(error)
//        })
        
        // original
        WebServices.service.webServicePostRequest(.post, .friend, .sendFriendRequest, parameters, successHandler: { (response) in
            DispatchQueue.main.async {
                let jsonDict = response
                let status = jsonDict!["status"] as! String
                if status == "success"{
                    self.currentViewCount = jsonDict!["view_count"] as! Int
                    let requiredData = jsonDict!["requiredData"] as? [String: Any]
                    if requiredData != nil {
               /* fhc         Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                            AnalyticsParameterItemID: "id-Match",
                            AnalyticsParameterItemName: "Match"
                            ])*/
                        let dictData = NSKeyedArchiver.archivedData(withRootObject: requiredData)
                        UserDefaults.standard.setValue(dictData, forKey: "matchedUser")
                        UserDefaults.standard.set(true, forKey: "matchedNotification")
                        UserDefaults.standard.synchronize()
                        self.matchNotificationRecived()
                    }
                    else{
                        if self.currentViewCount <= 0{
                            DispatchQueue.main.async {
                                self.viewInnerSlide.isHidden = false
                                self.btnUndoCard.isHidden = true
                                self.outAlert(title: "Sorry!", message: "out of views for today, check back in, in 24 hours", completeHandler : {
                                    self.viewInnerSlide.isHidden = false
                                    self.btnUndoCard.isHidden = true
                                })
                            }
                        }
                    }
                } else {
                    let message = jsonDict!["message"] as? String
                    self.outAlertError(message: message)
                }
            }
        }) { (error) in
            self.outAlertError(message: error?.localizedDescription)
        }
    }
    
    func dislikeUser(_ details: [String: Any]) {
        let userId = LocalStore.store.getFacebookID()
        let blocked_user = details["user_fb_id"] as! String
        let parameters = ["user_fb_id": userId , "dislike_user_fb_id":blocked_user]
        
        WebServices.service.webServicePostRequest(.post, .dislike, .dislikeUser, parameters, successHandler: { (response) in
            let jsonDict = response
            let status = jsonDict!["status"] as! String
            if status == "success"{
                self.currentViewCount = jsonDict!["view_count"] as! Int
                if self.currentViewCount <= 0{
                    DispatchQueue.main.async {
                        self.viewInnerSlide.isHidden = false
                        self.btnUndoCard.isHidden = true
                        self.outAlert(title: "Sorry!", message: "out of views for today, check back in, in 24 hours", completeHandler : {
                            self.viewInnerSlide.isHidden = false
                            self.btnUndoCard.isHidden = true
                        })
                    }
                }
            }
        }) { (error) in
        }
    }
    //MARK: Demo Card Animations
    @objc func panGestureRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        dragDistance = gestureRecognizer.translation(in: gestureRecognizer.view)
        
        let touchLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        
        switch gestureRecognizer.state {
        case .began:
            
            let firstTouchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            let newAnchorPoint = CGPoint(x: firstTouchPoint.x / (gestureRecognizer.view?.bounds.width)!, y: firstTouchPoint.y / (gestureRecognizer.view?.bounds.height)!)
            let oldPosition = CGPoint(x: (gestureRecognizer.view?.bounds.size.width)! * (gestureRecognizer.view?.layer.anchorPoint.x)!, y: (gestureRecognizer.view?.bounds.size.height)! * (gestureRecognizer.view?.layer.anchorPoint.y)!)
            let newPosition = CGPoint(x: (gestureRecognizer.view?.bounds.size.width)! * newAnchorPoint.x, y: (gestureRecognizer.view?.bounds.size.height)! * newAnchorPoint.y)
            gestureRecognizer.view?.layer.anchorPoint = newAnchorPoint
            gestureRecognizer.view?.layer.position = CGPoint(x: (gestureRecognizer.view?.layer.position.x)! - oldPosition.x + newPosition.x, y: (gestureRecognizer.view?.layer.position.y)! - oldPosition.y + newPosition.y)
            dragBegin = true
            
            animationDirectionY = touchLocation.y >= (gestureRecognizer.view?.frame.size.height)! / 2 ? -1.0 : 1.0
            gestureRecognizer.view?.layer.rasterizationScale = UIScreen.main.scale
            gestureRecognizer.view?.layer.shouldRasterize = true
            
        case .changed:
            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view);
            if gestureRecognizer.view == self.vwCardRight {
                if(velocity.x <= 0) {
                    self.resetViewPositionAndTransformations(self.vwCardRight)
                    return
                }
            }
            else if gestureRecognizer.view == self.vwCardLeft {
                if(velocity.x > 0) {
                    self.resetViewPositionAndTransformations(self.vwCardLeft)
                    return
                }
            }
            let rotationStrength = min(dragDistance.x / (gestureRecognizer.view?.frame.width)!, rotationMax)
            let rotationAngle = animationDirectionY * self.rotationAngle * rotationStrength
            let scaleStrength = 1 - ((1 - scaleMin) * abs(rotationStrength))
            let scale = max(scaleStrength, scaleMin)
            
            var transform = CATransform3DIdentity
            transform = CATransform3DScale(transform, scale, scale, 1)
            transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
            transform = CATransform3DTranslate(transform, dragDistance.x, dragDistance.y, 0)
            gestureRecognizer.view?.layer.transform = transform
            
            
        case .ended:
            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view);
            if gestureRecognizer.view == self.vwCardRight {
                if(velocity.x > 0) {
                    self.vwCardSelected = self.vwCardRight
                    self.startAnimationOfCards("right")
                }
            }
            else if gestureRecognizer.view == self.vwCardMessage {
                self.vwCardSelected = self.vwCardMessage
                self.startAnimationOfCards("message")
            }
            else {
                if(velocity.x <= 0) {
                    self.vwCardSelected = self.vwCardLeft
                    self.startAnimationOfCards("left")
                }
            }
            break
        default:
            break
        }
    }
    
    
    private func swipeAction(_ direction: SwipeResultDirection,_ gestureView: CardsView) {
        let translationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY)
        translationAnimation?.duration = cardSwipeActionAnimationDuration
        translationAnimation?.fromValue = NSValue(cgPoint: POPLayerGetTranslationXY(gestureView.layer))
        if direction == .left {
            translationAnimation?.toValue = NSValue(cgPoint: CGPoint(x:-UIScreen.main.bounds.width, y: 0))
        }
        else {
            translationAnimation?.toValue = NSValue(cgPoint: CGPoint(x:UIScreen.main.bounds.width, y: 0))
        }
        translationAnimation?.completionBlock = { _, _ in
            gestureView.removeFromSuperview()
        }
        gestureView.layer.pop_add(translationAnimation, forKey: "swipeTranslationAnimation")
    }
    
    func resetViewPositionAndTransformations(_ gestureView: CardsView) {
        
        let resetPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
        resetPositionAnimation?.fromValue = NSValue(cgPoint:POPLayerGetTranslationXY(gestureView.layer))
        resetPositionAnimation?.toValue = NSValue(cgPoint: CGPoint.zero)
        resetPositionAnimation?.springBounciness = cardResetAnimationSpringBounciness
        resetPositionAnimation?.springSpeed = cardResetAnimationSpringSpeed
        resetPositionAnimation?.completionBlock = {
            (_, _) in
            gestureView.layer.transform = CATransform3DIdentity
            self.dragBegin = false
        }
        
        gestureView.layer.pop_add(resetPositionAnimation, forKey: "resetPositionAnimation")
        
        let resetRotationAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
        resetRotationAnimation?.fromValue = POPLayerGetRotationZ(gestureView.layer)
        resetRotationAnimation?.toValue = CGFloat(0.0)
        resetRotationAnimation?.duration = cardResetAnimationDuration
        
        gestureView.layer.pop_add(resetRotationAnimation, forKey: "resetRotationAnimation")
        
        let overlayAlphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        overlayAlphaAnimation?.toValue = 0.0
        overlayAlphaAnimation?.duration = cardResetAnimationDuration
        
        let resetScaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        resetScaleAnimation?.toValue = NSValue(cgPoint: CGPoint(x: 1.0, y: 1.0))
        resetScaleAnimation?.duration = cardResetAnimationDuration
        gestureView.layer.pop_add(resetScaleAnimation, forKey: "resetScaleAnimation")
    }
}

extension ProfileViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return cardsArray.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return settingTheView(index)!
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return settingTheView(index) as? OverlayView
    }
    
    func settingTheView(_ index: Int) -> UIView? {
        let personalDetail = LocalStore.store.getUserDetails()
        
        let view = Bundle.main.loadNibNamed("Cards", owner: self, options: nil)![0] as? CardsView
        view?.cardDelegate = self
        view?.imgViewGold.isHidden = true
        let angle = CGFloat(Double.pi/2)
        view?.pageControl.transform = CGAffineTransform(rotationAngle: angle)
        view?.pageControlRight.transform = CGAffineTransform(rotationAngle: angle)
        view?.pageControlMessage.transform = CGAffineTransform(rotationAngle: angle)
        view?.pageControlLeft.transform = CGAffineTransform(rotationAngle: angle)
        view?.pageControlProfileDetail.transform = CGAffineTransform(rotationAngle: angle)
        view?.pageControlUndo.transform = CGAffineTransform(rotationAngle: angle)
        
        if let tip = self.cardsArray[index]["tipText"] as? String {
            view?.lblTip.text = tip
            view?.bringSubviewToFront((view?.vwTip)!)
            view?.imgVwTip.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/0.49))
            return view
        }
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.showImagesInFullView(_:)))
        view?.scrollVw.addGestureRecognizer(tapGesture)
        
        let userDetails = self.cardsArray[index]
        
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
        view?.btnOpenScroll.addTarget(self, action: #selector(self.showBottomView(_:)), for: .touchUpInside)
        if let intrests = userDetails["activities"] as?  String{
            let intrestsArray = intrests.components(separatedBy: ",")
            // print("Intrests :- ",intrestsArray)
            if intrestsArray.count > 0{
                self.activities = intrestsArray
            }
        }
        
        var activitiesArray = [String]()
        
        if let activitiesString = personalDetail["activities"] as? String{
            let activities = activitiesString.components(separatedBy: ",")
            activitiesArray = activities
        }
        
        let btns = [view?.btnInterestOne,view?.btnInterestTwo,view?.btnInterestThree,view?.btnInterestFour]
        for (index,activity) in self.activities.enumerated(){
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
        
        return view
    }
    
    func startAnimationOfCards(_ animation: String) {
        if animation == "right" {
            self.lblAlert.text = "Like what you see? Swiping a profile to the right means you'd like to connect!"
        }
        else if animation == "message" {
            self.lblAlert.text = "Tap the GoGetter icon to access your messages."
            self.imgViewS.isUserInteractionEnabled = true
        }
        else if animation == "left" {
            self.lblAlert.text = "Not feeling it? Swiping a profile to the left means you are not interested."
        }
        else if animation == "profile" {
             self.lblAlert.text = "Want to know more? Tap here to learn more about them."
        }
        else if animation == "undo" {
                self.lblAlert.text = "Accidentally swipe the wrong way? Undo here to make the right move."
        }
        
        self.view.bringSubviewToFront(self.vwAlert)
        self.vwAlert.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(withDuration: 0.5, animations: {
            self.vwAlert.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (completion) in
            UIView.animate(withDuration: 0.2, animations: {
                self.vwAlert.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { (completion) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.vwAlert.transform = CGAffineTransform(scaleX: 1, y: 1)
                }) { (completion) in
                    
                }
            }
        }
        
    }
    
    func updateTheDetails(_ details:[String: Any]){
        if (details["tipText"] as? String) != nil {
            return
        }
 
        //fhc       let personalDetail = LocalStore.store.getUserDetails()
       
        let name = details["user_name"] as! String
        let age = String(format:"%d", self.calculateAge(birthday: details["dob"] as! String))

        lblNameScroll.text = String(format: "%@, %@", name,age)

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
        
        videoUrl = "";
        self.imgVwVideoThumb.image = UIImage()
        let thumbView = self.imgVwVideoThumb;
        if let detail = details["profile_video"] as? String {
            if detail == "" {
                let noVideoURl = "novideoloadedGG.png"
                thumbView!.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl,noVideoURl)), placeholderImage: nil,options: .refreshCached,
                                       completed: { (img, err, cacheType, imgURL) in
                                        print("complete");
                                        print(err.debugDescription);
                                        
                })
            }
            else {
                videoUrl = String(format:"%@%@", mediaUrl, detail)
                // self.perform(#selector(self.thumbnailFromVideoServerURL(url:)), with: URL(string:self.videoUrl)!, afterDelay: 0.1)
                let profileThumb = (details["profile_thumbnail"] as? String)!;
                thumbView!.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl,profileThumb)), placeholderImage: nil,options: .refreshCached,
                        completed: { (img, err, cacheType, imgURL) in
                            print("complete");
                            print(err.debugDescription);
                            
                })
                
            }
        }
        else {
            
        }
       
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
           // if let brain = details["brain"] as? String {
            //    if let brainGame = personalDetail["brain"] as? String{
              //      if brain != brainGame {
                        self.heightPersonalityView.constant = 100
                        self.vwPersonality.isHidden = false
                        self.lineBelowPersonality.isHidden = false
                        self.view.layoutIfNeeded()
                   // }
                   // else {
                    //    self.vwPersonality.isHidden = true
                     //   self.lineBelowPersonality.isHidden = true
                     //   self.heightPersonalityView.constant = 0
                     //   self.view.layoutIfNeeded()
              //      }
             //   }
            //}
            
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
            let myGender = details["gender"] as? String
            
            if (kidArray.indices.contains(1)) {
                if kidArray[1] == "want" {
                    self.imgViewWantKidsScroll.image = #imageLiteral(resourceName: "checkLogo")
                }
                else if kidArray[1] == "no"{
                    self.imgViewWantKidsScroll.image = #imageLiteral(resourceName: "xLogo")
                }
                else {
                    self.imgViewWantKidsScroll.image = (myGender ?? "M") == "M" ? #imageLiteral(resourceName: "mshrug") : #imageLiteral(resourceName: "wshrug")
                }
            } else {
                self.imgViewWantKidsScroll.image = (myGender ?? "M") == "M" ? #imageLiteral(resourceName: "mshrug") : #imageLiteral(resourceName: "wshrug")
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
        
        self.scrollVwFullImage.contentOffset = CGPoint(x: 0, y: self.scrollVwFullImage.frame.size.height * CGFloat(index))
        self.scrollVwFullImage.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: self.scrollVwFullImage.frame.size.height * CGFloat(count))
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
    
    func animateSwipeCards(_ minimum: CGFloat, _ maximum: CGFloat, _ vwCard: CardsView, _ constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 1, animations: {
            constraint.constant = minimum
            vwCard.layoutIfNeeded()
        }, completion: { (completion) in
            UIView.animate(withDuration: 1, animations: {
                constraint.constant = maximum - 40
                vwCard.layoutIfNeeded()
            }, completion: { (completion) in
                UIView.animate(withDuration: 1, animations: {
                    constraint.constant = minimum
                    vwCard.layoutIfNeeded()
                }, completion: { (completion) in
                    UIView.animate(withDuration: 1, animations: {
                        constraint.constant = maximum
                        vwCard.layoutIfNeeded()
                    }, completion: { (completion) in
                        UIView.animate(withDuration: 1, animations: {
                            constraint.constant = minimum
                            vwCard.layoutIfNeeded()
                        }, completion: { (completion) in
                            UIView.animate(withDuration: 1, animations: {
                                constraint.constant = maximum
                                vwCard.layoutIfNeeded()
                            }, completion: { (completion) in
                                UIView.animate(withDuration: 1, animations: {
                                    constraint.constant = minimum
                                    vwCard.layoutIfNeeded()
                                }, completion: { (completion) in
                                    UIView.animate(withDuration: 1, animations: {
                                        constraint.constant = maximum
                                        vwCard.layoutIfNeeded()
                                    }, completion: { (completion) in
                                        UIView.animate(withDuration: 1, animations: {
                                            constraint.constant = minimum
                                            vwCard.layoutIfNeeded()
                                        }, completion: { (completion) in
                                            UIView.animate(withDuration: 1, animations: {
                                                constraint.constant = maximum
                                                vwCard.layoutIfNeeded()
                                            }, completion: { (completion) in
                                                UIView.animate(withDuration: 1, animations: {
                                                    constraint.constant = minimum
                                                    self.view.layoutIfNeeded()
                                                }, completion: { (completion) in
                                                    ClientLog.WriteClientLog( msgType: "feelgood", msg:"anim swiped cards complete");

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
    
    func animateMessageSwipeCards() {
        self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed: Bool) in
            self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed: Bool) in
                self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed: Bool) in
                    self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed: Bool) in
                        self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed:Bool) in
                            self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed: Bool) in
                                self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed: Bool) in
                                    self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed: Bool) in
                                        self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed:Bool) in
                                            self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed:Bool) in
                                                self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed:Bool) in
                                                    self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed:Bool) in
                                                        self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed:Bool) in
                                                            self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed:Bool) in
                                                                self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed:Bool) in
                                                                    self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed:Bool) in
                                                                        self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed:Bool) in
                                                                            self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed:Bool) in
                                                                                self.vwCardMessage.imgVwMessage.rotate(-55, 0.5, finished: { (completed:Bool) in
                                                                                    self.vwCardMessage.imgVwMessage.rotate(-35, 0.5, finished: { (completed:Bool) in
                                                                                        self.vwCardMessage.imgVwMessage.rotate(-45, 0.5, finished: { (completed:Bool) in
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
                            })
                        })
                    })
                })
            })
        })
    }
    
    func animateProfileDetailSwipeCards() {
        self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed: Bool) in
            self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed: Bool) in
                self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed: Bool) in
                    self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed: Bool) in
                        self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed:Bool) in
                            self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed: Bool) in
                                self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed: Bool) in
                                    self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed: Bool) in
                                        self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed:Bool) in
                                            self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed:Bool) in
                                                self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed:Bool) in
                                                    self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed:Bool) in
                                                        self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed:Bool) in
                                                            self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed:Bool) in
                                                                self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed:Bool) in
                                                                    self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed:Bool) in
                                                                        self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed:Bool) in
                                                                            self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed:Bool) in
                                                                                self.vwCardProfile.imgVwProfile.rotate(80, 0.5, finished: { (completed:Bool) in
                                                                                    self.vwCardProfile.imgVwProfile.rotate(60, 0.5, finished: { (completed:Bool) in
                                                                                        self.vwCardProfile.imgVwProfile.rotate(70, 0.5, finished: { (completed:Bool) in
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
                            })
                        })
                    })
                })
            })
        })
    }
    
    func animateUndoImgVwSwipeCards() {
        self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed: Bool) in
            self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed: Bool) in
                self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed: Bool) in
                    self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed: Bool) in
                        self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed:Bool) in
                            self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed: Bool) in
                                self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed: Bool) in
                                    self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed: Bool) in
                                        self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed:Bool) in
                                            self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed:Bool) in
                                                self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed:Bool) in
                                                    self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed:Bool) in
                                                        self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed:Bool) in
                                                            self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed:Bool) in
                                                                self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed:Bool) in
                                                                    self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed:Bool) in
                                                                        self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed:Bool) in
                                                                            self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed:Bool) in
                                                                                self.vwCardUndo.imgVwUndo.rotate(-80, 0.5, finished: { (completed:Bool) in
                                                                                    self.vwCardUndo.imgVwUndo.rotate(-60, 0.5, finished: { (completed:Bool) in
                                                                                        self.vwCardUndo.imgVwUndo.rotate(-70, 0.5, finished: { (completed:Bool) in
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
                            })
                        })
                    })
                })
            })
        })
    }
}

class QuestionTableViewCell: UITableViewCell {
    @IBOutlet weak var imgViewQuestion: UIImageView!
}

class TeamCell: UITableViewCell{
    @IBOutlet weak var lblTeam: UILabel!
}			
