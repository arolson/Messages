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
import Alamofire

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var messageField: UITextView!
    // Text View constraint for resizing
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    var messageId: String!
    var messages = [Message]()
    var currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    var message: Message!
    var recipient: String!
    var toDevice = ""
    let cellIdentifier = "MessageCell"
    var badgeNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup views for display
        configureViews()
        // Load tokens if they have not been already
        loadTokens()
        //Load Message data if not a new message
        if (messageId != nil && messageId != "") {
            loadData()
        }
        // Tap gesture for keyboard
        addTapGesture()
        // Move to the latest message
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
        // Reset the Message Field
        resetViews()
        if messageField.text != nil && messageField.text != "" {
            
            if messageId == nil {
                //Set message Id
                messageId = Database.database().reference().child(DatabaseConstants.messages).childByAutoId().key
                //Post
                postMessages()
                //User Messages
                UserMessages()
                //Recipient Message
                recipientMessages()
                loadData()
            } else if messageId != "" {
                //Post
                postMessages()
                //User Messages
                UserMessages()
                //Recipient Message
                recipientMessages()
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
         messageField.font = UIFont(name: "Arial", size: 17)
    }

    func resetViews() {
        //Reset the Message Field
        self.messageField.isScrollEnabled = false
        moveToBottom()
    }
    
    // Load tokens if they have not been already
    func loadTokens() {
        if toDevice == "" {
            loadtoDeviceToken()
            print("toDevice: \(toDevice)")
        }
        
        if AppDelegate.deviceId == "" {
            loadFromDeviceToken()
            print("AppDelegate: \(AppDelegate.deviceId)")
        }
    }
    
    // load recipient device token
    func loadtoDeviceToken() {
        let reference = Database.database().reference().child(DatabaseConstants.users).child(recipient).child(DatabaseConstants.fromDevice)
        reference.observe(.value) { (snapshot) in
            if snapshot.exists() {
                if let deviceToken = snapshot.value as? String {
                    self.toDevice = deviceToken
                } else {
                    self.toDevice = ""
                    print("toDevice Token is empty")
                }
            } else {
                print("Did not find token for toDevice")
            }
        }
    }
    
    // Load currentUser device token
    func loadFromDeviceToken() {
        let reference = Database.database().reference().child(DatabaseConstants.users).child(currentUser!)
        reference.observe(.value) { (snapshot) in
            if snapshot.exists() {
                if let deviceToken = snapshot.value as? String {
                    AppDelegate.deviceId = deviceToken
                }
            } else {
                print("Did not find token for Appdeleget.deviceId")
            }
        }
    }
    
    /*
     Mark: Load Messages from Messages database
     Reference: Messages -> messageId
     */
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
    
    /*
     MARK: Post Message
     Reference: Messages -> messageId -> new child
     */
    func postMessages() {
        let post: Dictionary<String, AnyObject> = [
            "message": messageField.text as AnyObject,
            "sender": recipient as AnyObject,
            DatabaseConstants.fromDevice : AppDelegate.deviceId as AnyObject,
            DatabaseConstants.toDevice : toDevice as AnyObject
        ]
        
        let firebaseMessage = Database.database().reference().child(DatabaseConstants.messages).child(messageId).childByAutoId()
        firebaseMessage.setValue(post)
        setupPushNotifications(fromDevice: AppDelegate.deviceId)
    }
    
    /*
     MARK: User Message
     Reference: users -> currentUser -> messages -> messagesId
     */
    func UserMessages() {
        let message: Dictionary<String, AnyObject> = [
            "lastmessage": messageField.text as AnyObject,
            "recipient": recipient as AnyObject,
            DatabaseConstants.fromDevice : AppDelegate.deviceId as AnyObject,
            DatabaseConstants.toDevice : toDevice as AnyObject
        ]
        
        let firebaseMessage = Database.database().reference().child(DatabaseConstants.users).child(currentUser!)
            .child(DatabaseConstants.messages).child(messageId)
        firebaseMessage.setValue(message)
    }
    
    /*
     MARK: Recipient Message
     Reference: users -> recipient -> messages -> messagesId
     Note: Mirror of User Messages
     */
    func recipientMessages() {
        let recipientmessage: Dictionary<String, AnyObject> = [
            "lastmessage": messageField.text as AnyObject,
            "recipient": currentUser as AnyObject,
            DatabaseConstants.fromDevice : toDevice as AnyObject,
            DatabaseConstants.toDevice : AppDelegate.deviceId as AnyObject
        ]
        
        let firebaseMessage = Database.database().reference().child(DatabaseConstants.users).child(recipient)
                                                             .child(DatabaseConstants.messages).child(messageId)
        firebaseMessage.setValue(recipientmessage)
    }
    
    // Move tableView to most recent message
    func moveToBottom () {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            table.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
}
//MARK: Push Notifications
extension MessageViewController {
    func setupPushNotifications(fromDevice: String) {
        if self.toDevice == "" {return}
        guard let message = messageField.text else {return}
        
        let title = "Message"
        let body = message
        let toDevice = self.toDevice
        badgeNumber += 1
        
        var header: HTTPHeaders = HTTPHeaders()
        header = ["Content-Type":"application/json", "Authorization" : "key=\(AppDelegate.server_key)"]
        
        let notification = ["to": "\(toDevice)", "notification":
                ["body":body, "title":title,"badge": badgeNumber,"sound":"default"]
            ] as [String : Any]
        Alamofire.request(AppDelegate.notification_url as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            print(response)
        }
    }
}

























