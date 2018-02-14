//
//  MessageViewController.swift
//  Messages
//
//  Created by Andrew Olson on 2/2/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    let cellIdentifier = "MessageCell"
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var messageField: UITextView!
    // Text View constraint for resizing
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    var messageId: String!
    var messages = [Message]()
    var currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    var message: Message!
    var recipient: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        messageFieldConfig()
        if (messageId != nil && messageId != "") {
            loadData()
        }
        addTapGesture()
        dispatchAfter {
            self.moveToBottom()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func backAction(_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPressed (_ sender: AnyObject) {
        resetViews()
        
        if messageField.text != nil && messageField.text != "" {
            
            if messageId == nil {
                let post: Dictionary<String, AnyObject> = [
                    "message": messageField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                
                let message: Dictionary<String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                
                let recipientmessage: Dictionary<String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
                
                messageId = Database.database().reference().child(DatabaseConstants.messages).childByAutoId().key
                
                //Post
                postMessages(post: post)
                //User Messages
                UserMessages(post: message)
                //Recipient Message
                recipientMessages(post: recipientmessage)
                loadData()
                
            } else if messageId != "" {
                let post: Dictionary<String, AnyObject> = [
                    "message": messageField.text as AnyObject,
                    "sender": recipient as AnyObject
                ]
                let message: Dictionary<String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": recipient as AnyObject
                ]
                let recipientmessage: Dictionary<String, AnyObject> = [
                    "lastmessage": messageField.text as AnyObject,
                    "recipient": currentUser as AnyObject
                ]
        
                //Post
                postMessages(post: post)
                //User Messages
                UserMessages(post: message)
                //Recipient Message
                recipientMessages(post: recipientmessage)
                loadData()
            }
            messageField.text = ""
        }
        moveToBottom()
    }
    //MARK: Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //MARK: Cell For Row At Index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageCell {
            cell.configureCell(message: message)
            return cell
        } else {
            print("Error: MessageViewConroller; Message Cell could not be configured")
            return MessageCell()
        }
    }
   
    //MARK: TextView Delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if self.messageField.contentSize.height < self.textHeightConstraint.constant {
            self.messageField.isScrollEnabled = false
        } else {
            self.messageField.isScrollEnabled = true
        }
        return true
    }
}
extension MessageViewController {
    func configureViews() {
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableViewAutomaticDimension
        table.estimatedRowHeight = 350
        messageField.delegate = self
        messageField.layer.cornerRadius = 5
        messageField.layer.masksToBounds = true
    }
    func messageFieldConfig() {
        messageField.font = UIFont(name: "Arial", size: 18)
    }
    func resetViews() {
        //Reset the Message Field
        self.messageField.isScrollEnabled = false
        moveToBottom()
    }
    
    func loadData() {
        let reference = Database.database().reference().child(DatabaseConstants.messages).child(messageId)
        reference.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.messages.removeAll()
                for data in snapshot {
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let post = Message(messageKey: key, postData: postDict)
                        self.messages.append(post)
                    }
                }
            }
            self.table.reloadData()
        }
    }
    
    func moveToBottom () {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            table.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func postMessages(post: Dictionary<String, AnyObject>) {
        let firebaseMessage = Database.database().reference().child(DatabaseConstants.messages).child(messageId).childByAutoId()
        firebaseMessage.setValue(post)
    }
    
    func recipientMessages(post: Dictionary<String, AnyObject>) {
        let firebaseMessage = Database.database().reference().child(DatabaseConstants.users).child(recipient)
                                                             .child(DatabaseConstants.messages).child(messageId)
        firebaseMessage.setValue(post)
    }
    
    func UserMessages(post: Dictionary<String, AnyObject>) {

        let firebaseMessage = Database.database().reference().child(DatabaseConstants.users).child(currentUser!)
            .child(DatabaseConstants.messages).child(messageId)
        firebaseMessage.setValue(post)
    }
    func deleteConversation() {
        if let currentUserId = Auth.auth().currentUser?.uid {
            //1. Will need to delete from current user
            
            //2. Delete from recipient messages
            
        }
    }
}



























