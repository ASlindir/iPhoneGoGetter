 //
//  FirebaseObserver.swift
//  Slindir
//
//  Created by Gill on 12/13/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import Firebase
import TTGSnackbar
 
class FirebaseObserver: NSObject {
    //Firebase related variables
    var count = 0
    var friendArray = [[String: Any]]()
    
    let user_id = LocalStore.store.getFacebookID()
    var friendRef = Database.database().reference().child("messages")
    var userRef: DatabaseReference?
    private lazy var messageRef: DatabaseReference = self.friendRef
    private var newMessageRefHandle: DatabaseHandle?
    
    static let observer = FirebaseObserver()
    
    var firstLoad:Bool = false
    
    func observeMessages() {
        messageRef = friendRef.child(user_id)
        let messageQuery = messageRef.queryOrderedByKey()
        
        newMessageRefHandle = messageQuery.observe(.childChanged, with: { (snapshot) in
            let messages = NSMutableArray()
            let snapshotData = snapshot.value as! NSDictionary
            for i in 0..<snapshotData.allKeys.count {
                let message = snapshotData.allValues[i] as! NSDictionary
                let dtmp = message.value(forKey: "time") as! String
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd hh:mm:ss a"
                df.locale = Locale.init(identifier: "en_US_POSIX")
                let date = df.date(from: dtmp)
                if (date != nil){
                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                }
                let newMessage:NSMutableDictionary  = message as! NSMutableDictionary
                newMessage["time"] = date
                messages.add(newMessage as NSDictionary)
            }
            let sortDesc = NSSortDescriptor.init(key: "time", ascending: true)
            let ready = messages.sortedArray(using: [sortDesc])
            
            print(ready)
            
            print(messages)
            let messageData = ready.last as! NSDictionary
            
            let del = UIApplication.shared.delegate as! AppDelegate
            
            let dictData = NSKeyedArchiver.archivedData(withRootObject: messageData)
            UserDefaults.standard.setValue(dictData, forKey: "ChatUser")
            UserDefaults.standard.synchronize()
            
            if let id = messageData["senderId"] as? String, let name = messageData["senderName"] as? String, let text = messageData["text"] as? String , text.count > 0, (((messageData["photoURL"] as? String) == nil)) {
                if del.currentController.isKind(of: ChatViewController.self) {
                    if id != self.user_id{
                        UserDefaults.standard.set(true, forKey: "chatNotification")
                        UserDefaults.standard.synchronize()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatControllerNotification"), object: nil, userInfo: messageData as? [AnyHashable : Any])
                    }
                    else {
                        UserDefaults.standard.set(false, forKey: "chatNotification")
                        UserDefaults.standard.synchronize()
                    }
                }
                else {
                    self.showMessageView(String(format:"%@: %@",name, text), (messageData as? [AnyHashable : Any])!)
                }
            }
            else if let id = messageData["senderId"] as? String, let name = messageData["senderName"] as? String, let _ = messageData["photoURL"] as? String{
                if del.currentController.isKind(of: ChatViewController.self) {
                    if id != self.user_id{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatControllerNotification"), object: nil, userInfo: messageData as? [AnyHashable : Any])
                    }
                    else {
                        UserDefaults.standard.set(false, forKey: "chatNotification")
                        UserDefaults.standard.synchronize()
                    }
                }
                else {
                    self.showMessageView(String(format:"%@ has sent you a photo message.",name), messageData as! [AnyHashable : Any])
                }
            }
        })
    }
    
    func observeNewChat() {
        messageRef = friendRef.child(user_id)
        let messageQuery = messageRef.queryLimited(toLast: 1)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) in
            let snapshotData = snapshot.value as! NSDictionary
            print(snapshotData)
            if snapshotData.allValues.count > 1 {
                return
            }
            let messageData = snapshotData.allValues[0] as! [String: Any]
            
            if self.firstLoad {
                let del = UIApplication.shared.delegate as! AppDelegate
                let dictData = NSKeyedArchiver.archivedData(withRootObject: messageData)
                UserDefaults.standard.setValue(dictData, forKey: "ChatUser")
                UserDefaults.standard.synchronize()
                
                if let id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let text = messageData["text"] as! String! , text.count > 0{
                    if id != self.user_id{
                        if del.currentController.isKind(of: ChatViewController.self) {
                            UserDefaults.standard.set(true, forKey: "chatNotification")
                            UserDefaults.standard.synchronize()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatControllerNotification"), object: nil, userInfo: messageData as [AnyHashable : Any])
                        }
                        else {
                            self.showMessageView(String(format:"%@: %@",name, text), messageData )
                        }
                    }
                }
                else if let id = messageData["senderId"] as! String!, let name = messageData["senderName"] as! String!, let _ = messageData["photoURL"] as! String!{
                    if id != self.user_id{
                        if del.currentController.isKind(of: ChatViewController.self) {
                            UserDefaults.standard.set(true, forKey: "chatNotification")
                            UserDefaults.standard.synchronize()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatControllerNotification"), object: nil, userInfo: messageData)
                        }
                        else {
                            self.showMessageView(String(format:"%@ has sent you a photo message.",name), messageData)
                        }
                    }
                }
            }
            self.firstLoad = true
            print(messageData)
        })
    }
    
    func observeFriendList(){
        self.friendArray.removeAll()
        let friendRefer: DatabaseReference = Database.database().reference().child("users")
       let userRef1: DatabaseReference? = friendRefer.child(user_id).child("friends")
        
        newMessageRefHandle = userRef1?.observe(.childAdded, with: { (snapshot) in
            let friendData = snapshot.value
            
            if let data = friendData as? [String: Any] {
                if !self.friendArray.contains(where: { (friend) -> Bool in
                    friend["id"] as? String == data["id"] as? String
                }){
                    self.friendArray.append(data)
                    self.observeOnline()
                }
            }
           // print(friendData!)
            
        })
    }
    
     func observeOnline() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        connectedRef.observe(.value, with: { snapshot in
            // only handle connection established (or I've reconnected after a loss of connection)
            guard let connected = snapshot.value as? Bool, connected else { return }
            
            if self.count < self.friendArray.count {
                let firstObject = self.friendArray[self.count]
                self.count = self.count + 1
                if let idFirst = firstObject["id"] as? String {
                    let myConnectionsRef = Database.database().reference(withPath: String(format:"users/%@/friends/\(self.user_id)",idFirst))
                    //let lastOnlineRef = Database.database().reference(withPath: String(format:"users/%@/friends/\(self.user_id)",firstObject["id"] as! CVarArg))
                    
                    // add this device to my connections list
                    let con = myConnectionsRef.child("online")
                    
                    // when this device disconnects, remove it.
                    con.onDisconnectRemoveValue()
                    
                    // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
                    // where you set the user's presence to true and the client disconnects before the
                    // onDisconnect() operation takes effect, leaving a ghost user.
                    
                    // this value could contain info about the device or a timestamp instead of just true
                    con.setValue(true)
                   // con.onDisconnectSetValue(false)
                    // when I disconnect, update the last time I was seen online
                    //lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
                }
                
            }
        })
    }
    
    func observeFriendsRemoved(){
        let friendRef: DatabaseReference = Database.database().reference().child("users")
        userRef = friendRef.child(user_id).child("friends")
        
        newMessageRefHandle = userRef?.observe(.childRemoved, with: { (snapshot) in
            let friendData = snapshot.value as! Dictionary<String, Any>
            print("Friends :- ",friendData)
            if let name = friendData["name"] as! String!, name.count > 0{
                if friendData["id"] as? String == self.user_id{
                }else{
                    if let index = self.friendArray.index(where: { (friend) -> Bool in
                        friend["id"] as? String == friendData["id"] as? String
                    }) {
                        self.friendArray.remove(at: index)
                    }
                }
            }
        })
    }
    
    func deleteConversation(_ receiver_id:String)  {
        let chatId = "\(self.user_id)_\(receiver_id)"
        let reciverChatId = "\(receiver_id)_\(self.user_id)"
        
        let chatref = self.friendRef.child(self.user_id).child(chatId)
        let newItemRef = self.friendRef.child(receiver_id).child(reciverChatId)
        
        let userRef = Database.database().reference().child("users").child(self.user_id).child("friends").child(receiver_id)
        let userRef1 = Database.database().reference().child("users").child(receiver_id).child("friends").child(self.user_id)
        
        chatref.removeValue()
        newItemRef.removeValue()
        userRef.removeValue()
        userRef1.removeValue()
    }
    
    func deleteFirebaseAccount() {
        for i in 0..<self.friendArray.count {
            print(self.friendArray[i])
            if let idFriend = self.friendArray[i]["id"] as? String {
                self.deleteConversation(idFriend)
            }
        }
        self.deleteUser()
    }
    
    func deleteUser()  {
        let userRef = Database.database().reference().child("users").child(self.user_id)
        userRef.removeValue()
    }
    
    func showMessageView(_ msg: String,_ messageData:[AnyHashable: Any]) {
        let del = UIApplication.shared.delegate as! AppDelegate

        let snackbar = TTGSnackbar(message: msg,duration: .long)
        snackbar.backgroundColor = UIColor.init(red: 38/255, green: 166/255, blue: 175/255, alpha: 1)
        snackbar.messageTextColor = UIColor.white
        snackbar.messageTextFont = UIFont.init(name: "OpenSans-Semibold", size: 16)!
        snackbar.messageTextAlign = .center
        snackbar.contentInset = UIEdgeInsets.init(top: 40, left: 8, bottom: 20, right: 8)
        snackbar.topMargin = 0
        snackbar.leftMargin = 0
        snackbar.rightMargin = 0
        snackbar.animationType = .slideFromTopBackToTop
        snackbar.animationDuration = 0.8
        
        snackbar.onTapBlock = { snackbar in
            if del.currentController.isKind(of: ProfileViewController.self) {
                UserDefaults.standard.set(true, forKey: "chatNotification")
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatNotification"), object: nil, userInfo: messageData)
                
            }else if del.currentController.isKind(of: ListViewController.self){
                UserDefaults.standard.set(true, forKey: "chatNotification")
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatListNotification"), object: nil, userInfo: messageData)
                
            }else if del.currentController.isKind(of: EditProfileViewController.self) {
                UserDefaults.standard.set(true, forKey: "chatNotification")
                UserDefaults.standard.synchronize()
                del.currentController.viewWillAppear(true)
            }
            else if del.currentController.isKind(of: ProfileDetaiViewController.self) {
                UserDefaults.standard.set(true, forKey: "chatNotification")
                UserDefaults.standard.synchronize()
                let listCont = del.currentController.navigationController?.viewControllers[(del.currentController.navigationController?.viewControllers.count)! - 3]
                del.currentController.navigationController?.popToViewController(listCont!, animated: true)
            }
            else {
                UserDefaults.standard.set(true, forKey: "chatNotification")
                UserDefaults.standard.synchronize()
                del.currentController.dismiss(animated: false, completion: nil)
            }
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
