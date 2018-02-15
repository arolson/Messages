//
//  ChatViewController.swift
//  Messages
//
//  Created by Andrew Olson on 2/1/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    
    var messageDetail = [MessageDetail]()
    var blockedUsers = [BlockedUser]()
    var detail: MessageDetail!
    var currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    var recipient: String!
    var messageId: String!
    let cellIdentifier = "MessagesCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        removeBlockedUsers()
    }
    @IBAction func signOut(_ sender: Any) {
        try! Auth.auth().signOut()
        KeychainWrapper.standard.removeObject(forKey: DatabaseConstants.uid)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageDetail.count
    }
    
    //MARK: Cell For Row At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageDet = messageDetail[indexPath.row]
        if let cell = table.dequeueReusableCell(withIdentifier: cellIdentifier) as? MessagesDetailCell {
            cell.configureCell(messageDetail: messageDet)
            return cell
        } else {
            print("Error: ChatViewController; Messages Cell could not be configured")
            return MessagesDetailCell()
        }
    }
    
    //MARK: Did Select Row At Index
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipient = messageDetail[indexPath.row].recipient
        messageId = messageDetail[indexPath.row].messageRef.key
        performSegue(withIdentifier: SegueConstants.toMessages, sender: nil)
    }
    
    //MARK: Sliding Cells
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let recipient = messageDetail[indexPath.row].recipient
        let key = messageDetail[indexPath.row].messageKey
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.deleteConversation(key: key, recipient: recipient)
           tableView.reloadData()
        }
        delete.backgroundColor = .red
        
        let block = UITableViewRowAction(style: .normal, title: "Block") { action, index in
            print("Block button tapped")
            self.setBlockUser(recipient: recipient)
            self.deleteConversation(key: key, recipient: recipient)
            tableView.reloadData()
        }
        block.backgroundColor = .blue
        return [delete, block]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MessageViewController {
            // Set class variables for MessageViewController
            destinationVC.recipient = recipient
            destinationVC.messageId = messageId
        }
    }
}
extension ChatViewController {
    //MARK: Load Data
    func loadData() {
        let reference = Database.database().reference()
            .child(DatabaseConstants.users).child(currentUser!).child(DatabaseConstants.messages)
        reference.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.messageDetail.removeAll()
                for data in snapshot {
                    if let messageDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let info = MessageDetail(messageKey: key, messageData: messageDict)
                        self.messageDetail.append(info)
                    }
                }
            }
            self.filterBlockedUsers()
            self.table.reloadData()
        }
    }
    func filterBlockedUsers() {
        messageDetail = messageDetail.filter({ (messageDetail) -> Bool in
            return !(self.blockedUsers.contains(where:{$0.blockedUser == messageDetail.recipient}))
        })
    }
    func deleteConversation(key: String, recipient: String) {
        if let currentUserId = Auth.auth().currentUser?.uid {
            //1. Will need to delete from current user
            var currentUserReference = Database.database().reference().child(DatabaseConstants.users).child(currentUserId)
            currentUserReference = currentUserReference.child(DatabaseConstants.messages).child(key)
            currentUserReference.removeValue()
            
            //2. Delete from recipient
            var recipientReference = Database.database().reference().child(DatabaseConstants.users).child(recipient)
            recipientReference = recipientReference.child(DatabaseConstants.messages).child(key)
            recipientReference.removeValue()
            print("Conversation Successfully removed")
        }
    }
    func setBlockUser(recipient: String) {
        if let _ = Auth.auth().currentUser?.uid {
            let post =  recipient as AnyObject
            let blockedId = Database.database().reference().child(DatabaseConstants.users).child(currentUser!)
                                                           .child(DatabaseConstants.blocked).childByAutoId().key
            
            let firebaseMessage = Database.database().reference().child(DatabaseConstants.users).child(currentUser!)
                                                                 .child(DatabaseConstants.blocked).child(blockedId)
            firebaseMessage.setValue(post)
        }
    }
    private func removeBlockedUsers() {
        let reference = Database.database().reference()
            .child(DatabaseConstants.users).child(currentUser!).child(DatabaseConstants.blocked)
        reference.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.blockedUsers.removeAll()
                for data in snapshot {
                    if let blocked = data.value as? String {
                        let key = data.key
                        let info = BlockedUser(blockedKey: key, data: blocked)
                        self.blockedUsers.append(info)
                    }
                }
            }
            self.loadData()
        }
    }
}



















