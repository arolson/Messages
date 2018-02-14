//
//  File.swift
//  Messages
//
//  Created by Andrew Olson on 2/10/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper

class Search {
    private var _username: String!
    private var _userImage: String!
    private var _userKey: String!
    private var _userRef: DatabaseReference!
    
    var currentUser = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
    var username: String {
        return _username
    }
    var userImage: String {
        return _userImage
    }
    var userKey: String {
        return _userKey
    }
    init(username: String, userImage: String) {
        _username = username
        _userImage = userImage
    }
    init(userKey: String, postData: Dictionary<String, AnyObject>) {
        _userKey = userKey
        if let username = postData[DatabaseConstants.username] as? String {
            _username = username
        }
        if let userImage = postData[DatabaseConstants.userImg] as? String {
            _userImage = userImage
        }
        _userRef = Database.database().reference().child(DatabaseConstants.messages).child(_userKey)
    }
}
