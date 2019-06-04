//
//  ListViewController.swift
//  Slindir
//
//  Created by Gurinder Batth on 31/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var heightNavigation: NSLayoutConstraint!
    @IBOutlet weak var collectionViewNewMatches: UICollectionView!
    
    @IBOutlet weak var tableViewMessages: UITableView!
    
    var friendsList = [[String: Any]]()
    
    var senderDisplayName: String?
    
    var newChannelTextField: UITextField?
    
    private var friends: [Friend] = []
    private let user_id = LocalStore.store.getFacebookID()
    let personalDetail = LocalStore.store.getUserDetails()
    private lazy var friendRef: DatabaseReference = Database.database().reference().child(user_id)
    
    private var userRef: DatabaseReference?
     private var userRefOther: DatabaseReference?
    private var friendRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(chatNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("chatListNotification")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMatchNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("newMatchListNotification")), object: nil)

        if UIScreen.main.bounds.size.height >= 812 {
            self.heightNavigation.constant = 100
            self.view.layoutIfNeeded()
        }
        
        getDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.friends.removeAll()
        observeFriendsAdded()
        observeFriendsRemoved()
        observeOnlineFriends()
        tableViewMessages.reloadData()
        checkMatchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.currentController = self
        
        getFriendsList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UserDefaults.standard.set(false, forKey: "chatNotification")
        UserDefaults.standard.synchronize()
        userRef?.removeObserver(withHandle: friendRefHandle!)
    }
    
    func checkMatchNotifications() {
        if UserDefaults.standard.bool(forKey: "matchedNotification") {
            UserDefaults.standard.set(false, forKey: "matchedNotification")
            UserDefaults.standard.synchronize()
            let data = UserDefaults.standard.object(forKey:"matchedUser")
            if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
                let userOtherDict = requiredData["request_to"] as? [String: Any]
                //var profile_pic = ""
                //if let pic = userOtherDict!["profile_pic"] as? String {
                   // profile_pic = pic
                //}
                self.createNewFriendOnFirebase(userOtherDict!)
                //let friend = Friend(id: (userOtherDict!["user_fb_id"]as? String)!, name: (userOtherDict!["user_name"]as? String)!, profilePic: profile_pic, lastMessage:nil, online: false)
                //goToChatController(friend,friend.id)
            }
            
        }
        else if UserDefaults.standard.bool(forKey: "newMatchedNotification") {
            UserDefaults.standard.set(false, forKey: "newMatchedNotification")
            UserDefaults.standard.synchronize()
            let data = UserDefaults.standard.object(forKey:"newMatchedUser")
            if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
                let userOtherDict = requiredData["sender"] as? [String: Any]
//                var profile_pic = ""
//                if let pic = userOtherDict!["profile_pic"] as? String {
//                    profile_pic = pic
//                }
//                let friend = Friend(id: (userOtherDict!["user_fb_id"]as? String)!, name: (userOtherDict!["user_name"]as? String)!, profilePic: profile_pic, lastMessage:nil, online: false)
//                goToChatController(friend,friend.id)
                self.createNewFriendOnFirebase(userOtherDict!)
            }
            
        }
    }
    
    func checkNotifications() {
        if UserDefaults.standard.bool(forKey: "chatNotification") {
            let data = UserDefaults.standard.object(forKey:"ChatUser")
            if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
                if let userOtherDict = requiredData["sender"] as? [String: Any] {
                    var profile_pic = ""
                    if let pic = userOtherDict["profile_pic"] as? String {
                        profile_pic = pic
                    }
                    
                    
                    if let index = self.friends.index(where: { (friend) -> Bool in
                        friend.id  == (userOtherDict["user_fb_id"] as? String)!
                    }){
                        UserDefaults.standard.set(false, forKey: "chatNotification")
                        UserDefaults.standard.synchronize()
                        let foundItems = self.friends[index] as Friend
                        let friend = Friend(id: (userOtherDict["user_fb_id"]as? String)!, name: (userOtherDict["user_name"]as? String)!, profilePic: profile_pic, lastMessage:foundItems.lastMessage, online: false)
                        goToChatController(friend,friend.id)
                        
                    }
                    
                }
                else {
                    let userOtherDict = requiredData
                    var profile_pic = ""
                    if let pic = userOtherDict["profilePic"] as? String {
                        profile_pic = pic
                    }
                    if let index = self.friends.index(where: { (friend) -> Bool in
                        friend.id  == (userOtherDict["senderId"] as? String)!
                    }){
                        UserDefaults.standard.set(false, forKey: "chatNotification")
                        UserDefaults.standard.synchronize()
                        let foundItems = self.friends[index] as Friend
                            let friend = Friend(id: (userOtherDict["senderId"]as? String)!, name: (userOtherDict["senderName"]as? String)!, profilePic: profile_pic, lastMessage:foundItems.lastMessage, online: false)
                            goToChatController(friend,friend.id)
                        

                    }
                    
                }
            }
        }
        
    }
    
    @objc func newMatchNotificationRecived() {
        checkMatchNotifications()
    }
    
    @objc func chatNotificationRecived() {
        
        let data = UserDefaults.standard.object(forKey:"ChatUser")
        if let requiredData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
            if let userOtherDict = requiredData["sender"] as? [String: Any] {
                var profile_pic = ""
                if let pic = userOtherDict["profile_pic"] as? String {
                    profile_pic = pic
                }
                if let index = self.friends.index(where: { (friend) -> Bool in
                    friend.id  == (userOtherDict["user_fb_id"] as? String)!
                }){
                    UserDefaults.standard.set(false, forKey: "chatNotification")
                    UserDefaults.standard.synchronize()
                    let foundItems = self.friends[index] as Friend
                        let friend = Friend(id: (userOtherDict["user_fb_id"]as? String)!, name: (userOtherDict["user_name"]as? String)!, profilePic: profile_pic, lastMessage:foundItems.lastMessage, online: false)
                        self.goToChatController(friend,friend.id)
                }
            }
            else {
                let userOtherDict = requiredData
                var profile_pic = ""
                if let pic = userOtherDict["profilePic"] as? String {
                    profile_pic = pic
                }
                if let index = self.friends.index(where: { (friend) -> Bool in
                    friend.id  == (userOtherDict["senderId"] as? String)!
                }){
                    UserDefaults.standard.set(false, forKey: "chatNotification")
                    UserDefaults.standard.synchronize()
                    let foundItems = self.friends[index] as Friend
                        let friend = Friend(id: (userOtherDict["senderId"]as? String)!, name: (userOtherDict["senderName"]as? String)!, profilePic: profile_pic, lastMessage:foundItems.lastMessage, online: false)
                        self.goToChatController(friend,friend.id)
                }
            }
        }
    }
    
    
    func getDetails(){
        let userDetails = LocalStore.store.getUserDetails()
        if let name = userDetails["user_name"] as? String{
            senderDisplayName = name
        }
    }
    
    
//MARK:-  UICollection View Data Sources

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friendsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMatchesCell", for: indexPath) as! NewMatchesCollectionViewCell
        let name = friendsList[indexPath.row]["user_name"] as! String
        cell.lblName.text = name
        if let profile_pic = friendsList[indexPath.row]["profile_pic"] as? String {
        cell.imgViewProfile.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profile_pic)), placeholderImage: UIImage.init(named: "placeholder"))
        }
        
        cell.imgViewProfile.layer.cornerRadius = 37
        
        if let matchDateStr = friendsList[indexPath.row]["match_created_on"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
             dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
            let matchDate: Date? = dateFormatter.date(from: matchDateStr )
            let time = Calendar.current.dateComponents([.second], from: matchDate!, to: Date()).second ?? 0

            cell.vwProgress.progressTintColor = UIColor.init(red: 35/255, green: 165/255, blue: 175/255, alpha: 0.7)
            cell.vwProgress.trackTintColor = UIColor.clear
            cell.vwProgress.roundedCorners = 0
            cell.vwProgress.thicknessRatio = 1.0
            cell.vwProgress.clockwiseProgress = 0
            if (time >= 172800) {
                cell.vwProgress.setProgress(1.0, animated: false)

            }
            else {
                print(CGFloat(CGFloat(time)/172800))
                cell.vwProgress.setProgress(CGFloat(CGFloat(time)/172800), animated: false)
            }
        }
        return cell
    }
    
//MARK:-  UICollectionView Delegates

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let friendDict = friendsList[indexPath.row]
        self.createNewFriendOnFirebase(friendDict)
        
    }
    
//MARK:-  UICollectionView Delegates Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 92, height: 125)
    }
    
//MARK:-  UITableView Data Sources
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let label = UILabel()
        label.text = "Messages"
        label.font = UIFont(name: "OpenSans-Semibold", size: 14)
        label.textColor = UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: [:], views: ["v0":label]))
        
        let countView = UIView()
        //countView.backgroundColor = UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)
        headerView.addSubview(countView)
        countView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[v0]-10-[v1]", options: NSLayoutConstraint.FormatOptions(rawValue:0), metrics: [:], views: ["v0":label,"v1":countView]))
        headerView.addConstraint(NSLayoutConstraint(item: countView, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0))
        countView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
//        let labelCount = UILabel()
//        labelCount.textColor = .white
//        labelCount.text = ""
//        labelCount.font = UIFont(name: "OpenSans-Semibold", size: 14)
//        labelCount.translatesAutoresizingMaskIntoConstraints = false
//        countView.addSubview(labelCount)
        
//        countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0]-8-|", options: NSLayoutFormatOptions(rawValue:0), metrics: [:], views: ["v0":labelCount]))
//        countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(rawValue:0), metrics: [:], views: ["v0":labelCount]))
//        countView.layer.cornerRadius = 12
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MessagesTableViewCell
        cell.lblName.text = friends[indexPath.row].name
        let profile_pic = friends[indexPath.row].profilePic
        cell.imgViewProfile.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profile_pic)), placeholderImage: UIImage.init(named: "placeholder"))
        
        cell.imgViewProfile.layer.cornerRadius = 42.5
        
        if !friends[indexPath.row].online {
            cell.imgViewNewMessage.backgroundColor = UIColor.gray
        }
        else {
            cell.imgViewNewMessage.backgroundColor = UIColor.init(red: 38/255, green: 166/255, blue: 175/255, alpha: 1)
        }
        
        
        cell.lblMessage.font = UIFont.init(name: "OpenSans-Regular", size: 16)
        if let lastMessageDict = friends[indexPath.row].lastMessage{
            let lastMessage = lastMessageDict["text"] as? String
            cell.lblMessage.text = lastMessage
            if let unread = lastMessageDict["unread"] as? String {
                if unread == "1" {
                    cell.lblMessage.font = UIFont.init(name: "OpenSans-Bold", size: 16)
                }
            }
        }else{
            cell.lblMessage.text = ""
        }
        
        return cell
    }
    
//MARK:-  UITableView Delegates

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let friend = friends[indexPath.item]
        goToChatController(friend,friend.id)
    }
    
    
//MARK:-  Local Functions
    func goToChatController(_ friend: Friend,_ id: String?){
        DispatchQueue.main.async {
            let friendRef: DatabaseReference = Database.database().reference().child("users")
            let userRefs = friendRef.child(self.user_id)
            
            let chatController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatController.navigationController?.navigationBar.isHidden = false
            chatController.senderDisplayName = self.senderDisplayName
            chatController.friend = friend
            chatController.receiver_id = id
            chatController.userRef = userRefs
            self.navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
//MARK:-  Get Friends List
    func getFriendsList(){
        let user_id = LocalStore.store.getFacebookID()
        let parameters = ["user_fb_id": user_id, "type":"new"]
        
        Loader.startLoader(true)
        
        WebServices.service.webServicePostRequest(.post, .friend, .fetchFriendList, parameters, successHandler: { (response) in
            Loader.stopLoader()
            let jsonDict = response
            let status = jsonDict!["status"] as! String
            self.friendsList.removeAll()
            if status == "success"{
                let friendsList = jsonDict!["friendList"] as! [[String: Any]]
                for  dict in friendsList  {
                    if let matchDateStr = dict["match_created_on"] as? String {
                        if matchDateStr != "" {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
                             dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
                            let matchDate: Date? = dateFormatter.date(from: matchDateStr)
                            print(Calendar.current.dateComponents([.second], from: matchDate!, to: Date()).second ?? 0)
                            let time = Calendar.current.dateComponents([.second], from: matchDate!, to: Date()).second ?? 0
                            if time == nil {
                                self.removeFromNewMatches(dict["user_fb_id"] as! String)
                            }
                            else {
                                //604800
                                if CGFloat(time) > 259200 {
                                    self.removeFromNewMatches(dict["user_fb_id"] as! String)
                                }
                                else {
                                    self.friendsList.append(dict)
                                }
                            }
                        }
                        else{
                            self.removeFromNewMatches(dict["user_fb_id"] as! String)
                        }
                    }
                }
                
            }
            self.collectionViewNewMatches.reloadData()
            print(self.friendsList)
            
        }) { (error) in
            self.friendsList.removeAll()
            Loader.stopLoader()
            self.collectionViewNewMatches.reloadData()
        }
    }
    
    
    //MARK:-  Firebase Related Methods

    func createNewFriendOnFirebase(_ friendDict:[String:Any]) {
        let id = friendDict["user_fb_id"] as! String
        var name = ""
        var profilePic = ""
        if let friendname = friendDict["user_name"] as? String {
            name = friendname
        }
        if let profilePicFriend = friendDict["profile_pic"] as? String {
            profilePic = profilePicFriend
        }
        
        let idSelf = self.user_id
        var nameSelf = ""
        var profilePicSelf = ""
        if let myName = personalDetail["user_name"] as? String {
            nameSelf = myName
        }
        if let myProfilePic = personalDetail["profile_pic"] as? String {
            profilePicSelf = myProfilePic
        }
        
        
        let friend:Friend?

        if let lastMessage = friendDict["lastMessage"] as? [String: Any]{
            friend = Friend(id: id, name: name, profilePic: profilePic, lastMessage: lastMessage, online: false)
        }else{
            friend = Friend(id: id, name: name, profilePic: profilePic, lastMessage:nil, online: false)
        }
        
        // add self to friend's friendlist
        let friendRefOther: DatabaseReference = Database.database().reference().child("users")
        self.userRefOther = friendRefOther.child(id).child("friends")
        //add friend to own friendlist
        let createFriendRef = self.userRefOther?.child(self.user_id)
        let friendItem = [
            "name": nameSelf,
            "id":idSelf,
            "profilePic": profilePicSelf,
            "online": true
            ] as [String : Any]
        createFriendRef?.setValue(friendItem)
        
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        
        self.userRef = friendRef.child(self.user_id).child("friends")
        self.userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(id){
                self.goToChatController(friend!,id)
            }else{
                //add friend to own friendlist
                self.createFriends(id, name, profilePic)
            }
        })
        
    }
    
    func createFriends(_ id: String, _ name: String, _ profilePic: String){
        let friend = Friend(id: id, name: name, profilePic: profilePic, lastMessage: nil, online: false)
        let user_id = LocalStore.store.getFacebookID()
        print("User ID:- ",user_id)
        let createFriendRef = userRef?.child(id)
        let friendItem = [
            "name": name,
            "id":id,
            "profilePic": profilePic
            ] as [String : Any]
        createFriendRef?.setValue(friendItem)
        goToChatController(friend, id)
    }
    
    private func observeFriendsAdded() {
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        userRef = friendRef.child(user_id).child("friends")
        
        friendRefHandle = userRef?.observe(.childAdded, with: { (snapshot) in
            let friendData = snapshot.value as! Dictionary<String, Any>
            print("Friends :- ",friendData)
            let id = snapshot.key
            if let name = friendData["name"] as! String!, name.count > 0{
                let user_id = LocalStore.store.getFacebookID()
                if friendData["id"] as? String == user_id {
                }else{
                    var profile_pic:String = ""
                    if let lastMessage = friendData["lastMessage"] as? [String: Any]{
                        if let pic = friendData["profilePic"] as? String {
                            profile_pic = pic
                        }
                        var online:Bool = false
                        if let onlineBool = friendData["online"] as? Bool {
                            online = onlineBool
                        }
                        self.friends.append(Friend(id: id, name: name, profilePic: profile_pic,lastMessage: lastMessage, online: online))
                        self.sortFriendsArray()
                        self.tableViewMessages.reloadData()
                    }else{
                        if let pic = friendData["profilePic"] as? String {
                            profile_pic = pic
                        }
                        var online:Bool = false
                        if let onlineBool = friendData["online"] as? Bool {
                            online = onlineBool
                        }
                        self.friends.append(Friend(id: id, name: name, profilePic: profile_pic,lastMessage: nil, online:online))
                        self.sortFriendsArray()
                        self.tableViewMessages.reloadData()
                    }
                    DispatchQueue.main.async {
                        self.checkNotifications()
                    }
                }
            }
        })
    }
    
    private func observeFriendsRemoved(){
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        userRef = friendRef.child(user_id).child("friends")
        
        friendRefHandle = userRef?.observe(.childRemoved, with: { (snapshot) in
            let friendData = snapshot.value as! Dictionary<String, Any>
            print("Friends :- ",friendData)
            let id = snapshot.key
            if let name = friendData["name"] as! String!, name.count > 0{
                let user_id = LocalStore.store.getFacebookID()
                if user_id != "" {
                    if friendData["id"] as? String == user_id{
                    }else{
                        if let index = self.friends.index(where: { (friend) -> Bool in
                            friend.id  == id
                        }){
                            self.friends.remove(at: index)
                        }
                        self.sortFriendsArray()
                        self.tableViewMessages.reloadData()
                    }
                }
                DispatchQueue.main.async {
                    self.checkNotifications()
                }
            }
        })
    }
    
    private func observeOnlineFriends(){
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        userRef = friendRef.child(user_id).child("friends")
        
        friendRefHandle = userRef?.queryOrderedByKey().observe(.childChanged, with: { (snapshot) in
            let data = snapshot.value as! NSDictionary
            print("Friends :- ",data)
            if let friendData = data as? [String: Any] {
                print("Friends :- ",friendData)
                let id = String(format:"%@",friendData["id"] as! CVarArg)
                let index = self.friends.index(where: { (friend) -> Bool in
                    friend.id  == id
                })
                var profile_pic = ""
                if let pic = friendData["profilePic"] as? String {
                    profile_pic = pic
                }
                var online = false
                if let status = friendData["online"] as? Bool {
                    online = status
                }
                var newFriend = Friend(id: id, name: friendData["name"] as! String, profilePic: profile_pic, lastMessage: nil , online: online)
                if let lastMessage = friendData["lastMessage"] as? [String: Any] {
                    newFriend = Friend(id: id, name: friendData["name"] as! String, profilePic: profile_pic, lastMessage: lastMessage , online: online)
                }
                if index != nil {
                    self.friends.remove(at: index!)
                    self.friends.insert(newFriend, at: index!)
                    self.sortFriendsArray()
                    DispatchQueue.main.async {
                        self.tableViewMessages.reloadData()
                    }
                    
                }
                DispatchQueue.main.async {
                    self.checkNotifications()
                }
            }
        })
    }
    
    func sortFriendsArray() {
        self.friends = self.friends.sorted(by: { (friend1, friend2) -> Bool in
            if friend1.lastMessage != nil && friend2.lastMessage != nil {
                let time1 = friend1.lastMessage!["time"] as! String
                let time2 = friend2.lastMessage!["time"] as! String
                return self.stringToSeconds(time1) > self.stringToSeconds(time2)
            }
            else if friend2.lastMessage != nil {
                return false
            }
            else if friend1.lastMessage != nil {
                return true
            }
            return false
        })
    }
    
    deinit {
        if let refHandle = friendRefHandle{
            friendRef.removeObserver(withHandle: refHandle)
        }
    }
    
//MARK:-  IBAction Methods
    
    @IBAction func btnBack(_ sender: Any?){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        navigationController?.popViewController(animated: true)
    }
        
    func removeFromNewMatches(_ id:String) {
        let user_id = LocalStore.store.getFacebookID()
        var parameters = Dictionary<String,Any>()
        parameters["user_fb_id"] = user_id
        parameters["request_sending_user_fb_id"] = id
        parameters["action"] = "decline"
        
        WebServices.service.webServicePostRequest(.post, .friend, .acceptFriendRequest, parameters, successHandler: { (response) in
            print(response ?? "")
        }) { (error) in
            Loader.stopLoader()
        }
    }
}

