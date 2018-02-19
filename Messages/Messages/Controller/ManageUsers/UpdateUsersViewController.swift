//
//  UpdateInfoViewController.swift
//  Messages
//
//  Created by Andrew Olson on 2/18/18.
//  Copyright © 2018 Andrew Olson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import Eureka

class UpdateUsersViewController: ProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userUid = KeychainWrapper.standard.string(forKey: DatabaseConstants.uid)
        let tags = ["username":"username", "email":"email", "password":"password", "image": "image"]
        buildForm(tags) {
            self.updateProfileInformation()
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    func updateProfileInformation() {
        if accountSetup {
            // update usermage and name
            updateUserImgandName()
            // update email
            updateUserEmail()
            // update password
            updateUserPassword()
        } else {
            // Throw error
            self.displayAlert(errorMessage)
        }
    }
    
    func updateUserImgandName() {
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
    func updateUserEmail() {
        if let _ = Auth.auth().currentUser?.uid {
            Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                if error != nil {
                    self.displayAlert(error!.localizedDescription)
                } else {
                    print("Email successfully updated")
                }
            }
        }
    }
    func updateUserPassword() {
        if let _ = Auth.auth().currentUser?.uid {
            Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                if error != nil {
                    self.displayAlert(error!.localizedDescription)
                } else {
                    print("Password successfully updated")
                }
            }
        }
    }
    func setUser(img: String) {
        let userData = [
            DatabaseConstants.username : username!,
            DatabaseConstants.userImg : img
        ]
        
        let location = Database.database().reference().child(DatabaseConstants.users).child(userUid)
        location.updateChildValues(userData)
        print("Username and Image updated")
        dismiss(animated: true, completion: nil)
    }
}
