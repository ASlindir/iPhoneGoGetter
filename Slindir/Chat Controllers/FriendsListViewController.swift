//
//  FriendsListViewController.swift
//  Slindir
//
//  Created by Gurinder Batth on 24/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

//MARK:-  Outlets, Variables and Constants
    @IBOutlet weak var tableView: UITableView?
    
    var senderDisplayName: String? 
    
    var newChannelTextField: UITextField?
    
    private var friends: [Friend] = []
    
    private lazy var friendRef: DatabaseReference = Database.database().reference().child("friends")
    private var friendRefHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.friends.removeAll()
        observeFriends()
        tableView?.reloadData()
    }
    deinit {
        if let refHandle = friendRefHandle{
            friendRef.removeObserver(withHandle: refHandle)
        }
    }
    
//MARK:-  UITableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resuseIdentifier = "ExistingChannel"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier, for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].name
        return cell
    }
    
//MARK:-  UITableView Delegates
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView?.deselectRow(at: indexPath, animated: true)
            let friend = friends[indexPath.row]
            self.performSegue(withIdentifier: "ShowChat", sender: friend)
    }
//MARK:-  Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let friend = sender as? Friend{
            let chatController = segue.destination as! ChatViewController
            chatController.navigationController?.navigationBar.isHidden = false
            chatController.senderDisplayName = senderDisplayName
            chatController.friend = friend
            chatController.friendRef = friendRef.child(friend.id)
        }
    }
//MARK:- IBAction Methods
    @IBAction func createFriend(_ sender: Any?){
        if let name = newChannelTextField?.text{
            let newFriendRef = friendRef.childByAutoId()
            let friendItem = [
                "name": name
            ]
            newFriendRef.setValue(friendItem)
        }
    }
    
//MARK:-  Firebase Related Methods
    private func observeFriends(){
        friendRefHandle = friendRef.observe(.childAdded, with: { (snapshot) in
            let friendData = snapshot.value as! Dictionary<String, Any>
            print("Friends :- ",friendData)
            let id = snapshot.key
            if let name = friendData["name"] as! String!, name.characters.count > 0{
                let user_id = LocalStore.store.getFacebookID()
                if friendData["id"] as? String == user_id{
                        
                }else{
                    if let lastMessage = friendData["lastMessage"] as? [String: Any]{
                       // self.friends.append(Friend(id: id, name: name, lastMessage:lastMessage))
                    }else{
                       // self.friends.append(Friend(id: id, name: name, lastMessage:nil))
                    }
                    self.tableView?.reloadData()
                }
            }
        })
    }
    
    @IBAction func btnBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
//MARK:-  Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class CreateChannelCell: UITableViewCell {
    
    @IBOutlet weak var newChannelNameField: UITextField!
    @IBOutlet weak var createChannelButton: UIButton!
    
}

