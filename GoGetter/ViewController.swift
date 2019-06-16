//
//  ViewController.swift
//  GoGetter
//
//  Created by Batth on 11/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//


//,friendlists{id,list_type,name},

import UIKit
import SwiftyGif
import AVFoundation
import AVKit
import MediaPlayer
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class ViewController: UIViewController {

    
//MARK:-  IBOutlets , Variables and Constants
    
    @IBOutlet weak var imgViewTitle: UIImageView!
    @IBOutlet weak var imgViewS: UIImageView!
    @IBOutlet weak var imgViewTitleWhite: UIImageView!
    @IBOutlet weak var imgViewTitleBlack: UIImageView!
    @IBOutlet weak var imgViewBackground: UIImageView!
    @IBOutlet weak var imgViewGreen: UIImageView!
    @IBOutlet weak var imgViewWelcome: UIImageView!
    @IBOutlet weak var imgViewMoreGifs: UIImageView!
    @IBOutlet weak var imgViewCircleGif: UIImageView!
    @IBOutlet weak var imgViewIcons: UIImageView!
    
    @IBOutlet weak var viewFade: UIView!

    @IBOutlet weak var viewPlayer: UIView?

    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var constrantSX: NSLayoutConstraint!
    
    @IBOutlet weak var constraintIconCenter: NSLayoutConstraint!

    @IBOutlet weak var constraintGreenBackTop: NSLayoutConstraint!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnPhoneNumber: CustomButton!
    
    let mask = CAGradientLayer()

    let playerController = AVPlayerViewController()
    
    var timer: Timer!
    var fbBtnTimer: Timer!
    var moreImagesTimer: Timer!
    
    var arrayIconImages = [UIImage]()
    var gifImages = [String]()
    
    var imageCount:Int = 0
    var moreGifCount: Int = 0
    
    @IBOutlet weak var vwDemo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
//Animate Title
        gifImages = ["ForActiveSmall.gif","PersonalityTypeMatching.gif","browser.gif"]
        animateTitle()
        btnFacebook.alpha = 0
        btnPhoneNumber.alpha = 0
        imgViewCircleGif.alpha = 0
        imgViewIcons.alpha = 0
        addingImagesInArray()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerController.player?.play()
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.currentController = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnFacebook.layer.cornerRadius = btnFacebook.frame.size.height/2
        btnPhoneNumber.layer.cornerRadius = btnPhoneNumber.frame.size.height/2
        mask.frame = viewFade.bounds
        if playerController.player?.status == AVPlayer.Status.readyToPlay {
            playerController.player?.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
//MARK:-  Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    
//MARK:-  Notifications
    
    @objc func playerItemDidReachEnd(_ notification: Notification){
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: CMTime.zero)
    }
    
//MARK:-  Local Methods
    
    func addingImagesInArray(){
        
        arrayIconImages = [#imageLiteral(resourceName: "moutainCycling"),#imageLiteral(resourceName: "waterBasketball"),#imageLiteral(resourceName: "tennis"),#imageLiteral(resourceName: "underWater"),#imageLiteral(resourceName: "basketBall"),#imageLiteral(resourceName: "swimming"),#imageLiteral(resourceName: "waterSketing"),#imageLiteral(resourceName: "sketing"),#imageLiteral(resourceName: "running"),#imageLiteral(resourceName: "tracking"),#imageLiteral(resourceName: "boating"),#imageLiteral(resourceName: "rafting"),#imageLiteral(resourceName: "moutainClimb"),#imageLiteral(resourceName: "cycling"),#imageLiteral(resourceName: "iceHockey"),#imageLiteral(resourceName: "footBall"),#imageLiteral(resourceName: "weightLifting"),#imageLiteral(resourceName: "sward"),#imageLiteral(resourceName: "wrestling"),#imageLiteral(resourceName: "golf"),#imageLiteral(resourceName: "boxing"),#imageLiteral(resourceName: "yoga"),#imageLiteral(resourceName: "iceSketing"),#imageLiteral(resourceName: "baseBall"),#imageLiteral(resourceName: "horsing")]
    }
    
    func animateTitle(){
//        imgViewS.isHidden = true
        imgViewTitle.isHidden = true
        viewFade.isHidden = true

//        imgViewS.alpha = 0
        imgViewTitle.alpha = 0
        
        imgViewTitleWhite.alpha = 0
        imgViewTitleBlack.alpha = 0
        
        imgViewWelcome.alpha = 0
  //      constrantSX.constant = -UIScreen.main.bounds.width/2 - 10
        constraintGreenBackTop.constant = UIScreen.main.bounds.height
      
        mask.frame = viewFade.bounds
        mask.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        mask.startPoint = CGPoint(x: 0, y: 1)
        mask.endPoint = CGPoint(x: 1, y: 1)
        viewFade.layer.mask = mask
        fadeIn()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.5, animations: {
                //self.imgViewS.alpha = 1
       	         self.imgViewTitleWhite.alpha = 1
            }, completion: { (completed: Bool) in
   //             self.constrantSX.constant = -15
                self.fadeOut()

                UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear, animations: {
//                    self.imgViewTitle.alpha = 1
                    self.imgViewTitleBlack.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) in
                    self.greenBackGround()
                })
            })
        }
    }
    
    func greenBackGround(){
        constraintGreenBackTop.constant = 0
        UIView.animate(withDuration: 0.5, animations: { 
            self.view.layoutIfNeeded()

        }) { (completed: Bool) in
            UIView.animate(withDuration: 1, animations: {
                self.view.layoutIfNeeded()
                self.blurView.alpha = 1
            }, completion: { (completed:Bool) in
                self.playVideo()
            })
        }
    }
    
//MARK:-  Video Methods
    func playVideo() {
        addWelcomeGifImage(false)
        self.playCircularIcon()
        var videoUrl = Bundle.main.url(forResource: "SlindirIntro", withExtension: "mp4")
        
        if UIScreen.main.bounds.size.height >= 812 {
            videoUrl = Bundle.main.url(forResource: "SlindirIntro_iPhoneX", withExtension: "mp4")
            self.playerController.view.frame = CGRect(x:-20, y:-20, width: UIScreen.main.bounds.size.width + 40, height: UIScreen.main.bounds.size.height + 40)
        }
        else {
            self.playerController.view.frame = self.view.frame
        }
        let player = AVPlayer(url: videoUrl!)
        self.playerController.player = player
        self.playerController.showsPlaybackControls = false
        player.actionAtItemEnd = .none
        player.play()
        self.addChild(self.playerController)
        self.viewPlayer?.addSubview(self.playerController.view)
         //
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_ :)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.blurView.alpha = 0
            self.imgViewBackground.alpha = 0
        }) { (completed: Bool) in
            
        }
    }
    
    
//MARK:-  Gif Functions
    func addWelcomeGifImage(_ isFinal: Bool){
        
        imgViewWelcome.alpha = 0
        imgViewMoreGifs.alpha = 1

        let gifManager = SwiftyGifManager(memoryLimit: 0)
        let gif = UIImage(gifName: "ForActiveSmall.gif")//welcome.gif
       // imgViewWelcome.setGifImage(gif, manager: gifManager, loopCount:1)
        imgViewMoreGifs.setGifImage(gif, manager: gifManager, loopCount: 1)

        
        if isFinal {
            imgViewMoreGifs.delegate = nil
        }else{
            imgViewMoreGifs.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.showFbButton()
            })
            
        }
    }
    func moreGifFiles(_ imageNo: Int){
        imgViewMoreGifs.alpha = 1
        
        let gifManager = SwiftyGifManager(memoryLimit: 10)
        let gif = UIImage(gifName: gifImages[imageNo])
        imgViewMoreGifs.setGifImage(gif, manager: gifManager, loopCount: 1)
        imgViewMoreGifs.delegate = self

    }
    
    func playCircularIcon(){
        let gifManager = SwiftyGifManager(memoryLimit: 10)
        let gif = UIImage(gifName: "circle.gif")
        imgViewCircleGif.setGifImage(gif, manager: gifManager)
        imgViewCircleGif.delegate = self
        self.imgViewIcons.image = arrayIconImages[imageCount]
        UIView.animate(withDuration: 2, animations: {
            self.imgViewCircleGif.alpha = 1
            self.imgViewIcons.alpha = 1
        }) { (completed: Bool) in
            
        }
    }
    
//MARK:-  Animation Functions
    private func locations(a: Float, b: Float, c: Float, d: Float) -> [Any] {
        return [Float(a), Float(b), Float(c), Float(d)]
    }
    
    func fadeIn() {
        CATransaction.begin()
        CATransaction.setValue(Double(10.0), forKey: kCATransactionAnimationDuration)
        (viewFade.layer.mask as? CAGradientLayer)?.locations = locations(a: 0, b: 0, c: 0.15, d: 0) as? [NSNumber]
        CATransaction.commit()
    }
    
    func fadeOut() {
        CATransaction.begin()
        CATransaction.setValue(Double(0.8), forKey: kCATransactionAnimationDuration)
        let timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        CATransaction.setAnimationTimingFunction(timingFunction)
        (viewFade.layer.mask as? CAGradientLayer)?.locations = locations(a: 1, b: 1, c: 1, d: 1) as? [NSNumber]
        CATransaction.commit()
    }
    
    @objc func showDemoView() {
        self.view.bringSubviewToFront(self.vwDemo)
    }
    
//MARK:-  IBAction Methods
    @IBAction func btnLoginWithFB(_ sender: Any?){
        UserDefaults.standard.set(true, forKey: "UpdateImages")
        UserDefaults.standard.synchronize()

        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        
        self.playerController.player?.pause()
        
        let loginManager = LoginManager()
        loginManager.logOut()
        let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.showDemoView), userInfo: nil, repeats: false)
        
        //ClientLog.WriteClientLog( msgType: "iosfb", msg:"btnLoginFB start");
      //  loginManager.loginBehavior = .web;
        
        loginManager.logIn(permissions: ["public_profile","email","user_birthday","user_photos", "user_gender","user_age_range"], from: self) { (loginResults, error) in
            let fbloginresult : LoginManagerLoginResult = loginResults!
            if (loginResults?.isCancelled)!{
//                ClientLog.WriteClientLog( msgType: "iosfb", msg:"logincancelled");
                timer.invalidate()
                self.view.sendSubviewToBack(self.vwDemo)
                return
            }
            if(fbloginresult.grantedPermissions.contains("email")) {
                timer.invalidate()
//                ClientLog.WriteClientLog( msgType: "iosfb", msg:"emailgranted");
                self.view.sendSubviewToBack(self.vwDemo)
//                print("token Permission:- \(accessToken.authenticationToken)")
//                print("Access Token :- ",FBSDKAccessToken.current().tokenString)
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                
                let welcomeController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                welcomeController.accesToken = AccessToken.current
                welcomeController.credential = credential
                welcomeController.fbLoginType = 0

//                ClientLog.WriteClientLog( msgType: "iosfb", msg:"towelcome");
                self.navigationController?.pushViewController(welcomeController, animated: false)
            }
            else{
//                ClientLog.WriteClientLog( msgType: "iosfb", msg:"emailNOTgranted");
            }
           
        }
    }
    
    @IBAction func btnLoginWithPhoneNumber(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "UpdateImages")
        UserDefaults.standard.synchronize()
        if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            self.navigationController?.pushViewController(newViewController, animated: false)
//            self.present(newViewController, animated: true, completion: nil)
//            UIApplication.shared.keyWindow?.rootViewController = newViewController
        }
    }
    
    @IBAction func BtnTermsAndConditions(_ sender: Any) {
        UIApplication.shared.open((URL(string: "http://slindir.com/terms-of-use/")!), options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
}


//MARK:-  Gif Image Delegates
extension ViewController : SwiftyGifDelegate {
    
    func gifDidStart(sender: UIImageView) {
    }
    
    func gifDidLoop(sender: UIImageView) {
        if sender == imgViewCircleGif{
            imgViewIcons.image = arrayIconImages[imageCount]
            changeIconPhoto()
            return
        }
        
        if sender == imgViewMoreGifs {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.moreImagesTimer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(self.rewindMoreImages), userInfo: nil, repeats: true)
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             self.timer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(self.rewind), userInfo: nil, repeats: true)
        }
    }
   
//MARK:-  Reverse The Animations of Gif Images
    @objc func rewind(){
        self.imgViewWelcome.showFrameForIndexDelta(-1)
        if self.imgViewWelcome.currentFrameIndex() <= 0{
            stopTimer()
        }
    }
    
    @objc func rewindMoreImages(){
        self.imgViewMoreGifs.showFrameForIndexDelta(-1)
        if self.imgViewMoreGifs.currentFrameIndex() <= 0{
            stopGifImage()
        }
    }
//MARK:-  Stop the Gif Images and Timers
    func stopGifImage(){
        self.moreImagesTimer.invalidate()
        self.moreImagesTimer = nil
        if moreGifCount >= gifImages.count - 1{
//            UIView.animate(withDuration: 0.2, animations: {
//              self.imgViewMoreGifs.alpha = 0
//            })
//            return
            moreGifCount = 0
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.moreGifFiles(self.moreGifCount)
            })
        }else{
            moreGifCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.moreGifFiles(self.moreGifCount)
            })
        }
        UIView.animate(withDuration: 1) { 
            self.imgViewMoreGifs.alpha = 0
        }

    }

    func stopTimer(){
        timer?.invalidate()
        timer = nil
        self.imgViewWelcome.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
            self.moreGifFiles(self.moreGifCount)
            self.playCircularIcon()
        }
    }
    
//MARK:-  FB Button Animations
    func showFbButton(){
        
        self.btnFacebook.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.btnPhoneNumber.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 1, animations: {
            self.btnFacebook.transform = CGAffineTransform.identity
            self.btnFacebook.alpha = 1
            
            self.btnPhoneNumber.transform = CGAffineTransform.identity
            self.btnPhoneNumber.alpha = 1
        }) { (completed: Bool) in
            self.fbBtnTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.fbBtnAnimation), userInfo: nil, repeats: true)
        }
    }
    
    @objc func fbBtnAnimation(){
        UIView.animate(withDuration: 0.3, animations: {
            self.btnFacebook.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//            self.btnPhoneNumber.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (completed: Bool) in
            UIView.animate(withDuration: 0.3, animations: {
                self.btnFacebook.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//                self.btnPhoneNumber.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { (completed: Bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.btnFacebook.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//                    self.btnPhoneNumber.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }) { (completed: Bool) in
                    UIView.animate(withDuration: 0.3, animations: {
                        self.btnFacebook.transform = .identity
//                        self.btnPhoneNumber.transform = .identity
                    }, completion: { (completed: Bool) in
                    })
                }
            })
        }
    }
  
    
//MARK:-  Circle Animations
    
    func changeIconPhoto(){
        constraintIconCenter.constant = -5
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (completed: Bool) in
            self.constraintIconCenter.constant = 100
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
                self.imgViewIcons.alpha = 0
            }, completion: { (completed:Bool) in
                self.imgViewIcons.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.constraintIconCenter.constant = 0
                self.imgViewIcons.alpha = 0
                if self.imageCount == self.arrayIconImages.count - 1{
                    self.imgViewCircleGif.stopAnimatingGif()
                    self.imgViewCircleGif.alpha = 0
                    self.addWelcomeGifImage(true)
                    return
                }else{
                    self.imageCount += 1
                    self.imgViewIcons.image = self.arrayIconImages[self.imageCount]
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.imgViewIcons.transform = .identity
                    self.imgViewIcons.alpha = 1
                }, completion: { (completed: Bool) in
                    
                })
            })
        }
    }
    
    func gifDidStop(sender: UIImageView) {
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
