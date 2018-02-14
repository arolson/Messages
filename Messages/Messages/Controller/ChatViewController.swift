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
        loadData()
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
        let mesageDet = messageDetail[indexPath.row]
        if let cell = table.dequeueReusableCell(withIdentifier: cellIdentifier) as? MessagesDetailCell {
            cell.configureCell(messageDetail: mesageDet)
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
            self.table.reloadData()
        }
    }
}



















