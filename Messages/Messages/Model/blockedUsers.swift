//
//  blockedUsers.swift
//  Messages
//
//  Created by Andrew Olson on 2/14/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class BlockedUser {
    private var _blockedUser: String!
    private var _blockedKey: String!
    private var _blockedRef: DatabaseReference!
    var currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    
    init(blockedKey: String, data: String) {
        _blockedKey = blockedKey
        _blockedRef = Database.database().reference().child(DatabaseConstants.users).child(currentUser!)
                                                     .child(DatabaseConstants.blocked).child(_blockedKey)
        _blockedUser = data
    }
    var blockedUser: String {
        return _blockedUser
    }
    var blockedKey: String {
        return _blockedKey
    }
}
