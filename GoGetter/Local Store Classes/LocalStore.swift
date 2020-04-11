//
//  LocalStore.swift
//  GoGetter
//
//  Created by Harsh on 04/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit

enum UserDetails: String {
    
    case userDetailsKey = "UserDetails"
    
    case name = "name"
    
    case facebookId = "facebookID"

    case coinFreebie = "coinFreebie"

    case isLogin = "isLogin"
    
    case isFirstTime = "isFirstTime"
    
    case facebookDetailsKey = "facebookDetails"
    
    case quizDoneKey = "quizDoneKey"
    
    case sound = "soundOnOff"
    
    case heightSet = "heightSet"
}


class LocalStore: NSObject {
    
    static let store = LocalStore()

//MARK:-  Saving Properties
    
    var saveUserDetails: Data?{
        didSet{
            saveUserDetailsFromAPI()
        }
    }
    
    var saveName: String?{
        didSet{
            saveDataInUserDefault(saveName)
        }
    }
    
    var facebookID: String?{
        didSet{
            saveFacebookID()
        }
    }

    var coinFreebie: Bool?{
        didSet{
            saveCoinFreebie()
        }
    }

    var facebookDetails: [String:Any]?{
        didSet{
            saveFacebookDetails()
        }
    }
    
    var login: Bool?{
        didSet{
            userLogin(login)
        }
    }
    
    var appNotFirstTime: Bool? = true{
        didSet{
            isFirstTimeAppOpen()
        }
    }
    
    var quizDone: Bool?{
        didSet{
            quizDoneSave()
        }
    }
    
    var soundOnOff: Bool? = true{
        didSet{
            soundPlayStop()
        }
    }
    
    var heightDone: Bool? = true{
        didSet{
            heightDoneSave()
        }
    }
    
//MARK:-  Getting Methods
    func getUserDetails() -> Dictionary<String, Any>{
        var userDict = Dictionary<String, Any>()
        if let data = UserDefaults.standard.object(forKey: UserDetails.userDetailsKey.rawValue) {
            if let dict = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
                userDict = dict
            }
        }
        return  userDict
    }
    
    func getData() -> String{
        return UserDefaults.standard.object(forKey: UserDetails.name.rawValue) as! String
    }
    
    func getFacebookID() -> String{
        if let str = UserDefaults.standard.object(forKey: UserDetails.facebookId.rawValue) as? String {
            return str
        }
        return ""
    }
    
    func getFacebookDetails() -> [String:Any]?{
        if let details =  UserDefaults.standard.object(forKey: UserDetails.facebookDetailsKey.rawValue) as? [String : Any] {
            return details
        }
        return ["":""]
    }
    
    func isLogin() -> Bool{
        return UserDefaults.standard.bool(forKey: UserDetails.isLogin.rawValue)
    }
    
    func notFirstTime() -> Bool{
        return UserDefaults.standard.bool(forKey: UserDetails.isFirstTime.rawValue)
    }
    
    func isQuizDone() -> Bool{
        return UserDefaults.standard.bool(forKey: UserDetails.quizDoneKey.rawValue)
    }
    
    func isSoundOn() -> Bool{
        if UserDefaults.standard.value(forKey: UserDetails.sound.rawValue) == nil{
            return true
        }else{
            return UserDefaults.standard.bool(forKey: UserDetails.sound.rawValue)
        }
    }
    
   
    func clearDataAllData(){
        let domain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: domain!)
        UserDefaults.standard.synchronize()
    }
    
    func clearKey(_ key: String){
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }

//MARK:-  Private Methods
    
    private func saveUserDetailsFromAPI(){
        UserDefaults.standard.set(saveUserDetails, forKey: UserDetails.userDetailsKey.rawValue)
    }
    
    private func saveDataInUserDefault(_ details: String?){
        UserDefaults.standard.set(details, forKey: UserDetails.name.rawValue)
    }
    
    private func saveFacebookID(){
        UserDefaults.standard.set(facebookID, forKey: UserDetails.facebookId.rawValue)
    }
    private func saveCoinFreebie(){
        UserDefaults.standard.set(coinFreebie, forKey: UserDetails.coinFreebie.rawValue)
    }

    private func saveFacebookDetails(){
        UserDefaults.standard.set(facebookDetails, forKey: UserDetails.facebookDetailsKey.rawValue)
    }
    
    private func userLogin(_ isLoginOrNot: Bool?){
        UserDefaults.standard.set(isLoginOrNot, forKey: UserDetails.isLogin.rawValue)
    }
    
    private func isFirstTimeAppOpen(){
        UserDefaults.standard.set(appNotFirstTime, forKey: UserDetails.isFirstTime.rawValue)
    }
    
    private func quizDoneSave(){
        UserDefaults.standard.set(quizDone, forKey: UserDetails.quizDoneKey.rawValue)
    }
    
    private func soundPlayStop(){
        UserDefaults.standard.set(soundOnOff, forKey: UserDetails.sound.rawValue)
    }
    
    private func heightDoneSave() {
        UserDefaults.standard.set(heightDone, forKey: UserDetails.heightSet.rawValue)
    }
}
