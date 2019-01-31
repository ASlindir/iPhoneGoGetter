//
//  ChatViewController.swift
//  Slindir
//
//  Created by Gurinder Batth on 24/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

//MARK:-  Want Help Visit Here: - https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2


import UIKit
import Firebase
import Photos
import SDWebImage
import IQKeyboardManagerSwift
import TTGSnackbar
import Firebase

class ChatViewController: JSQMessagesViewController{


    //MARK:-  Outlets, Variables and Constants
    let user_id = LocalStore.store.getFacebookID()
    let personalDetail = LocalStore.store.getUserDetails()
    
    var friendRef = Database.database().reference().child("messages")
    var userRef: DatabaseReference?
    private var userRefOther: DatabaseReference?
    
    var readUnreadRef: DatabaseReference?
    var unread_count: String = ""
    
    let currentUserDict = LocalStore.store.getUserDetails()
    @IBOutlet weak var lblTitle: UILabel!
    
    var friend: Friend?{
        didSet{
            title = friend?.name
        }
    }
    
    private var friends: [Friend] = []
    
    private var opponentRef: DatabaseReference?

    private var opponentRefHandle: DatabaseHandle?
    
    var receiver_id:String?
    
    var messages = [JSQMessage]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    private lazy var messageRef: DatabaseReference = self.friendRef
    private var newMessageRefHandle: DatabaseHandle?
    private var newRefHandle: DatabaseHandle?
//Properties for Typing Indicator
    private lazy var userIsTypingRef: DatabaseReference = Database.database().reference().child("typingIndicator").child("\(self.receiver_id!)_\(user_id)")
    private var localTyping = false
    var isTyping: Bool{
        get{
            return localTyping
        }set{
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    private lazy var usersTypingQuery: DatabaseQuery = self.friendRef.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
//Properties for Send Photo & Show Photo
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://slindir-a98e6.appspot.com/")
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updateMessageRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("chatControllerNotification")), object: nil)

        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor =  UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        
//Add the right Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "flag"), style: .plain, target: self, action: #selector(blockOrWarnUser))
        
//Remove the Avatar From the chat Collection View
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
        
        self.senderId = user_id//Auth.auth().currentUser?.uid
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        
        
        getCurrentUser()
    }

    
    func getCurrentUser(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        messages.removeAll()
        self.collectionView.reloadData()
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isHidden = false
        UserDefaults.standard.set(false, forKey: "chatNotification")
        UserDefaults.standard.synchronize()
        
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.currentController = self
        
        if friend?.lastMessage != nil {
            self.automaticallyScrollsToMostRecentMessage = true
            var messageItem = friend?.lastMessage
            messageItem!["unread"] = "0"
            messageItem!["unread_count"] = "0"
            self.updateReadUnreadMessages(messageItem!)
        }
        
        IQKeyboardManager.shared.enable = false
        
        settingTheTitleLabel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
        observeMessages()
        observeTyping()
        observeFriendsRemoved()
        observeOpponentFriendsAdded()
        observeFriendUpdated()
        self.moveToPermanentList()
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-Chat",
            AnalyticsParameterItemName: "Chat"
            ])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.enable = true
        if let refHandle = newMessageRefHandle{
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updateMessageRefHandle{
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = opponentRefHandle{
            opponentRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    deinit {
        if let refHandle = newMessageRefHandle{
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updateMessageRefHandle{
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = opponentRefHandle{
            opponentRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    @objc func chatNotificationRecived() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let data = UserDefaults.standard.object(forKey:"ChatUser")
        if let messageData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? Dictionary<String, Any> {
            if let sender_id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let text = messageData["text"] as! String! , text.characters.count > 0{
                if sender_id != self.receiver_id! {
                    self.showMessageView(String(format:"%@: %@",name, text), messageData)
                }
                else {
                    UserDefaults.standard.set(false, forKey: "chatNotification")
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
    }
    
//MARK:-  Local Methods
    func settingTheTitleLabel(){
    
        let navTitleLabel = UILabel()
        navTitleLabel.text = friend?.name
        navTitleLabel.font = UIFont(name: "OpenSans-SemiBold", size: 15)
        navTitleLabel.textColor = UIColor.white
        let width = navTitleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        navTitleLabel.frame = CGRect(x: 36, y: 0, width: width, height: 34)
        
        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 2, width: 30, height: 30))
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, (friend?.profilePic)!)), placeholderImage: UIImage.init(named: "placeholder"))
        
        let titleView = UIView()
        titleView.backgroundColor = .clear
        titleView.frame = CGRect(x: 0, y: 0, width: width + 36, height: 34)
        titleView.addSubview(imageView)
        titleView.addSubview(navTitleLabel)
        self.navigationItem.titleView = titleView
        
        let recognizer1 = UITapGestureRecognizer(target: self, action: #selector(gotoProfileDetail))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer1)
        
}
    
    @objc func gotoProfileDetail() {
        let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileDetaiViewController") as! ProfileDetaiViewController
        profileController.navigationController?.navigationBar.isHidden = true
        profileController.user_id = self.receiver_id!
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
   
    
//MARK:-  JSQMesagesViewController DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
//MARK:-  JSQMessagesBubbleImage DataSource Methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId{
            return outgoingBubbleImageView
        }else{
            return incomingBubbleImageView
        }
    }
    
//MARK:-  UICollection View Data Source
    /*
     This method is called to override the message text color
     */
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.row]
        cell.avatarImageView.layer.cornerRadius = 15
        cell.avatarImageView.clipsToBounds = true
        cell.avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        if message.isMediaMessage{
            if message.senderId == senderId {
                if let profile_pic = personalDetail["profile_pic"] as? String {
                    cell.avatarImageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profile_pic)), placeholderImage: UIImage.init(named: "placeholder"))
                }
            }else{
                cell.avatarImageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, (friend?.profilePic)!)), placeholderImage: UIImage.init(named: "placeholder"))
            }
        }else {
            if message.senderId == senderId {
                cell.textView.textColor = .white
                if let profile_pic = personalDetail["profile_pic"] as? String {
                    cell.avatarImageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profile_pic)), placeholderImage: UIImage.init(named: "placeholder"))
                }
            }else{
                cell.textView.textColor = .black
                cell.avatarImageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, (friend?.profilePic)!)), placeholderImage: UIImage.init(named: "placeholder"))
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        if message.senderId == senderId {
            let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)]
            return NSAttributedString.init(string: Date().offset(from: message.date), attributes: attributes)
        }
        else {
            let attributes = [NSAttributedStringKey.foregroundColor:UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)]
            return NSAttributedString.init(string: Date().offset(from: message.date), attributes: attributes)
        }
        
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
//MARK:-  Remove the Person Image from Chat
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let jsqMessage = JSQMessagesAvatarImage(avatarImage: #imageLiteral(resourceName: "steve"), highlightedImage: nil, placeholderImage: #imageLiteral(resourceName: "steve"))
        return jsqMessage
    }
    
    
//MARK:-  Send Message
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        unread_count = "0"
        for friend in friends {
            if let lastMessage = friend.lastMessage as? [String: Any] {
                unread_count = String(format: "%d",Int(lastMessage["unread_count"] as! String)! + Int(unread_count)!)
            }
        }
        
        let chatId = "\(user_id)_\(self.receiver_id!)"
        let reciverChatId = "\(self.receiver_id!)_\(user_id)"
        let chatref = friendRef.child(user_id).child(chatId).childByAutoId()
        let itemRef = chatref
        let newItemRef = friendRef.child(self.receiver_id!).child(reciverChatId).childByAutoId()
        var profile_pic = ""
        if let pic = currentUserDict["profile_pic"] as? String  {
            profile_pic =  pic
        }
        
        let messageItem = [
            "senderId":senderId!,
            "senderName":senderDisplayName!,
            "text": text!,
            "time":self.currentTime(),
            "profilePic": profile_pic,
            "unread": "0",
            "unread_count": "0"
            ] as [String : Any]
        let messageItem1 = [
            "senderId":senderId!,
            "senderName":senderDisplayName!,
            "text": text!,
            "time":self.currentTime(),
            "profilePic": profile_pic,
            "unread": "1",
            "unread_count": String(format:"%d",Int(unread_count)! + 1)
            ] as [String : Any]
        
        let userRef = Database.database().reference().child("users").child(user_id).child("friends").child(self.receiver_id!).child("lastMessage")
        let userRef1 = Database.database().reference().child("users").child(self.receiver_id!).child("friends").child(user_id).child("lastMessage")

        userRef.setValue(messageItem)
        userRef1.setValue(messageItem1)
        itemRef.setValue(messageItem)
        newItemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
        self.sendMessageNotification(text!, self.receiver_id!)
        
    }
    
    func createNewFriend() {
        
        let idSelf = self.user_id
        var nameSelf = ""
        var profilePicSelf = ""
        if let myName = self.currentUserDict["user_name"] as? String {
            nameSelf = myName
        }
        if let myProfilePic = self.currentUserDict["profile_pic"] as? String {
            profilePicSelf = myProfilePic
        }
        
        // add self to friend's friendlist
        let friendRefOther: DatabaseReference = Database.database().reference().child("users")
        self.userRefOther = friendRefOther.child(self.receiver_id!).child("friends")
        userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.receiver_id!){
            }else{
                //add friend to own friendlist
                let createFriendRef = self.userRefOther?.child(self.user_id)
                let friendItem = [
                    "name": nameSelf,
                    "id":idSelf,
                    "profilePic": profilePicSelf
                    ] as [String : Any]
                createFriendRef?.setValue(friendItem)
            }
        })
        
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        
        userRef = friendRef.child(user_id).child("friends")
        userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let user_id = LocalStore.store.getFacebookID()
            print("User ID:- ",user_id)
            let createFriendRef = self.userRef?.child((self.friend?.id)!)
            let friendItem = [
                "name": self.friend?.name as Any,
                "id":self.friend?.id as Any,
                "profilePic": self.friend?.profilePic as Any
                ] as [String : Any]
            createFriendRef?.setValue(friendItem)
        })
    }
    
    private func addMessage(withId id: String, name: String, text: String, date: Date){
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date , text: text){
            messages.append(message)
        }
    }
    
    private func observeMessages(){
        let chatId = "\(user_id)_\(self.receiver_id!)"
        messageRef = friendRef.child(user_id).child(chatId)
        let messageQuery = messageRef.queryLimited(toLast: 25)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        df.timeZone = TimeZone(abbreviation: "GMT")
        df.locale = Locale.init(identifier: "en_US_POSIX")
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) in
            let messageData = snapshot.value as! [String: Any]
            if let id = messageData["senderId"] as? String, let name = messageData["senderName"] as? String, let text = messageData["text"] as? String , text.characters.count > 0, (messageData["photoURL"]  == nil), let dateStr = messageData["time"] as? String, dateStr.characters.count > 0{
                if let date = df.date(from: dateStr)! as? Date {
                }
                else {
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                }
                self.addMessage(withId: id, name: name, text: text, date: df.date(from: dateStr)!)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.scrollToBottom(animated: true)
                }
                var messageItem = messageData
                messageItem["unread"] = "0"
                messageItem["unread_count"] = "0"
                self.updateReadUnreadMessages(messageItem)
            }
            else if let id = messageData["senderId"] as? String, let photoURL = messageData["photoURL"] as? String, let dateStr = messageData["time"] as? String, dateStr.characters.count > 0{
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId){
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem, date: df.date(from: dateStr)!)
                    if photoURL.hasPrefix("gs://"){
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                    self.updateMessageRefHandle = self.messageRef.observe(.childChanged, with: { (snapshot) in
                        let key = snapshot.key
                        let messageData = snapshot.value as! [String: Any]
                        
                        if let photoURL = messageData["photoURL"] as? String{
                            if let mediaItem = self.photoMessageMap[key]{
                                self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                            }
                        }
                    })
                    
                    var messageItem = messageData
                    messageItem["unread"] = "0"
                     messageItem["unread_count"] = "0"
                    self.updateReadUnreadMessages(messageItem)
                }
                
            }
            else{
                
            }
        })
    }
    
    //MARK:-  Observe Friends Removed
    private func observeFriendsRemoved(){
        self.unread_count = "0"
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        userRef = friendRef.child(user_id).child("friends")
        
        newRefHandle = userRef?.observe(.childRemoved, with: { (snapshot) in
            let friendData = snapshot.value as! Dictionary<String, Any>
            print("Friends :- ",friendData)
            let ids = snapshot.key
            if ids == self.receiver_id{
                let alert = UIAlertController(title:String(format:"This conversation is no longer available.",(self.friend?.name)!), message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .cancel) { (action: UIAlertAction) in
                    if (self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2].isKind(of: ListViewController.self))! {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        let listCont = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
                        self.navigationController?.popToViewController(listCont!, animated: true)
                    }
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    //MARK:-  Observe opponents Friends
    private func observeOpponentFriendsAdded() {
        self.friends.removeAll()
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        opponentRef = friendRef.child(friend?.id ?? "").child("friends")
        
        opponentRefHandle = opponentRef?.observe(.childAdded, with: { (snapshot) in
            let friendData = snapshot.value as! Dictionary<String, Any>
            print("Friends :- ",friendData)
            let data = snapshot.value as! NSDictionary
            print("Friends :- ",data)
            if let friendData = data as? [String: Any] {
                print("Friends :- ",friendData)
                let id = String(format:"%@",friendData["id"] as! CVarArg)
                
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
                self.friends.append(newFriend)
                // print(friendData!)
            }
        })
    }
    
    func observeFriendUpdated(){
        
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        opponentRef = friendRef.child(friend?.id ?? "").child("friends")
        opponentRefHandle = opponentRef?.observe(.childChanged, with: { (snapshot) in
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
                }
            // print(friendData!)
            }
        })
    }
    
    //MARK:-  Setting up the Bubbles
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage{
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: #colorLiteral(red: 0, green: 0.6509803922, blue: 0.6862745098, alpha: 1))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage{
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
//MARK:-  Detect The Typing
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        self.scrollToBottom(animated: true)
    }
    
    private func observeTyping(){
        let chatId = "\(self.receiver_id!)_\(user_id)"
        let checkId = "\(user_id)_\(self.receiver_id!)"
        let typeRef = Database.database().reference().child("typingIndicator").child(chatId)
        let observeRef = Database.database().reference().child("typingIndicator").child(checkId)
        
        userIsTypingRef = typeRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery = observeRef.queryOrderedByValue().queryEqual(toValue: true)
        usersTypingQuery.observe(.value) { (data : DataSnapshot) in
            print("ID :- ",data.childrenCount)
            if self.isTyping{
                return
            }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
//MARK:-   Send The Photo in Message
    func sendPhotoMessage() -> (String?,String?)?{
        unread_count = "0";
        for friend in friends {
            if let lastMessage = friend.lastMessage as? [String: Any] {
                unread_count = String(format: "%d",Int(lastMessage["unread_count"] as! String)! + Int(unread_count)!)
            }
        }
        
        let chatId = "\(user_id)_\(self.receiver_id!)"
        let reciverChatId = "\(self.receiver_id!)_\(user_id)"
        let chatref = friendRef.child(user_id).child(chatId).childByAutoId()
        let itemRef = chatref
        let newItemRef = friendRef.child(self.receiver_id!).child(reciverChatId).child(chatref.key ?? "")
        var profile_pic = ""
        if let pic = currentUserDict["profile_pic"] as? String  {
            profile_pic =  pic
        }
        let messageItem = [
            "photoURL":imageURLNotSetKey,
            "senderId": senderId!,
            "senderName":senderDisplayName!,
            "text": "photo",
            "time":self.currentTime(),
            "profilePic":profile_pic,
            "unread": "0",
            "unread_count": "0"
            ] as [String : Any]
        
        let messageItem1 = [
            "photoURL":imageURLNotSetKey,
            "senderId": senderId!,
            "senderName":senderDisplayName!,
            "text": "photo",
            "time":self.currentTime(),
            "profilePic":profile_pic,
            "unread": "1",
            "unread_count": String(format:"%d",Int(unread_count)! + 1)
            ] as [String : Any]
        
        let userRef = Database.database().reference().child("users").child(user_id).child("friends").child(self.receiver_id!).child("lastMessage")
        let userRef1 = Database.database().reference().child("users").child(self.receiver_id!).child("friends").child(user_id).child("lastMessage")
        
        userRef.setValue(messageItem)
        userRef1.setValue(messageItem1)
        itemRef.setValue(messageItem)
        itemRef.setValue(messageItem)
        newItemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        self.sendMessageNotification("Sent you a photo message.", self.receiver_id!)
        return (itemRef.key,newItemRef.key)
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: (String,String)){
        let chatId = "\(user_id)_\(self.receiver_id!)"
        let reciverChatId = "\(self.receiver_id!)_\(user_id)"
        let chatref = friendRef.child(user_id).child(chatId).child(key.0)
        let itemRef = chatref
        let newItemRef = friendRef.child(self.receiver_id!).child(reciverChatId).child(key.1)
        newItemRef.updateChildValues(["photoURL":url])
        itemRef.updateChildValues(["photoURL": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
        
    }
    /*
     This method helps to send photo
     */
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem, date: Date){
        if let message = JSQMessage(senderId: id, senderDisplayName: "", date: date, media: mediaItem){
            messages.append(message)
            if (mediaItem.image == nil){
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    /*
     This Methods helps to retrive the image from firebase Storage and show in Chat
     */
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?){
        let imgVw = UIImageView()
        imgVw.loadImageUsingCacheWithURLString(photoURL) { (image) in
            DispatchQueue.main.async {
                mediaItem.image = image
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            }
            
        }
        
      //  let storageRef = Storage.storage().reference(forURL: photoURL)

//        if let cacheImage = imageCache.object(forKey: photoURL as AnyObject) as? UIImage {
//            mediaItem.image = cacheImage
//        }
//        else {
//            storageRef.getData(maxSize: INT64_MAX) { (data, error) in
//                if let err = error{
//                    self.showAlertWithOneButton("Error!", err.localizedDescription, "OK")
//                }else{
//                    storageRef.getMetadata(completion: { (metaData, metaDataErr) in
//                        if let err = error{
//                            self.showAlertWithOneButton("Error!", err.localizedDescription, "OK")
//                        }else{
//                            if metaData?.contentType == "image/gif"{
//                                mediaItem.image = UIImage(gifData: data!)
//                            }else{
//                                mediaItem.image = UIImage(data: data!)
//                            }
//                            //self.imageCache.setObject(mediaItem.image, forKey: photoURL as AnyObject)
//
//                            self.collectionView.reloadData()
//
//                            guard key != nil else {
//                                return
//                            }
//                            self.photoMessageMap.removeValue(forKey: key!)
//                        }
//                    })
//                }
//            }
//        }
        
    }
    
    //MARK:-  Send Message Notification
    func sendMessageNotification(_ message:String, _ receiverId:String) {
        let user_id = LocalStore.store.getFacebookID()
        var parameters = Dictionary<String,Any>()
        parameters["sender_fb_id"] = user_id
        parameters["receiver_fb_id"] = receiverId
        parameters["message"] = message
        parameters["badge_count"] = String(format:"%d",Int(unread_count)! + 1)
        
        WebServices.service.webServicePostRequest(.post, .chat, .chatMessage, parameters, successHandler: { (response) in
            print(response ?? "")
            Loader.stopLoader()
        }) { (error) in
            Loader.stopLoader()
        }
    }
    
    func moveToPermanentList() {
        let user_id = LocalStore.store.getFacebookID()
        var parameters = Dictionary<String,Any>()
        parameters["user1_fb_id"] = user_id
        parameters["user2_fb_id"] = self.receiver_id!
        
        WebServices.service.webServicePostRequest(.post, .friend, .moveUserToPermanentList, parameters, successHandler: { (response) in
            print("Remove Match:",response as Any)
            Loader.stopLoader()
            
        }) { (error) in
            Loader.stopLoader()
        }
    }
    
    func removeFromNewMatches() {
        let user_id = LocalStore.store.getFacebookID()
        var parameters = Dictionary<String,Any>()
        parameters["user_fb_id"] = user_id
        parameters["request_sending_user_fb_id"] = self.receiver_id!
        parameters["action"] = "decline"
        
        WebServices.service.webServicePostRequest(.post, .friend, .acceptFriendRequest, parameters, successHandler: { (response) in
            print(response ?? "")
        }) { (error) in
            Loader.stopLoader()
        }
    }
    
    func updateReadUnreadMessages(_ messageItem: [String: Any]) {
        readUnreadRef = Database.database().reference().child("users").child(user_id).child("friends").child(self.receiver_id!).child("lastMessage")
        readUnreadRef?.setValue(messageItem)
       // finishSendingMessage()
    }
    
//MARK:-  Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK:-  IBAction Methods
    @IBAction func btnBack(_ sender: Any?){
        navigationController?.popViewController(animated: true)
    }

    @objc func blockOrWarnUser(){
        CustomClass.sharedInstance.playAudio(.popGreen, .mp3)
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let profile = UIAlertAction(title: "View Profile", style: .default) { (action: UIAlertAction) in
            //
            self.gotoProfileDetail()
        }
        actionSheet.addAction(profile)
        let conversation = UIAlertAction(title: "Delete Conversation", style: .default                         ) { (action: UIAlertAction) in
            let alert = UIAlertController(title:String(format:"Are you sure you want to delete the conversation. Deleting the conversation will remove %@ from your friendlist.",(self.friend?.name)!), message: nil, preferredStyle: .alert)
            let no = UIAlertAction(title: "No", style: .cancel) { (action: UIAlertAction) in
                
            }
            alert.addAction(no)
            let yes = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction) in
                FirebaseObserver.observer.deleteConversation(self.receiver_id!)
                self.removeFromNewMatches()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            alert.addAction(yes)
            self.present(alert, animated: true, completion: nil)
        }
        actionSheet.addAction(conversation)
        
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
        
        let action = UIAlertAction(title: "Block", style: .destructive) { (action: UIAlertAction) in
            let alert = UIAlertController(title:String(format:"Are you sure you want to block %@?",(self.friend?.name)!), message: nil, preferredStyle: .alert)
            let no = UIAlertAction(title: "No", style: .cancel) { (action: UIAlertAction) in
                
            }
            alert.addAction(no)
            let yes = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction) in
                
                FirebaseObserver.observer.deleteConversation(self.receiver_id!)
                
                let userId = LocalStore.store.getFacebookID()
                let blocked_user = self.receiver_id
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
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            alert.addAction(yes)
            self.present(alert, animated: true, completion: nil)
        }
        actionSheet.addAction(action)
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
        }
        actionSheet.addAction(action2)
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    func reportUser(reason: String) {
        FirebaseObserver.observer.deleteConversation(self.receiver_id!)
        
        let userId = LocalStore.store.getFacebookID()
        let report_user = self.receiver_id
        let parameters = ["user_fb_id": userId , "report_user_fb_id":report_user, "reason":reason, "reporting_to": "slindirapp@gmail.com"]
        
        WebServices.service.webServicePostRequest(.post, .report, .reportUser, parameters, successHandler: { (response) in
            let jsonDict = response
            let status = jsonDict!["status"] as! String
            if status == "success"{
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                //let message = jsonDict!["message"] as! String
                //self.showAlertWithOneButton("", message, "Ok")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        
    }
    
    func showMessageView(_ msg: String,_ messageData:[AnyHashable: Any]) {
        let snackbar = TTGSnackbar(message: msg,duration: .long)
        snackbar.backgroundColor = UIColor.init(red: 38/255, green: 166/255, blue: 175/255, alpha: 1)
        snackbar.messageTextColor = UIColor.white
        snackbar.messageTextFont = UIFont.init(name: "OpenSans-Semibold", size: 16)!
        snackbar.messageTextAlign = .center
        snackbar.contentInset = UIEdgeInsetsMake(40, 8, 20, 8)
        snackbar.topMargin = 0
        snackbar.leftMargin = 0
        snackbar.rightMargin = 0
        snackbar.animationType = .slideFromTopBackToTop
        snackbar.animationDuration = 0.8
        
        snackbar.onTapBlock = { snackbar in
            UserDefaults.standard.set(true, forKey: "chatNotification")
            UserDefaults.standard.synchronize()
            self.navigationController?.popViewController(animated: true)
            snackbar.dismiss()
        }
        
        snackbar.onSwipeBlock = { (snackbar, direction) in
            
            // Change the animation type to simulate being dismissed in that direction
            if direction == .right {
                snackbar.animationType = .slideFromLeftToRight
            } else if direction == .left {
                snackbar.animationType = .slideFromRightToLeft
            } else if direction == .up {
                snackbar.animationType = .slideFromTopBackToTop
            } else if direction == .down {
                snackbar.animationType = .slideFromTopBackToTop
            }
            
            snackbar.dismiss()
        }
        
        snackbar.show()
    }
}

//MARK:-  Want Help Visit Here: - https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2


//MARK:-  UIImagePickerController delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let photoRefernceUrl = info[UIImagePickerControllerReferenceURL] as? URL{
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoRefernceUrl], options: nil)
            let asset = assets.firstObject
            
            if let key = sendPhotoMessage(){
                
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, information) in
                    //let imageFileUrl = contentEditingInput?.fullSizeImageURL
                    let auth = "\(Auth.auth().currentUser!.uid)/"
                    let timeInterval = "\(Int64(Date.timeIntervalSinceReferenceDate * 1000))/"
                    let refernceUrl = "\(photoRefernceUrl.lastPathComponent)"
                    let path = auth + timeInterval + refernceUrl
                    let imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage] as! UIImage, 0.7)!
                        
                    self.storageRef.child(path).putData(imageData, metadata: nil, completion: { (metaData, error) in
                        if let err = error{
                            self.showAlertWithOneButton("Error!", err.localizedDescription, "OK")
                        }
                        else{
                            self.setImageURL(self.storageRef.child((metaData?.path)!).description, forPhotoMessageWithKey: (key.0!,key.1!))
                        }
                    })
                })
            }
        }else{
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if let (key,newKey) = sendPhotoMessage(){
                let imageData = UIImageJPEGRepresentation(image, 1)
                let time = Int64(Date.timeIntervalSinceReferenceDate * 1000)
                let imagePath = Auth.auth().currentUser!.uid + "\(time).jpg"
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                storageRef.child(imagePath).putData(imageData!, metadata: metaData, completion: { (metaData, error) in
                    if let err = error{
                        self.showAlertWithOneButton("Error!", err.localizedDescription, "OK")
                    }else{
                        self.setImageURL(self.storageRef.child((metaData?.path)!).description, forPhotoMessageWithKey: (key!,newKey!))
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
 }



//MARK:-  Want Help Visit Here: - https://www.raywenderlich.com/140836/firebase-tutorial-real-time-chat-2
