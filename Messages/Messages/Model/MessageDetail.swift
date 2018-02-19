//
//  MessageDetail.swift
//  Messages
//
//  Created by Andrew Olson on 2/1/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper


class MessageDetail {
    private var _recipient: String!
    private var _toDevice: String!
    private var _messageKey: String!
    private var _messageRef: DatabaseReference!
    
    var currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    var recipient: String {
        return _recipient
    }
    var toDevice: String {
        return _toDevice
    }
    var messageKey: String {
        return _messageKey
    }
    var messageRef: DatabaseReference {
        return _messageRef
    }
    
    init(recipient: String, toDevice: String) {
        _recipient = recipient
        _toDevice = toDevice
    }
    init(messageKey: String, messageData: Dictionary<String, AnyObject>) {
        _messageKey = messageKey
        guard let recipient = messageData[DatabaseConstants.recipient] as? String else {
            print("Could not get recipient")
            return
        }
        _recipient = recipient
        guard let toDevice = messageData[DatabaseConstants.fromDevice] as? String else {
            print("Could not get device")
            return
        }
        _toDevice = toDevice
        _messageRef = Database.database().reference().child(DatabaseConstants.recipient).child(_messageKey)
    }
}


























