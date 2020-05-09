//
//  ListViewController.swift
//  GoGetter
//
//  Created by Gurinder Batth on 31/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class ChatListViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var heightNavigation: NSLayoutConstraint!
    @IBOutlet weak var collectionViewNewMatches: UICollectionView!
    
    @IBOutlet weak var leadingCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewMessages: UITableView!
    
    var headerFriendsList = [Dictionary<String, Any>]()
    var bodyFriendsList = [Dictionary<String, Any>]()
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
    
    var doHeaderToBodyAnimation : Bool = false
    var animatingItem : Int = -1

    var userNewId: String? = nil
    var leadingCollectionConstraintDefault: CGFloat = 0.0
    var bottomCollectionViewConstraintDefault: CGFloat = 0.0
    var isAnimateFirstItem: Bool = false
    var isAnimateFirstItemInTable: Bool = false
    
    var purchase: [PurchaseViewController.PurchaseItem] = []
    var purchasePrompt: String? = nil
    var purchaseScreenAction: Int = 0
    var purchaseConvoId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(chatNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("chatListNotification")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMatchNotificationRecived), name: NSNotification.Name(rawValue: NSNotification.Name.RawValue("newMatchListNotification")), object: nil)

        if UIScreen.main.bounds.size.height >= 812 {
            self.heightNavigation.constant = 100
            self.view.layoutIfNeeded()
        }
        
        getDetails()
        
        // constraints
        self.leadingCollectionConstraintDefault = self.leadingCollectionViewConstraint.constant
        self.bottomCollectionViewConstraintDefault = self.bottomCollectionViewConstraint.constant
        
        // test
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.animationAddItemToCollection()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            observeFriendsAdded()
            observeFriendsRemoved()
            observeOnlineFriends()
            tableViewMessages.reloadData()
            checkMatchNotifications(isCHeckUser: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let del:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        del.currentController = self
        self.friends.removeAll()
        getFriendsList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UserDefaults.standard.set(false, forKey: "chatNotification")
        UserDefaults.standard.synchronize()
        userRef?.removeObserver(withHandle: friendRefHandle!)
    }
    
    func checkMatchNotifications(isCHeckUser: Bool = false) {
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
                self.createNewFriendOnFirebase(userOtherDict!, isOpenChat: !isCHeckUser)
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
    func getPercentComplete(matchDateStr : String) -> CGFloat{
    let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        let matchDate: Date? = dateFormatter.date(from: matchDateStr)
        print(Calendar.current.dateComponents([.second], from: matchDate!, to: Date()).second ?? 0)
        let time = Calendar.current.dateComponents([.second], from: matchDate!, to: Date()).second ?? 0
        // time is in secs
        let percComplete = (CGFloat(time)/CGFloat(172800))
        if (percComplete > 1){
            return CGFloat(1)
        }
        else{
            return percComplete * CGFloat(100)
        }
    }

        @objc func doConvoBeginPurchase(friend : Dictionary<String, Any>, whichList : Int){
           
           let userTo = friend["user_fb_id"] as! String
           
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
                    if self.purchaseScreenAction == PurchasesConst.ScreenAction.BUY_CONVO.rawValue {
                        
                        
                        let purchaseViewController = PurchaseViewController.loadFromNib()
    //              fhc      purchaseViewController.delegate = self
                        purchaseViewController.products = self.purchase
                        purchaseViewController.prompt = self.purchasePrompt
                        purchaseViewController.convoId = self.purchaseConvoId
                        purchaseViewController.userId = userTo
    //                    purchaseViewController.userId = LocalStore.store.getFacebookID()
                        purchaseViewController.chatListViewController = self
                        purchaseViewController.profileDelegate = nil
                        self.doHeaderToBodyAnimation = false
                        self.navigationController?.pushViewController(purchaseViewController, animated: true)
    // fhc
                        
    //                    let controller = ReservePurchaseViewController.loadFromNib()
    //                    controller.userId = LocalStore.store.getFacebookID()
    //                    controller.isPinkName = whichList == 0 ? true : false
    //                    controller.didGoHandler = {userId in
    //                        self.DoPurchaseConversation(friend : friend, whichList: whichList)
    //                    }
    //                    self.present(controller, animated: true, completion: nil)
                    }
                    else if self.purchaseScreenAction == PurchasesConst.ScreenAction.BUY_COINS.rawValue {
                        
                    }
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
        

//MARK:-  UICollection View Data Sources

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.friendsList.count
        return self.headerFriendsList.count
    }

    func showHeaderToBodyAnimation(cell : NewMatchesCollectionViewCell, indexPath : IndexPath){
        cell.circleView.shapeColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)
//        self.animationAddItemToTable()

        let copiedView: UIView = cell.circleView.copyView()

        copiedView.center.x = CGFloat((indexPath.item + 1) * 105 - 105 / 2 + 10)
        copiedView.center.y = 198
        copiedView.layer.zPosition = 1000

        //                    copiedView.frame.origin = self.view.convert(cell.circleView.frame.origin, to: nil)

        copiedView.isHidden = false
        self.view.addSubview(copiedView)
        cell.circleView.isHidden = true

        let item = headerFriendsList[indexPath.item]
        self.headerFriendsList.remove(at: indexPath.item)
        self.collectionViewNewMatches.deleteItems(at: [indexPath])
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
          copiedView.center.x = cell.contentView.frame.width / 2
          copiedView.center.y = 390
        }, completion: {finished in
          self.animatingItem = -1
          self.doHeaderToBodyAnimation = false
          self.collectionViewNewMatches.reloadData()
          copiedView.removeFromSuperview()
          self.isAnimateFirstItemInTable = false
          self.tableViewMessages.reloadData()
        })

//        cell.circleView.addCircle(0)
    }
    // render a single match circle in the top of the view controller
    // this contains 'nobody paid' 3 and 'theypaid' entries 0
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMatchesCell", for: indexPath) as! NewMatchesCollectionViewCell
//        let name = friendsList[indexPath.row]["user_name"] as! String
       
        let friend = headerFriendsList[indexPath.item] as Dictionary<String, Any>
        
        if let profile_pic = friend["profile_pic"] as? String {
            cell.circleView.imageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profile_pic)), placeholderImage: UIImage.init(named: "placeholder"))
        }
    
        cell.circleView.tapHandler = nil
        cell.circleView.indexPath = indexPath
        // 0 they paid, 1 ipaid, 2bothpaid, 3neither paid
        let whichList = friend["which_list"] as! Int
        let match_created_on = friend["match_created_on"] as! String
        switch whichList {
            case 0:
                cell.circleView.shapeColor = UIColor(red:0.94, green:0.37, blue:0.65, alpha:1.0) // pink, they paid
            case 3:
                cell.circleView.shapeColor = UIColor(red:0.66, green:0.66, blue:0.66, alpha:1.0) // gray neither paid
            default:
                NSLog("error bad which value")
        }
        
        cell.circleView.addCircle(getPercentComplete(matchDateStr: match_created_on))
        cell.circleView.tapHandler = {circleView in
            self.animatingItem = circleView.indexPath!.item // index of item to animate when we return
           circleView.animationClick(completion: {
               self.doConvoBeginPurchase(friend: friend, whichList: whichList)
           })
        }
        if doHeaderToBodyAnimation {
            if indexPath.item == animatingItem {
                // we came back to the chatlist after purchasing
                // animate to body
                DispatchQueue.main.async {
//                    self.animationAddItemToTable()
                    self.showHeaderToBodyAnimation(cell:cell,  indexPath: indexPath)
                }

            }
        }
//        cell.circleView.shapeColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)  //neither paid gray

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
        return CGSize(width: 105, height: 105)
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
        return bodyFriendsList.count
    }
    
    
    // boyd friends are eitehr bothpaid 2 or ipaid 1
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MessagesTableViewCell
        
        
        let friend = bodyFriendsList[indexPath.item] as Dictionary<String, Any>
        
        let profile_pic = friend["profile_pic"] as? String

        cell.circleView.tapHandler = nil
        
        // 0 they paid, 1 ipaid, 2bothpaid, 3neither paid
        let whichList = friend["which_list"] as! Int
        let match_created_on = friend["match_created_on"] as! String
        switch whichList {
        case 1:
            cell.circleView.shapeColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0) // blue, i paid, no action just waiting
            cell.circleView.tapHandler = {circleView in
//                self.animationAddItemToTable()
            }
        case 2:
            cell.circleView.shapeColor = UIColor.white // both paid white // should never see in header!
            if doHeaderToBodyAnimation {
                     animationAddItemToTable()
                     doHeaderToBodyAnimation = false;
            }
            cell.circleView.tapHandler = {circleView in
            let friendItem = self.friends[indexPath.item]
            self.goToChatController(friendItem, friendItem.id)
            }
        default:
            NSLog("error bad which value")
        
        }
        cell.circleView.addCircle(getPercentComplete(matchDateStr: match_created_on))

        let fname = friend["user_name"] as? String
        cell.lblName.text = fname
        cell.imgViewProfile.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profile_pic!)), placeholderImage: UIImage.init(named: "placeholder"))
        cell.lblMessage.text = ""
        cell.circleLabel.text = ""
        cell.circleView.imageView.sd_setImage(with: URL(string:String(format:"%@%@", mediaUrl, profile_pic!)), placeholderImage: UIImage.init(named: "placeholder"))
        cell.circleLabel.textColor = UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)
        if friend["which_list"] as! Int ==  1{
            cell.circleLabel.text = "Pending "+fname!+"'s activation ..."
        }
        else{ // both paid, official friend
//            let r = indexPath.row.
            if friends.indices.contains(indexPath.row){
                if !friends[indexPath.row].online {
                    cell.imgViewNewMessage.backgroundColor = UIColor.gray
                }
                else {
                    cell.imgViewNewMessage.backgroundColor = UIColor.init(red: 38/255, green: 166/255, blue: 175/255, alpha: 1)
                }
            }
            else{
                cell.imgViewNewMessage.backgroundColor = UIColor.init(red: 38/255, green: 166/255, blue: 175/255, alpha: 1)
            }
            cell.lblMessage.font = UIFont.init(name: "OpenSans-Regular", size: 16)
            if friends.indices.contains(indexPath.row){
                if let lastMessageDict = friends[indexPath.row].lastMessage{
                    let lastMessage = lastMessageDict["text"] as? String
                    cell.lblMessage.text = lastMessage?.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let unread = lastMessageDict["unread"] as? String {
                        if unread == "1" {
                            cell.lblMessage.font = UIFont.init(name: "OpenSans-Bold", size: 16)
                        }
                    }
                }
            }
        }
        cell.imgViewProfile.layer.cornerRadius = 42.5
        
        if self.isAnimateFirstItemInTable && indexPath.item == 0 {
            cell.contentView.isHidden = true
        } else {
            cell.contentView.isHidden = false
        }
        
        // test
//        if self.friends.count > 1 && indexPath.item == 0 {
//            cell.circleView.isHidden = false
//            cell.circleLabel.isHidden = false
//
//            cell.imgViewProfile.isHidden = true
//            cell.lblName.isHidden = true
//            cell.lblMessage.isHidden = true
//            cell.imgViewNewMessage.isHidden = true
//            cell.borderLabel.isHidden = true
//
//            cell.circleLabel.alpha = 0
//
//            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
//                cell.circleLabel.alpha = 1
//            }, completion: nil)
//        } else {
//            cell.circleView.isHidden = true
//            cell.circleLabel.isHidden = true
//
//            cell.imgViewProfile.isHidden = false
//            cell.lblName.isHidden = false
//            cell.lblMessage.isHidden = false
//            cell.imgViewNewMessage.isHidden = false
//            cell.borderLabel.isHidden = false
//        }
        
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
    
    func animationAddItemToCollection() {
        self.isAnimateFirstItem = true
        self.friendsList.append(LocalStore.store.getUserDetails())
        
        self.leadingCollectionViewConstraint.constant = self.leadingCollectionConstraintDefault + 105
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
        }, completion: {res in
            self.leadingCollectionViewConstraint.constant = self.leadingCollectionConstraintDefault
//            self.friendsList = [nil] + self.items
//            self.collectionViewNewMatches.reloadData()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                if let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TestPurchaseCollectionViewCell {
//
//                    //                      UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
//                    //                        self.imageVIew.alpha = 0.0
//                    //                    }) { _ in print("Animation Done") }
//
//                    let perc: CGFloat = 10.0
//
//                    cell.mainImage.addCircle(perc)
//                    cell.mainImage.isHidden = false
//                    cell.layer.zPosition = 1000
//
//                    cell.mainImage.animationHide(completion: {
//                        self.items[0] = perc
//                        self.collectionView.reloadData()
//                    })
//                }
//            }
            
            self.collectionViewNewMatches.reloadData()
        })
    }
    
    func addToFriends(friendDict : Dictionary<String, Any>){
        let idSelf = self.user_id
        var nameSelf = ""
        var profilePicSelf = ""
        if let myName = personalDetail["user_name"] as? String {
            nameSelf = myName
        }
        if let myProfilePic = personalDetail["profile_pic"] as? String {
            profilePicSelf = myProfilePic
        }
        let id = friendDict["user_fb_id"] as! String
        var name = ""
        var profilePic = ""
        if let friendname = friendDict["user_name"] as? String {
            name = friendname
        }
        if let profilePicFriend = friendDict["profile_pic"] as? String {
            profilePic = profilePicFriend
        }
        self.friends.insert(Friend(id: idSelf, name: nameSelf, profilePic: profilePicSelf, lastMessage: nil, online: false), at: 0)
    }
    func animationAddItemToTable() {
        self.isAnimateFirstItemInTable = true

        let friendDict = LocalStore.store.getUserDetails()
        addToFriends(friendDict: friendDict)
        self.bottomCollectionViewConstraint.constant = self.leadingCollectionConstraintDefault + 105
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
        }, completion: {res in
            self.leadingCollectionViewConstraint.constant = self.leadingCollectionConstraintDefault
//            self.collectionViewNewMatches.reloadData()
        })
        
//        self.tableViewMessages.beginUpdates()
//        self.tableViewMessages.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        self.tableViewMessages.endUpdates()
    }

 
//MARK:-  Get Friends List
    // validate that 48 hour time has not expired
    func checkMatchExpired(dict : Dictionary<String,Any>)-> Bool{
        if let matchDateStr = dict["match_created_on"] as? String {
           if matchDateStr != "" {
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
               dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
               dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
               let matchDate: Date? = dateFormatter.date(from: matchDateStr)
               print(Calendar.current.dateComponents([.second], from: matchDate!, to: Date()).second ?? 0)
               let time = Calendar.current.dateComponents([.second], from: matchDate!, to: Date()).second ?? 0
               //604800
               if CGFloat(time) > 172800 {// 48 hours as seconds
                   self.removeFromNewMatches(dict["user_fb_id"] as! String)
                    return true // expired
               }
               else {
                   self.friendsList.append(dict)
               }
           }
           else{
               self.removeFromNewMatches(dict["user_fb_id"] as! String)
               return true // expired
           }
       }
        return false
    }
     func LoadHeaderObjects(dict : Dictionary<String, Any>?, collectionName : String, whichList : Int){
          var cc = false
          if let collFriendList = dict![collectionName] as? [Dictionary<String, String>] {
              for  f in collFriendList  {
                  cc = true
                  var item =  Dictionary<String, Any>()
                  item["user_name"] = f["user_name"]
                  item["user_fb_id"] = f["user_fb_id"]
                  item["profile_pic"] = f["profile_pic"]
                  item["match_created_on"] = f["match_created_on"]
                  item["which_list"] = whichList
                  if ( !self.checkMatchExpired(dict : item)){
                      if whichList == 0 || whichList == 3{
                          headerFriendsList.append(item)
                      }
                      else{
                        bodyFriendsList.append(item)
                        if (whichList == 2){ // full friends
                            addToFriends(friendDict: item)
                        }
                      }
                  }
    //              arrayChatListHeaderModals.add(chatListHeaderModal);
              }
              //                chatListAdapter.notifyDataSetChanged();
          }
        return
      }
func getFriendsList(){
        
        // test
//        for index in 0..<10 {
//            self.friendsList.append(LocalStore.store.getUserDetails())
//        }
        
        self.collectionViewNewMatches.reloadData()
//        print(self.friendsList)
        
        // original
        let user_id = LocalStore.store.getFacebookID()
        let parameters = ["user_fb_id": user_id, "type":"new"]

        Loader.startLoader(true)
        WebServices.service.webServicePostRequest(.post, .friend, .fetchFriendList, parameters, successHandler: { (response) in
            Loader.stopLoader()
            self.bodyFriendsList.removeAll()
            self.headerFriendsList.removeAll()
            self.friends.removeAll()
            let jsonDict = response
            let status = jsonDict!["status"] as! String
            self.friendsList.removeAll()
            if status == "success"{
                self.LoadHeaderObjects(dict: jsonDict, collectionName: "iPaid", whichList: 1)
                self.LoadHeaderObjects(dict: jsonDict, collectionName: "bothPaid", whichList: 2)
                self.LoadHeaderObjects(dict: jsonDict, collectionName: "theyPaid", whichList: 0)
                self.LoadHeaderObjects(dict: jsonDict, collectionName: "neitherPaid", whichList: 3)
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

    func createNewFriendOnFirebase(_ friendDict:[String:Any], isOpenChat: Bool = true) {
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
                if isOpenChat {
                    self.goToChatController(friend!,id)
                }
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
