//
//  Extension.swift
//  Slindir
//
//  Created by Batth on 14/09/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import AVFoundation
import Firebase

//MARK:-  UIImageView Extension
let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWithURLString(_ photoURL: String, successHandler success:@escaping (_ image: UIImage?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        if let cacheImage = imageCache.object(forKey: photoURL as AnyObject) as? UIImage {
            success(cacheImage)
        }
        else {
           
            storageRef.getData(maxSize: INT64_MAX) { (data, error) in
                if error != nil{
                  //  self.showAlertWithOneButton("Error!", err.localizedDescription, "OK")
                }else{
                    storageRef.getMetadata(completion: { (metaData, metaDataErr) in
                        if error != nil{
                        }else{
                            if metaData?.contentType == "image/gif"{
                                imageCache.setObject(UIImage(gifData: data!), forKey: photoURL as AnyObject)
                                success(UIImage(gifData: data!))
                            }else{
                                imageCache.setObject(UIImage(data: data!)!, forKey: photoURL as AnyObject)
                                success(UIImage(data: data!))
                                
                            }
                        }
                    })
                }
            }
        }
    }
}

//MARK:-  UILabel Extension

extension UILabel{
    func animate(newText: String, characterDelay: TimeInterval,completed:@escaping (_ : Bool) -> Void){
        DispatchQueue.main.async {
            self.text = ""
            for (index, character) in newText.enumerated(){
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index), execute: {
                    self.text?.append(character)
                    if index == newText.count - 1{
                        completed(true)
                    }
                })
            }
        }
    }
}

//MARK:-  UITextField Extension
extension UITextField{
    
    func animate(newText: String,characterDelay:TimeInterval,completed:@escaping (_ : Bool) -> Void){
        DispatchQueue.main.async {
            self.text = ""
        }
        for (index,character) in newText.enumerated()
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index), execute: {
                self.text?.append(character)
                if index == newText.count - 1{
                    completed(true)
                }
            })
        }
    }
}

extension UIButton{
    
    func shadowButton(_ opacity: Float, _ radius: CGFloat, _ color: UIColor, _ size: CGSize){
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = size
    }
    
}
//MARK:-  UIView Extension
extension UIView{
    
    func shadow(_ opacity: Float, _ radius: CGFloat, _ color: UIColor, _ size: CGSize){
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = size
    }
    
    func rotate(_ r: CGFloat, _ duration: TimeInterval, finished:@escaping (_ finish:Bool) -> ()){
        UIView.animate(withDuration: duration, animations: {
            let rotationTransform = CGAffineTransform.identity
            self.transform = rotationTransform.rotated(by: self.degreesToRadians(degrees: r))
        }) { (completed: Bool) in
            if completed{
                finished(completed)
            }
        }
    }
    
    func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * .pi / 180
    }
}
//MARK:-  UIViewController Extension
extension UIViewController{
    
    //Custom Alert Controller Methods
    func showAlertWithOneButton(_ title: String?, _ message: String?, _ buttonTitle:String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { (action: UIAlertAction) in
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithCustomButtons(_ title: String?,_ message: String?, _ actions: UIAlertAction ...){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions{
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func action(_ title: String?,_ style: UIAlertAction.Style, actionHandler actionClick:@escaping (_ action: UIAlertAction) -> Void) -> UIAlertAction{
        
        let alertAction = UIAlertAction(title: title, style: style) { (action) in
            actionClick(action)
        }
        return alertAction
    }
    // Common method used in many classes so we define here
    func getUserDetails(_ isFirstTime: Bool){
        let facebookUserId = LocalStore.store.getFacebookID()
        var parameters = Dictionary<String, Any>()
        parameters["user_fb_id"] = facebookUserId
        
        WebServices.service.webServicePostRequest(.post, .user, .userDetails, parameters, successHandler: { (response) in
            let jsonData = response
            let status = jsonData!["status"] as! String
            if status == "success"{
                
                let userDetails = jsonData!["user_details"] as? Dictionary<String, Any>
                
                if let profile_video = userDetails!["profile_video"] as? String {
                    if profile_video != ""{
                        self.writeVideo(profile_video)
                    }
                }
                
                let dictData = NSKeyedArchiver.archivedData(withRootObject: userDetails!)
                LocalStore.store.saveUserDetails = dictData
                self.loadProfileImagesInCache(userDetails!)
               
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateLocation"), object: nil, userInfo: nil)
                
                let details = LocalStore.store.getUserDetails()
                if isFirstTime {
                    if let name = details["user_name"] as? String, let id = details["user_fb_id"] as? String, let dob = details["dob"] as? String, let gender = details["gender"] as? String{
                        let friendRef: DatabaseReference = Database.database().reference().child("users")
                        friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            print("Snap Shot :- ",snapshot.hasChildren())
                            let childern = snapshot.children
                            print("Childen :- ",childern)
                            for child in childern{
                                print("Child :- ",child)
                                let newChild = child as! DataSnapshot
                                if let checkID = newChild.value as? [String: Any]{
                                    if let idNew = checkID["id"] as? String{
                                        if idNew == id {
                                            return
                                        }
                                    }
                                }
                            }
                            let newFriendRef = friendRef.child(id)
                            let friendItem = [
                                "name": name,
                                "id":id,
                                "dob":dob,
                                "gender":gender
                                ] as [String : Any]
                            newFriendRef.setValue(friendItem)
                        })
                    }
                }
                else {
                    if let detail =  userDetails!["profile_pic"] as? String {
                            let friendArray = FirebaseObserver.observer.friendArray
                            var count = 0
                            if count < friendArray.count {
                                let firstObject = friendArray[count]
                                count = count + 1
                                if let idFirst = firstObject["id"] as? String {
                                    let myConnectionsRef = Database.database().reference(withPath: String(format:"users/%@/friends/\(userDetails!["user_fb_id"] ?? "")",idFirst))
                                    let con = myConnectionsRef.child("profilePic")
                                    con.setValue(detail)                                    
                                }                                
                        }
                    }
                    /* jasvir changes  */
 
                     if let detail = details["profile_video"] as? String {
                     if detail == "" {
                     self.deleteOldVideoFromDocumentDirectory()
                     }
                     }
                     else {
                     self.deleteOldVideoFromDocumentDirectory()
                     }
 
                    /* end jasvir changes */
                    

                }
            }else{
                if jsonData!["message"] as? String == "No Associated Facebook ID Found!" {
                    if self.navigationController?.viewControllers.count == 1  {
                        let controller = self.navigationController?.viewControllers[0]
                        if (controller?.isKind(of: ViewController.self))! {
                            return
                        }
                    }
                   // LoginManager().logOut()
                    LocalStore.store.clearDataAllData()
                    FirebaseObserver.observer.firstLoad = false
                    self.deleteOldVideoFromDocumentDirectory()
                    let loginController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    self.navigationController?.setViewControllers([loginController], animated: true)
                }
            }
        }, errorHandler: { (error) in
        })
    }
    
    //MARK:-  Document Directory Video
    
    func deleteOldVideoFromDocumentDirectory() {
        UserDefaults.standard.set(nil, forKey: "videoURL")
        UserDefaults.standard.synchronize()
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent("video.mov")
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
            }
            catch {
                
            }
        }
    }
    
    func writeVideo(_ urlStr: String) {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent("video.mov")
        if FileManager.default.fileExists(atPath: imageURL.path) {
            let asset = AVURLAsset.init(url: imageURL)
            if !asset.isPlayable {
                do {
                    try FileManager.default.removeItem(at: imageURL)
                }
                catch {
                    
                }
            }
            else {
                if  UserDefaults.standard.url(forKey: "videoURL") != imageURL{
                    UserDefaults.standard.set(imageURL, forKey: "videoURL")
                    UserDefaults.standard.synchronize()
                }
                return
            }
        }
        
        let urlRequest = URLRequest.init(url: URL(string:String(format:"%@%@", mediaUrl, urlStr))!)
        let urlSessionConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        let urlSessionData = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil{
                DispatchQueue.main.async {
                    do {
                        try data?.write(to: imageURL, options: .atomic)
                        UserDefaults.standard.set(imageURL, forKey: "videoURL")
                        UserDefaults.standard.synchronize()
                    }
                    catch {
                        
                    }
                }
            }
        }
        urlSessionData.resume()
    }
    
    func loadProfileImagesInCache(_ personalDetail:[String: Any]) {
        let imgVwDummy = UIImageView()
        for i in 0..<6 {
            if i == 0 {
                if let detail =  personalDetail["profile_pic"] as? String {
                    if detail != "" {
                        imgVwDummy.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, detail)), placeholderImage: UIImage.init(named: "placeholder"))
                    }
                }
            }
            else {
                if let detail =  personalDetail[String(format:"image%d",i)] as? String {
                    if detail != "" {
                        imgVwDummy.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, detail)), placeholderImage: UIImage.init(named: "placeholder"))
                    }
                }
            }
        }
    }
    
    func currentTime() -> String{
        let format = DateFormatter()
        print("Date :-",Date().self)
        format.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        format.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone        
        format.locale = Locale.init(identifier: "en_US_POSIX")
        let dateString = format.string(from: Date())
        return dateString//Date().timeIntervalSince1970
    }
    
    func stringToSeconds(_ time: String) -> Double{
        let format = DateFormatter()
        print("Date String :-",time)
        format.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        format.locale = Locale.init(identifier: "en_US_POSIX")
        if let date = format.date(from: time) {
            return date.timeIntervalSince1970
        }
        else {
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = format.date(from: time)
            return date!.timeIntervalSince1970
        }
    }
    
    func thumbnailForVideoASSet(asset: AVURLAsset) -> UIImage? {
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do {
            let maxSize = CGSize(width: 512, height: 512);
            imgGenerator.maximumSize = maxSize;
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            // !! check the error before proceeding
            let uiImage = UIImage.init(cgImage: cgImage)
            return uiImage
        } catch  {
            print("exception catch at block - while uploading video")
        }
        return nil
    }
    
    func thumbnailForVideoAtURL(url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage.init(cgImage: imageRef)
        } catch {
            print("error")
            return nil
        }
    }
    
    
}

//MARK:-  UICollectionView Extension
extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

//MARK:-  String Extension
extension String{
    func capitalizingFirstLetter() -> String{
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizingFirstLetter(){
        self = self.capitalizingFirstLetter()
    }
}
extension UIWindow {
    
    /// Fix for http://stackoverflow.com/a/27153956/849645
    func set(rootViewController newRootViewController: UIViewController, withTransition transition: CATransition? = nil) {
        
        let previousViewController = rootViewController
        
        if let transition = transition {
            // Add the transition
            layer.add(transition, forKey: kCATransition)
        }
        
        rootViewController = newRootViewController
        
        // Update status bar appearance using the new view controllers appearance - animate if needed
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }
        
        /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
//        if years(from: date)   > 0 { return "\(years(from: date))y"   }
//        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "1s" }
        return ""
    }
}
