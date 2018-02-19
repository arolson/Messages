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
        buildForm {
            self.updateProfileInformation()
        }
        // Do any additional setup after loading the view.
    }
    func updateProfileInformation() {
        if accountSetup {
            // Do Somthing
            
        } else {
            // Throw error
            self.displayErrorAlert(errorMessage)
        }
    }
    func updateUsername() {
        if let currentUserId = Auth.auth().currentUser?.uid {
         let ref = Database.database().reference().child(DatabaseConstants.users).child(currentUserId)
            ref.child(DatabaseConstants.username).value(forKey: username)
        }
    }
    func updateUserImg() {
        if let imgData = UIImageJPEGRepresentation(image, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) {
                (metadata, error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                    self.displayErrorAlert(error!.localizedDescription)
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
                    self.displayErrorAlert(error!.localizedDescription)
                }
            }
        }
    }
    func updateUserPassword() {
        
    }
    func setUser(img: String) {
        let userData = [
            DatabaseConstants.username : username!,
            DatabaseConstants.userImg : img
        ]
        KeychainWrapper.standard.set(userUid, forKey: DatabaseConstants.uid)
        let location = Database.database().reference().child(DatabaseConstants.users).child(userUid)
        location.setValue(userData)
        dismiss(animated: true, completion: nil)
    }
}
