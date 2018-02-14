//
//  MessageCell.swift
//  Messages
//
//  Created by Andrew Olson on 2/3/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class MessageCell: UITableViewCell {
    @IBOutlet weak var recievedMessageLabel: UILabel!
    @IBOutlet weak var recievedMessageView: UIView!
    @IBOutlet weak var sentMessageLabel: UILabel!
    @IBOutlet weak var sentMessageView: UIView!
    
    var message: Message!
    var currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Configure Cell
    func configureCell(message: Message) {
        self.message = message
        if message.sender == currentUser {
            sentMessage(message)
        } else {
            recievedMessage(message)
        }
    }
    
    //Configure cell for sent messages
    func sentMessage(_ message: Message) {
        //View
        sentMessageView.isHidden = false
        sentMessageView.layer.cornerRadius = 5
        sentMessageView.layer.masksToBounds = true
        //Label
        sentMessageLabel.text = message.message
        sentMessageLabel.isHidden = false
        //Recieved
        recievedMessageLabel.text = ""
        recievedMessageLabel.isHidden = true
        recievedMessageView.isHidden = true
    }
    
    //Configure cell for recieved messages
    func recievedMessage(_ message: Message) {
        //View
        recievedMessageView.isHidden = false
        recievedMessageView.layer.cornerRadius = 5
        recievedMessageView.layer.masksToBounds = true
        
        //Label
        recievedMessageLabel.text = message.message
        recievedMessageLabel.isHidden = false
        recievedMessageLabel.textColor = .white
        //Sent
        sentMessageView.isHidden = true
        sentMessageLabel.text = ""
        sentMessageLabel.isHidden = true
    }
}
