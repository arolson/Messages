//
//  SignUpViewController.swift
//  Messages
//
//  Created by Andrew Olson on 1/31/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import Eureka

class SignUpViewController: ProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tags = ["username":"username", "email":"email", "password":"password", "image": "image"]
        buildForm(tags){self.createAccount()}
    }
    
    func createAccount() {
        
        if accountSetup {
            Auth.auth().createUser(withEmail: self.email, password: self.password, completion: {
                (user, error) in
                if error != nil {
                    self.displayAlert(error!.localizedDescription)
                } else {
                    if let user = user {
                        self.userUid = user.uid
                        self.uploadImg()
                    }
                }
            })
        } else {
            self.displayAlert(errorMessage)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension SignUpViewController {
    func uploadImg() {
        if let imgData = UIImageJPEGRepresentation(image, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) {
                (metadata, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    self.displayAlert(error!.localizedDescription)
                } else {
                    print("Upload")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.setUser(img: url)
                    }
                }
            }
        }
    }
    
    func setUser(img: String) {
        let userData = [
            DatabaseConstants.username : username!,
            DatabaseConstants.userImg : img,
            DatabaseConstants.fromDevice : AppDelegate.deviceId
        ]
        // KeychainWrapper to set user I
        KeychainWrapper.standard.set(userUid, forKey: DatabaseConstants.uid)
        
        let location = Database.database().reference().child(DatabaseConstants.users).child(userUid)
        
        location.setValue(userData)
        sendVerificationEmail()
        dismiss(animated: true, completion: nil)
    }
}
