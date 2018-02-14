//
//  MessagesDetailCell.swift
//  Messages
//
//  Created by Andrew Olson on 2/1/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper

class MessagesDetailCell: UITableViewCell {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chatPreview: UILabel!
    
    var messageDetail: MessageDetail!
    var userPostKey: DatabaseReference!
    let currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Configure Cell
    func configureCell(messageDetail: MessageDetail) {
        self.indicator.startAnimating()
        self.indicator.isHidden = false
        self.messageDetail = messageDetail
        let recipientData = Database.database().reference().child(DatabaseConstants.users).child(messageDetail.recipient)
        retrieveDataForCell(recipientData)
    }
    
    //Retrieve data for cell
    func retrieveDataForCell(_ recipientData: DatabaseReference) {
        recipientData.observeSingleEvent(of: .value) {
            (snapshot) in
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data[DatabaseConstants.username]
            let userImg = data[DatabaseConstants.userImg]
            
            self.nameLabel.text = username as? String
            if let messages = data[DatabaseConstants.messages] as? Dictionary<String, AnyObject> {
                if let message = messages[self.messageDetail.messageKey] {
                    if let lastMessage = message[DatabaseConstants.lastMessage] as? String {
                        self.chatPreview.text = lastMessage
                    }
                }
            }
            
            
            let ref = Storage.storage().reference(forURL: userImg as! String )
            ref.getData(maxSize: 1000000, completion: { (data, error) in
                if error != nil {
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                    print("Could not load image")
                } else {
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                                self.userImage.image = img
                                self.indicator.stopAnimating()
                                self.indicator.isHidden = true
                        }
                    }
                }
            })
        }
    }
    // Delete Chat
    func deleteChat() {
        // 1. Get the reference to the chat in the database
        let recipientData = Database.database().reference().child(DatabaseConstants.users).child(messageDetail.recipient)
        // 2. Delete the values associated with that chat
        recipientData.removeValue { (error, reference) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                print("Chat Deleted Correctly: \(reference)")
            }
        }
    }
}






























